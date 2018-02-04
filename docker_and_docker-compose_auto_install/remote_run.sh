#!/bin/bash


giturl = "https://github.com/yyr03gy/gftest.git"

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
git clone https://github.com/yyr03gy/gftest.git ~/gftest || {
    echo "git clone failed";
    exit 1;
}


##check expect have been installed
[ -x "/usr/bin/expect" ] || {
       sudo apt-get -y install expect
}

##run
/usr/bin/expect<<-EOF
spawn scp -o StrictHostKeyChecking=no -P ${port} ~/gftest/docker_and_docker-compose_auto_install/install_docker.sh ${user}@${host}:${remote_dir}
expect "*password:"
send "${passwd}\r\n"
expect eof
spawn ssh -o StrictHostKeyChecking=no -p ${port} ${user}@${host} /bin/bash ${remote_dir}/install_docker.sh
expect "*password:"
send "${passwd}\r\n"
expect eof
exit
EOF




