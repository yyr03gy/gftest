#!/bin/bash

##创建运行该备份的定时任务，可配置备份的时间、频率、需要备份的数据表、日志文件、存放备份文件的git私有库、压缩格式。
##为运行该自动备份定时任务创建必要的用户组和用户，并对其需要访问的目录、文件、其他服务等进行必要的授权，不得直接使用root账户运行该任务。
##备份完成后自动将生成的备份文件命名为“备份日期-时间戳”的格式。
##备份完成后自动将数据文件压缩成指定的格式。
##压缩完成后自动检测压缩文件是否完好、可正常解压。
##检测完成后自动将压缩文件commit到指定的Git私有库，并自动按备份的时间戳建立一个分支。


cd `dirname $0`
abs_path=`pwd`
self_name=`basename $0`
#引入配置文件
source ./mysqlbackup.conf



#修改一下ssh_config的配置，上传到git会自动添加对端机器的指纹到本机用户的~/.ssh/known_hosts 当中
function configssh(){
    grep -q "StrictHostKeyChecking no" /etc/ssh/ssh_config || {
        echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config || {
            echo "\033[1;31mconfig the ssh_config error\033[0m";
            exit 1;
        }
    }
}


#判断用户是否存在，不存在就创建
function create_user(){
    if [ "$user" = "root" ];then
        echo -e "\033[1;31mcan't use account root to run backup task ,please change the user in config file\033[0m"
        exit 1
    fi
    id $user 1>/dev/null 2>&1 || {
        useradd -m $user || exit 1;
        chown -R ${user}:${user} /home/${user} || exit 1;
    }
}

#对临时目录和备份保存目录授予权限
function give_permission(){
    [ -d "${temp_pdir}" ] || { mkdir -p "${temp_pdir}"; }
    [ -d "${store_dir}" ] || { mkdir -p "${store_dir}"; }
    chown -R ${user}:${user} ${temp_pdir}
    chown -R ${user}:${user} ${store_dir}
}

#创建计划任务
function create_crontab(){
    crontab_cmd="${backup_time} /bin/bash ${abs_path}/${self_name} backup 1>/dev/null 2>&1"
    crontab_content=$(crontab -l 2>/dev/null | grep -Fv "${abs_path}/${self_name}";echo "${crontab_cmd}")
    echo -e "$crontab_content"  | sudo -u $user crontab -
    [ "$?" = 0 ] && { echo -e "\033[1;32madd backup crontab success\033[0m"; } || {
        echo -e "\033[1;31madd backup crontab failed\033[0m";
    }
}


#压缩函数，根据指定的文件后缀压缩成相应的格式，并检查是否压缩完成
function compress(){
    dir=$1
    suffix=$2
    filebasename=$3
    cd $dir
    function error(){
        echo -e "\033[1;31m压缩备份文件 ${filebasename}.sql 失败\033[0m";
        exit 1;        
    }
    case $suffix in
    zip)
        compress_file=${filebasename}.zip
        zip -r ${compress_file} ./* && {
            #检查压缩包是否可以解压
            unzip -l ${compress_file} 1>/dev/null 2>&1 || {
                error;
            }
        } || {
            error;
        };;
    gz|bz)
        compress_file=${filebasename}.tar.${suffix}
        tar -czf ${compress_file} ./* && {
            #检查压缩包是否可以解压
            tar -tzf ${compress_file} 1>/dev/null 2>&1 || {
                error;
            }
        } || {
            error;
        };;
    xz)
        compress_file=${filebasename}.tar.xz
        tar -cf ${compress_file} ./* && {
            #检查压缩包是否可以解压
            tar -tf ${compress_file} 1>/dev/null 2>&1 || {
                error;
            }
        } || {
            error;
        };;
    bz2)
        compress_file=${filebasename}.tar.bz2
        tar -cjf ${compress_file} ./* && {
            #检查压缩包是否可以解压
            tar -tjf ${compress_file} 1>/dev/null 2>&1 || {
                error;
            }
        } || {
            error;
        };;
    *)
        echo -e "\033[1;31mnot support the suffix  ${suffix} format\033[0m"
        exit 1;;
    esac
    /bin/cp -f ${compress_file} ${store_dir}/
    
}


#备份和压缩
function backupdb(){
    #备份日期
    day=`date +"%Y%m%d"`
    #时间截
    timestamp=`date +"%s"`
    #临时目录和创建
    tmpdir=${temp_pdir}/${timestamp}
    [ -d "$tmpdir" ] || { mkdir -p $tmpdir; }
    mysqldump -h${host} -P${port} -u${dbuser} -p${dbpasswd} -B ${db} --tables ${tables} > ${tmpdir}/${day}-${timestamp}.sql && \
    /bin/cp -f ${log_dir}/${binlog_prefix}* ${tmpdir}/ && compress "${tmpdir}" "${format}" "${day}-${timestamp}" && \
    rm -rf ${tmpdir} && \
    echo -e "\033[1;32m backup mysql file ${day}-${timestamp}.sql and log success \033[0m" || \
    { echo -e "\033[1;31m backup mysql file ${day}-${timestamp}.sql and log failed \033[0m"; exit 1; }
}

#上传到私有git仓库
function git_commit(){
[ -f "${HOME}/.gitconfig" ] || {
cat >"${HOME}/.gitconfig"<<EOF
[user]
        email = `whoami`@gftest.com
        name = `whoami`
EOF
}

    git_basedir=`echo ${giturl}|gawk '{match($0,/.*\/([^/]+)\.git/,m);printf m[1]}'`
    [ -z "$git_basedir" ] && { echo -e "\033[1;31mthe git_url format error,please check\033[0m";exit 1;}
    git_dir=$HOME/${git_basedir}    
    if [ -d "$git_dir" ];then
        cd $git_dir
        #init_git="git pull"
    else
        cd $HOME
        init_git="git clone ${giturl}" 
    fi
    ${init_git} && cd $git_dir && git checkout -b ${timestamp} && /bin/cp -f ${store_dir}/${compress_file} ./ && git add ./${compress_file} && \
    git commit -m "add new backup timestamp is ${timestamp}" && git push origin ${timestamp}:${timestamp} && {
        echo -e "\033[1;32mcommit backup file ${compress_file} to git repo success\033[0m";
    }||{
        echo -e "\033[1;31mcommit backup file ${compress_file} to git repo failed\033[0m";
    }   
}


if [ "${1}" = "backup" ];then 
    #执行备份
    backupdb
    #上传到私有git仓库
    git_commit
else
    #修改ssh配置
    configssh
    #创建备份计划任务
    create_user
    give_permission
    create_crontab
fi
