#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y docker git

systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# AL2023's docker package doesn't ship the Compose v2 plugin.
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

git clone ${github_repo_url} /opt/cloud-task-manager
cd /opt/cloud-task-manager

# IMPORTANT: the heredoc delimiter below is QUOTED ('ENVFILE', not ENVFILE).
# That disables bash variable/command expansion inside the heredoc entirely.
# Without the quotes, any $ in the DB password gets interpreted as a shell
# variable at boot time and silently deleted, corrupting DATABASE_URL.
cat > .env <<'ENVFILE'
DATABASE_URL=postgresql+psycopg://${db_username}:${db_password}@${db_host}:${db_port}/${db_name}
ENVFILE
chmod 600 .env

# Compose v2 defaults to buildx for --build, which isn't installed
# separately from the compose plugin above. Force the classic build engine.
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

docker compose -f docker-compose.prod.yml up -d --build
