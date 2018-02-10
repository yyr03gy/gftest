#!/bin/bash

#自动构建slapd服务镜像并启动

cd `dirname $0`
abs_path=`pwd`

#构建
function build(){
    docker images -q ldap_ubuntu | grep -q -E "[0-9a-z]" && {
        echo -e "\033[1;32mldap_ubuntu image had been builded before\033[0m"
    } || {
        docker build -t ldap_ubuntu . && {
            echo -e "\033[1;32mldap_ubuntu image build success\033[0m"
        } || {
            echo -e "\033[1;31mldap_ubuntu image build fail\033[0m"
            exit 1
        }
    }
}

#启动
function run(){
    [ -d /data/slapd ] || { mkdir -p /data/slapd; }
    docker-compose up -d && {
        echo -e "\033[1;32mstart up ldap success\033[0m"
    } || {
        echo -e "\033[1;31mstart up ldap fail\033[0m"
    }
}

build
run