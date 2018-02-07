#!/bin/bash 

cd `dirname $0`
abs_path=`pwd`

#编译镜像

echo "开始构建镜像....."
docker images -q mysql5_lastest_ubuntu | grep -q -E "[a-z0-9]" && {
    echo -e "\033[1;32mmysql5 lastest镜像之前已经构建完成\033[0m"
} || {
    docker build -t mysql5_lastest_ubuntu . || {
        echo -e "\033[1;31m构建mysql5 lastest 失败\033[0m";
        exit 1;
    }
    echo -e "\033[1;32m构建镜像完成\033[0m";
}


#调用rancher compose开启mysql服务
 
#读入配置文件
source ${abs_path}/rancher_api.conf

#创建mysql数据卷路径
[ -d "/data/mysql" ] || { mkdir -p /data/mysql; }

#替换mysql文件成为绝对路径（rancher 不支持相对路径）
sed -i 's@${abs_path}@'${abs_path}'@' docker-compose.yml


rancher-compose --url $RANCHER_URL --access-key $RANCHER_ACCESS_KEY --secret-key $RANCHER_SECRET_KEY -p mysql5_stack1 up -d && {
    echo -e "\033[1;32mrancher compose 启动 mysql5 lastest完成\033[0m"
} || {
    echo -e "\033[1;31mrancher compose 启动 mysql5 lastest 失败\033[0m";
    exit 1;
}