#!/bin/bash
#本脚本git clone 脚本仓库到本地然后
#上传仓库当中的目录 <nginx自动安装配置> 到远程主机上指定的目录，并在远程主机上运行autoinstall.sh安装部署脚本

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
       sudo apt-get -y install expect
}

##run
/usr/bin/expect<<-EOF
set timeout -1
spawn scp -r -o StrictHostKeyChecking=no -P ${port} ${HOME}/gftest/nginx自动安装配置 ${user}@${host}:${remote_dir}
expect "*password:"
send "${passwd}\r\n"
expect eof
spawn ssh -o StrictHostKeyChecking=no -p ${port} ${user}@${host} /bin/bash ${remote_dir}/nginx自动安装配置/autoinstall.sh
expect "*password:"
send "${passwd}\r\n"
expect eof
exit
EOF