#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Assumes there's an ssh key for the root user on the server
# that is also available locally.

read -p "Server host (domain or IP): " server_host
read -p "Full ssh key path: " key_path
read -p "Application user: " host_username
read -p "Environment (staging/prod): " environment
ssh -t -i $key_path $host_username@$server_host \
    "docker compose -f docker-compose.${environment}.yml exec web \
    python manage.py createsuperuser"
