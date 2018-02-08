#!/bin/bash

#实现nginx docker lastest 镜像的自动下载并根据docker-compose.yml、rancher-compose.yml自动部署服务



function download_nginx_image(){
    docker pull nginx && {
        echo -e "\033[1;32mdownload lastest nginx image success\033[0m"
    } || {
        echo -e "\033[1;32mdownload lastest nginx image failed\033[0m"
        exit 1
    }
}

function deploy_nginx_services(){
    source rancher_api.conf
    sed -i -r 's@[^"]*(/nginx.conf:/etc/nginx/nginx.conf)@'${abs_path}'\1@' docker-compose.yml
    rancher-compose --url $RANCHER_URL --access-key $RANCHER_ACCESS_KEY --secret-key $RANCHER_SECRET_KEY -p nginx_stack1 up -d && {
        echo -e "\033[1;32mrancher compose 启动 nginx lastest完成\033[0m"
    } || {
        echo -e "\033[1;31mrancher compose 启动 nginx lastest 失败\033[0m";
        exit 1;
    }
}

cd `dirname $0`
abs_path=`pwd`

download_nginx_image
deploy_nginx_services

