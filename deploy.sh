#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

read -p "Server host (domain or IP): " server_host
read -p "Enter name of user that runs the application: " host_username
read -p "Full ssh key path for user: " host_user_key_path
ssh -i $host_user_key_path $host_username@$server_host "mkdir .envs"
user_path=/home/${host_username}
read -p "Environment (staging/prod): " host_env
scp -i $host_user_key_path \
    .envs/.env.${host_env} $host_username@$server_host:${user_path}/.envs
scp -i $host_user_key_path \
    .envs/.env.${host_env}.db $host_username@$server_host:${user_path}/.envs
scp -i $host_user_key_path \
    .envs/.env.${host_env}.proxy-companion \
    $host_username@$server_host:${user_path}/.envs
scp -i $host_user_key_path \
    docker-compose.${host_env}.yml $host_username@$server_host:$user_path
scp -i $host_user_key_path \
    -r {app,nginx} $host_username@$server_host:${user_path}
ssh -i $host_user_key_path $host_username@$server_host \
    "docker compose -f docker-compose.${host_env}.yml up -d --build"
