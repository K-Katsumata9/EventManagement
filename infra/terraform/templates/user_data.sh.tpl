#!/bin/bash
set -eux

dnf install -y docker
systemctl enable --now docker

DOCKER_CONFIG_PLUGINS=/usr/libexec/docker/cli-plugins
mkdir -p "$DOCKER_CONFIG_PLUGINS"
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o "$DOCKER_CONFIG_PLUGINS/docker-compose"
chmod +x "$DOCKER_CONFIG_PLUGINS/docker-compose"

aws ecr get-login-password --region ${aws_region} | \
  docker login --username AWS --password-stdin ${ecr_registry}

mkdir -p /opt/eventmanagement
cat > /opt/eventmanagement/docker-compose.prod.yml <<'EOF'
${docker_compose_content}
EOF

cat > /opt/eventmanagement/.env <<EOF
BACKEND_IMAGE=${backend_image}
FRONTEND_IMAGE=${frontend_image}
RAILS_MASTER_KEY=${rails_master_key}
DB_HOST=${db_host}
DB_PORT=${db_port}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
EOF

cd /opt/eventmanagement
docker compose --env-file .env -f docker-compose.prod.yml up -d
