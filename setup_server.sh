#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Assumes there's an ssh key for the root user on the server
# that is also available locally.

read -p "Full ssh key path: " root_key_path
read -p "Server host (domain or IP): " server_host
read -p "Application user: " host_username
ssh -i $root_key_path root@$server_host \
    "adduser --gecos \"\" $host_username; \
    usermod -aG sudo $host_username; \
    groupadd docker; \
    usermod -aG docker $host_username"

read -p "Full ssh key path for user: " host_user_key_path
ssh -i $root_key_path root@$server_host \
    "mkdir /home/${host_username}/.ssh; \
    touch /home/${host_username}/.ssh/authorized_keys;"
scp -i $host_user_key_path ${host_user_key_path}.pub root@$server_host:"key.pub"
ssh -i $root_key_path root@$server_host \
    "cat key.pub >> /home/${host_username}/.ssh/authorized_keys; \
    rm key.pub; \
    cat /home/${host_username}/.ssh/authorized_keys; \
    chmod 700 /home/${host_username}/.ssh/; \
    chmod 600 /home/${host_username}/.ssh/authorized_keys; \
    chown -R ${host_username}:${host_username} /home/${host_username}/.ssh/"

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
