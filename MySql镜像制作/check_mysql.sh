#!/bin/bash

#检查mysql是否正常服务脚本

function prompt_help(){
    echo "${0} usage: -h <host> -P <port> -u <user> -p <port>"
    exit 1
}


while getopts "h:P:u:p:" opt;do
    case $opt in
    h)
        host=$OPTARG;;
    P)
        port=$OPTARG;;
    u)
        user=$OPTARG;;
    p)
        passwd=$OPTARG;;
    *)
        prompt_help;;
    esac
done

[ -z "$host" -o -z "port" -o -z "$user" -o -z "$passwd" ] && {
    prompt_help
}

mysql -h${host} -P${port} -u${user} -p${passwd} -D mysql -e "select * from user where User = 'root';" 1>/dev/null 2>&1 && {
    echo -e "\033[1;32m链接到mysql成功\033[0m"
} || {
    echo -e "\033[1;31m链接到mysql失败\033[0m"
    exit 1
}