#!/bin/bash

set -eu
#本脚本是非交互式自动安装slapd ldap-utils

#变量设置
rootpw="$SLAPD_ROOT_PASSWORD"
domain="$SLAPD_ROOT_DOMAIN"
organization="$SLAPD_ORGANIZATION"

#设置安装slapd自动回答的问题
function reconfig_slapd(){
cat << EOF | debconf-set-selections
slapd slapd/password1 password ${rootpw}
slapd slapd/password2 password ${rootpw}
slapd slapd/internal/generated_adminpw password ${rootpw}
slapd slapd/internal/adminpw password ${rootpw}
slapd slapd/no_configuration boolean false
slapd shared/organization string ${organization}
slapd slapd/purge_database boolean false
slapd slapd/domain string ${domain}
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/invalid_config boolean true
slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
slapd slapd/dump_database string when needed
slapd slapd/move_old_database boolean true
slapd slapd/backend string HDB
EOF
dpkg-reconfigure -f noninteractive slapd
}

#安装函数
function run_install(){
    apt-get update
    apt-get -y install slapd ldap-utils    
}

#配置客户端配置文件（ldap）
function config_ldap(){
    #转换域名成为dc=example,dc=com,dc=cn等格式
    dn=`echo ${domain} | sed -n '{s/\./,dc=/g;s/^/dc=/;p}'`
cat << EOF > /etc/ldap/ldap.conf
BASE    $dn
URI     ldap://localhost
SSL     no
pam_password    md5
TLS_CACERT      /etc/ssl/certs/ca-certificates.crt
EOF
}

#安装ldap FusionDirectory Schema
function install_FusionDirectory_Schema(){
    grep -q "fusiondirectory repository" /etc/apt/sources.list || {
cat <<EOF >>/etc/apt/sources.list
# fusiondirectory repository
deb http://repos.fusiondirectory.org/fusiondirectory-current/debian-jessie jessie main
 
# fusiondirectory extra repository
deb http://repos.fusiondirectory.org/fusiondirectory-extra/debian-jessie jessie main
EOF
    
    }
    #添加gpg key
    gpg --keyserver keys.gnupg.net --recv-key 0xD744D55EACDA69FF
    gpg --export -a "FusionDirectory Project Signing Key <contact@fusiondirectory.org>" > /tmp/FD-archive-key
    apt-key add /tmp/FD-archive-key
    
    apt-get update
    #安装
    apt-get -y install fusiondirectory-schema
}

function import_FusionDirectory_Schema(){
    #更新schema到ldap
    /usr/sbin/slapd -h 'ldap:/// ldapi:///' -g openldap -u openldap -F /etc/ldap/slapd.d
    fusiondirectory-insert-schema
    kill `pgrep -f "^/usr/sbin/slapd"`
    sleep 2    
}

function INIT_END(){
    echo -e "LDAP following parameter initialed\ndomain:${domain}\norganization:${organization}" > /etc/ldap/inited.flag
}

if [ -f "/etc/ldap/inited.flag" ];then
    echo "LDAP have been initialed before"
else
    echo "start init LDAP"
    reconfig_slapd
    config_ldap
    import_FusionDirectory_Schema
    INIT_END
fi
"$@" 1>/dev/null 2>/var/lib/ldap/error.log