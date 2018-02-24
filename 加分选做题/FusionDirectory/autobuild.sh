#!/bin/bash

set -e
cd `dirname $0`
abs_path=`pwd`


#构建php base images
function buildPHP(){
    docker images -q ubuntu_php:latest | grep -q -E "[0-9a-z]" && {
        echo -e "\033[1;32mubuntu_php latest had been built before\033[0m"
    } || {
        docker build -t ubuntu_php -f Dockerfile_base_php . && {
            echo -e "\033[1;32mubuntu_php build success\033[0m"
        } || {
            echo -e "\033[1;31mubuntu_php build fail\033[0m"
            exit 1
        }
    }

}

#构建 fusiondirectory images
function fusiondirectoryBuild(){
    docker images -q fusiondirectory:latest | grep -q -E "[0-9a-z]" && {
        echo -e "\033[1;32mfusiondirectory latest had been built before\033[0m"
    } || {
        docker build -t fusiondirectory --add-host "github-cloud.s3.amazonaws.com:219.76.4.4" . && {
            echo -e "\033[1;32mfusiondirectory build success\033[0m"
        } || {
            echo -e "\033[1;31mfusiondirectory build fail\033[0m"
            exit 1
        }
    }    
}

#开启服务
function startup(){
    #创建映射目录
    [ -d "/data/fusiondirectory/log" ] || { mkdir -p /data/fusiondirectory/log; }
    [ -d "/data/fusiondirectory/etc" ] || { mkdir -p /data/fusiondirectory/etc; }
    [ -d "/data/fusiondirectory/code" ] || { mkdir -p /data/fusiondirectory/code; }
    [ -d "/data/php-fpm/log" ] || { mkdir -p /data/php-fpm/log; }
    [ -d "/data/php-fpm/etc" ] || { mkdir -p /data/php-fpm/etc; }
    /bin/cp -f fusiondirectory-apache.conf /data/fusiondirectory/etc/
    source rancher_api.conf
    rancher-compose --url $RANCHER_URL --access-key $RANCHER_ACCESS_KEY --secret-key $RANCHER_SECRET_KEY \
    -p fusiondirectory-stack1 up -u -d && {
        echo -e "\033[1;32mrancher compose 启动 fusiondirectory_stack1 完成\033[0m"
    } || {
        echo -e "\033[1;31mrancher compose 启动 fusiondirectory_stack1 失败\033[0m";
        exit 1;
    } 
}

buildPHP
fusiondirectoryBuild
startup