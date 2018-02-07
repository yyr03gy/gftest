#!/bin/bash 

cd `dirname $0`
abs_path=`pwd`

#编译镜像

echo "开始构建镜像....."
docker images -q mysql5_lastest_ubuntu:lastest | grep -q -E "[a-z0-9]" && {
    echo -e "\033[1;32mmysql5 lastest镜像之前已经构建完成\033[0m"
} || {
    docker build -t mysql5_lastest_ubuntu . || {
        echo -e "\033[1;31m构建mysql5 lastest 失败\033[0m";
        exit 1;
    }
    echo -e "\033[1;32m构建镜像完成\033[0m";
}
#调用rancher compose开启mysql服务


 
# Set the url that Rancher is on
export RANCHER_URL=http://192.168.188.137:8080/
# Set the access key, i.e. username
export RANCHER_ACCESS_KEY=5859422D630276D7D747
# Set the secret key, i.e. password
export RANCHER_SECRET_KEY=6Ee5LDtV5gF8PD22BHkSqYzRjibNEK5RykBKXwZ9

rancher-compose --url $RANCHER_URL --access-key $RANCHER_ACCESS_KEY --secret-key $RANCHER_SECRET_KEY -p mysql5_stack1 up && {
    echo -e "\033[1;32mrancher compose 启动 mysql5 lastest完成\033[0m"
} || {
    echo -e "\033[1;31mrancher compose 启动 mysql5 lastest 失败\033[0m";
    exit 1;
}