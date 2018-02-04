#!/bin/bash

#update the apt package index
sudo apt-get update

#Install packages to allow apt to use a repository over HTTPS
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

#Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#Verify fingerprint
sudo apt-key fingerprint 0EBFCD88 | grep -q "Docker Release (CE deb) <docker@docker.com>" || {
        echo "Docker’s official GPG key ERROR ,please check the GPG key";
        exit 1
}


#set up the Docker stable repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
#update the apt package index
sudo apt-get update


#Install the latest version of Docker CE
sudo apt-get -y install docker-ce
   
#Verify that Docker CE is installed correctly
sudo docker run hello-world && {
        echo -e "\033[1;32minstall docker  lastest success\033[0m";
} || {
        echo "\033[1;31minstall docker  lastest failed\033[0m";
		exit 1;
}


#install the lastest docker-compose(1.18)
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o \
/usr/bin/docker-compose && sudo chmod +x /usr/bin/docker-compose

#check the docker-compose version
docker-compose --version | grep -q "1.18.0" && {
	echo -e "\033[1;32minstall the docker-compose 1.18.0 success\033[0m";
	exit 0;
} || {
	echo -e "\033[1;31minstall the docker-compose 1.18.0 failed\033[0m";
	exit 1;
}
