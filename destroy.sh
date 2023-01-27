#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

read -p "Server host (domain or IP): " server_host
read -p "Enter name of user that runs the application: " host_username
read -p "Full ssh key path for user: " host_user_key_path
read -p "Environment (staging/prod): " environment

ssh -i $host_user_key_path $host_username@$server_host \
   "docker kill $(docker ps -q); \
    docker system prune --all --force --volumes; \
    rm -rf nginx/ app/ .envs/ docker-compose.${environment}.yml"
