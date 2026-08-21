#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y docker git

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

# The AL2023 "docker" package does not ship the Compose v2 plugin, which is
# why `docker compose` failed earlier ("docker: 'compose' is not a docker
# command"). Install the plugin explicitly into the CLI plugins directory.
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

git clone ${github_repo_url} /opt/cloud-task-manager
cd /opt/cloud-task-manager

# docker-compose.prod.yml is checked into the repo (no local Postgres
# container — the app connects to RDS via DATABASE_URL below).
cat > .env <<ENVFILE
DATABASE_URL=postgresql+psycopg://${db_username}:${db_password}@${db_host}:${db_port}/${db_name}
ENVFILE
chmod 600 .env

docker compose -f docker-compose.prod.yml up -d --build
