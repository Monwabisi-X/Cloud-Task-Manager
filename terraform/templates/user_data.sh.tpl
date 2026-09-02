#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y docker amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# AL2023's docker package doesn't ship the Compose v2 plugin.
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

mkdir -p /opt/cloud-task-manager
cd /opt/cloud-task-manager

# No git clone, no on-instance build. GitHub Actions builds the image and
# pushes it to Docker Hub; this instance just pulls the published image.
#
# QUOTED heredoc ('COMPOSE') so bash does not touch the DATABASE_URL
# reference below -- that syntax is meant for docker compose itself to
# resolve from the .env file at compose-parse time, not for bash to expand
# at boot time. $${...} here is Terraform's own escape so templatefile()
# leaves it as a literal $${...} in the rendered output.
cat > docker-compose.prod.yml <<'COMPOSE'
services:
  web:
    image: ${dockerhub_image}:latest
    environment:
      DATABASE_URL: $${DATABASE_URL}
    ports:
      - "${app_port}:${app_port}"
    restart: unless-stopped
COMPOSE

# IMPORTANT: quoted heredoc delimiter ('ENVFILE', not ENVFILE) for the same
# reason -- this disables all bash variable/command expansion inside it.
# Without the quotes, any $ in the DB password gets interpreted as a shell
# variable at boot time and silently deleted, corrupting DATABASE_URL. The
# password below is also urlencode()'d by Terraform, closing off the same
# class of bug at the URL-format level too (see project documentation,
# Section 8.6).
cat > .env <<'ENVFILE'
DATABASE_URL=postgresql+psycopg://${db_username}:${db_password}@${db_host}:${db_port}/${db_name}
ENVFILE
chmod 600 .env

docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
