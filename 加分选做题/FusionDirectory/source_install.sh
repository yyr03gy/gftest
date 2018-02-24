#!/bin/bash

set -ex
#install fusiondirectory from source
version="1.2"

function install_apache2(){
    apt-get -y install apache2 libapache2-mod-php7.0 
    ln -s /etc/apache2/mods-available/proxy.load /etc/apache2/mods-enabled/proxy.load;\
    ln -s /etc/apache2/mods-available/proxy_fcgi.load /etc/apache2/mods-enabled/proxy_fcgi.load;\
}

function install_depends(){
    apt-get -y install libpath-class-perl libnet-ldap-perl libmime-base64-urlsafe-perl libcrypt-passwdmd5-perl \
    libcrypt-cbc-perl libfile-copy-recursive-perl libarchive-extract-perl libxml-twig-perl libterm-readkey-perl \
    libmsgcat-perl gettext schema2ldif
}

function get_latest(){
    curl -o /tmp/fusiondirectory-${version}.tar.gz -L \
    http://repos.fusiondirectory.org/sources/1.0/fusiondirectory/fusiondirectory-${version}.tar.gz
    #curl -o /tmp/fusiondirectory-plugins-${version}.tar.gz -L \
    #http://repos.fusiondirectory.org/sources/1.0/fusiondirectory/fusiondirectory-plugins-${version}.tar.gz
    curl -o /tmp/CHECKSUM.MD5 -L http://repos.fusiondirectory.org/sources/1.0/fusiondirectory/CHECKSUM.MD5
}

function check_md5(){
    f_md5=`md5sum /tmp/fusiondirectory-${version}.tar.gz |cut -d " " -f 1`
    #plugin_md5=`md5sum /tmp/fusiondirectory-plugins-${version}.tar.gz |cut -d " " -f 1`
    right_f_md5=`grep "fusiondirectory-${version}.tar.gz" /tmp/CHECKSUM.MD5 | cut -d " " -f 1`
    #right_plugin_md5=`grep "fusiondirectory-plugins-${version}.tar.gz" /tmp/CHECKSUM.MD5 | cut -d " " -f 1`
    [ "$f_md5" = "$right_f_md5" ] || { echo "check fusiondirectory-${version}.tar.gz md5 error" >&2;exit 1; }
    #[ "$plugin_md5" = "$right_plugin_md5" ] || { echo "check fusiondirectory-plugins-${version}.tar.gz md5 error" >&2;exit 1; }
}

function run_install(){
    tar -xzf /tmp/fusiondirectory-${version}.tar.gz -C /var/www/
    mv -f /var/www/fusiondirectory-${version} /var/www/fusiondirectory
    cd /var/www/fusiondirectory
    chmod 755 contrib/bin/*
    /bin/cp -f contrib/bin/* /usr/local/bin/
    fusiondirectory-setup --yes --check-directories --update-cache --update-locales
    sed -i -r 's@define \("SMARTY",.+\)@define ("SMARTY", "/usr/share/php/smarty3/Smarty.class.php")@' include/variables.inc
    chmod -R 777 /var/cache/fusiondirectory
    /bin/cp -f contrib/fusiondirectory.conf /var/cache/fusiondirectory/template/
    /bin/cp -f contrib/apache/fusiondirectory-apache.conf /etc/apache2/conf-available/
    cd /etc/apache2/conf-enabled && ln -s ../conf-available/fusiondirectory-apache.conf fusiondirectory-apache.conf
    
}

install_apache2
install_depends
get_latest
check_md5
run_install