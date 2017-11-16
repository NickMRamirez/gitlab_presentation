#!/bin/bash

if [ ! $(which docker) ]; then
    echo "Installing docker from apt"
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    echo "Installing docker-compose"
    sudo apt update
    sudo apt install -y docker-ce
    sudo curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    echo "Downloading Docker binaries"
    curl https://download.docker.com/linux/static/stable/x86_64/docker-17.09.0-ce.tgz | sudo tar -xvz -C /opt
fi
