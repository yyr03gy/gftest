#!/bin/bash
#本脚本实现自动下载Rancher的Docker镜像、Rancher Compose、Rancher CLI的stable 版本，
#自动安装Rancher并自动调用 docker-compose 运行 Rancher


#downlad the rancher cli stable (current version 0.6.7) and install
/usr/local/sbin/rancher --version | grep -q "0.6.7" && {
    echo -e "\033[1;32mrancher cli v0.6.7 had been installed before\033[0m";
} || {
    cd /tmp && \
    wget -O rancher-linux-amd64-v0.6.7.tar.gz \
    https://github.com/rancher/cli/releases/download/v0.6.7/rancher-linux-amd64-v0.6.7.tar.gz && \
    tar -xzf rancher-linux-amd64-v0.6.7.tar.gz && \
    /bin/cp -f rancher-v0.6.7/rancher /usr/local/sbin/ && \
    /usr/local/sbin/rancher --version | grep -q "0.6.7" && {
        echo -e "\033[1;32mrancher cli v0.6.7 install success\033[0m";
    }||{
        echo -e "\033[1;31mrancher cli v0.6.7 install failed\033[0m";
        exit 1;
    };
}

#download the rancher compose stable (current version v0.12.5) and install
/usr/local/sbin/rancher-compose --version | grep -q "0.12.5" && {
    echo -e "\033[1;32mrancher compose v0.12.5 had been installed before\033[0m";
} || {
    cd /tmp && \
    wget -O rancher-compose-linux-amd64-v0.12.5.tar.xz \
    https://github.com/rancher/rancher-compose/releases/download/v0.12.5/rancher-compose-linux-amd64-v0.12.5.tar.xz && \
    tar -xf rancher-compose-linux-amd64-v0.12.5.tar.xz && \
    /bin/cp -f rancher-compose-v0.12.5/rancher-compose /usr/local/sbin/ && \
    /usr/local/sbin/rancher-compose --version | grep -q "0.12.5" && {
        echo -e "\033[1;32mrancher compose v0.12.5 had been installed before\033[0m";
    } || {
        echo -e "\033[1;31mrancher compose v0.12.5 install failed\033[0m";
        exit 1;
    }
}


#download the rancher docker image
docker images -q rancher/server:stable | grep -q -E "[a-z0-9]" && {
    echo -e "\033[1;32mrancher server stable had been installed before\033[0m";
} || {
    docker pull rancher/server:stable && {
        echo -e "\033[1;32mrancher server stable installed success\033[0m";
    } || {
        echo -e "\033[1;32mrancher server stable installed failed\033[0m";
    }
}


#start the rancher server from docker-compose
cd `dirname ${0}`
#make the volumes
[ -d "/data/rancher/mysql" ] || { mkdir -p /data/rancher/mysql; }
docker-compose up -d && {
    echo -e "\033[1;32mstart rancher success\033[0m";
} || {
    echo -e "\033[1;31mstart rancher failed\033[0m";
}
