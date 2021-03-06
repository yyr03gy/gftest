#!/bin/bash
#本脚本git clone 脚本仓库到本地然后
#上传mysqlbackup.sh脚本到远程主机上创建mysql备份任务

#check home dir
[ -z "$HOME" ] && { echo "can't found home dir";exit 1; }

giturl="https://github.com/yyr03gy/gftest.git"

prompt_help="usage:${0} -h <host> -P <port> -u <user> -p <passwd> -d <remote_dir>"

while getopts "h:P:u:p:d:" opt;do
    case $opt in
    h)
        host=$OPTARG
        ;;
    P)
        port=$OPTARG
        ;;
    u)
        user=$OPTARG
        ;;
    p)
        passwd=$OPTARG
        ;;
    d)    
        remote_dir=$OPTARG
        ;;
    *)
        echo $prompt_help
        exit 1
        ;;
    esac
done

[ -z "$host" -o -z "$port" -o -z "$user" -o -z "$passwd" -o -z "$remote_dir" ] && {
    echo $prompt_help
    exit 1
}

#git clone scripts to user home dir
[ -d "${HOME}/gftest" ] || {
    git clone https://github.com/yyr03gy/gftest.git ${HOME}/gftest || {
        echo "git clone failed";
        exit 1;
    }
}

##check expect have been installed
[ -x "/usr/bin/expect" ] || {
        echo -e "\033[1;33m check local host havn't install expect,now will be installed\033[0m"
        sudo apt-get -y install expect
}

##run
/usr/bin/expect<<-EOF
set timeout -1
spawn scp -r -o StrictHostKeyChecking=no -P ${port} "${HOME}/gftest/MySql自动备份" ${user}@${host}:${remote_dir}/
expect "*password:"
send "${passwd}\r\n"
expect eof
spawn ssh -o StrictHostKeyChecking=no -p ${port} ${user}@${host} /bin/bash ${remote_dir}/MySql自动备份/mysqlbackup.sh
expect "*password:"
send "${passwd}\r\n"
expect eof
exit
EOF