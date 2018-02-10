#!/bin/bash

#本脚本是非交互式自动安装slapd ldap-utils

#变量设置
rootpw="gftest@success"
domain="gftest.com"
organization="gftest"

#设置安装slapd自动回答的问题
function auto_answer(){
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
slapd slapd/backend string MDB
EOF
}

#安装函数
function run_install(){
    apt-get update
    apt-get -y install slapd ldap-utils
    dpkg-reconfigure -f noninteractive slapd
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

auto_answer
run_install
config_ldap