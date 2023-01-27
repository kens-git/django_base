#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# TODO: remove overriden input values

# Assumes there's an ssh key for the root user on the server
# that is also available locally.

# # Fresh install, log into root account
read -p "Full ssh key path: " root_key_path
read -p "Server host (domain or IP): " server_host
server_host=143.110.215.160
# #ssh -i $root_key_path root@$server_host
read -p "Enter name of user that runs the application: " host_username
host_username=user
ssh -i $root_key_path root@$server_host \
    "adduser --gecos \"\" $host_username"
ssh -i $root_key_path root@$server_host "usermod -aG sudo $host_username"
ssh -i $root_key_path root@$server_host "groupadd docker"
ssh -i $root_key_path root@$server_host "usermod -aG docker $host_username"
# TODO: use semicolon to avoid all of these ssh logins



read -p "Full ssh key path for user: " host_user_key_path
host_user_key_path=/home/user482/.ssh/staging_test
# TODO: cd should work if the commands are 'chained' when ssh'ing into the remote.
ssh -i $root_key_path root@$server_host "mkdir /home/${host_username}/.ssh"
ssh -i $root_key_path root@$server_host "touch /home/${host_username}/.ssh/authorized_keys"
scp -i $host_user_key_path ${host_user_key_path}.pub root@$server_host:"key.pub"
ssh -i $root_key_path root@$server_host \
    "cat key.pub >> /home/${host_username}/.ssh/authorized_keys"
ssh -i $root_key_path root@$server_host "rm key.pub"
ssh -i $root_key_path root@$server_host "cat /home/user/.ssh/authorized_keys"
ssh -i $root_key_path root@$server_host "chmod 700 /home/${host_username}/.ssh/"
ssh -i $root_key_path root@$server_host \
    "chmod 600 /home/${host_username}/.ssh/authorized_keys"
ssh -i $root_key_path root@$server_host \
    "chown -R user:user /home/${host_username}/.ssh/"



ssh -t -i $host_user_key_path $host_username@$server_host "\
    sudo apt-get update; \
    sudo apt-get install -y ca-certificates curl gnupg lsb-release; \
    sudo mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://download.docker.com/linux/debian/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
    echo \
        \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/debian $(lsb_release -cs) stable\" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; \
    sudo apt-get update; \
    sudo apt-get install -y \
        docker-ce docker-ce-cli containerd.io docker-compose-plugin"


# TODO: update this because the parts above set up the server,
#       and the bottom part copies the files and starts the server,
#       so maybe have 'setup' and 'deploy' scripts


# TODO: remove (or save for some 'destory script' or something):
#ssh -i $host_user_key_path $host_username@$server_host \
#    "docker kill $(docker ps -q)"
#ssh -i $host_user_key_path $host_username@$server_host \
#    "docker system prune --all --force --volumes"
#ssh -i $host_user_key_path $host_username@$server_host \
#    "rm -rf nginx/ app/ .envs/ docker-compose.staging.yml"

# TODO: these paths will need to be updated when the commands are chained
ssh -i $host_user_key_path $host_username@$server_host "mkdir .envs"
# ssh -i $host_user_key_path $host_username@$server_host \
#     "$app_path = /home/${host_username}/app"
user_path=/home/${host_username}
#app_path=$user_path/app
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
    "docker compose -f docker-compose.${host_env}.yml up --build"
ssh -i $host_user_key_path $host_username@$server_host "echo ${DJANGO_SECRET_KEY}"
