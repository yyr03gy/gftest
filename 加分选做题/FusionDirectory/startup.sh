#!/bin/bash

set -ex

#
[ -z "$phpfpm" ] && { echo "env phpfpm not set in the docker-compose.yml" >&2;exit 1; }
cat<<EOF>/etc/apache2/mods-available/php7.0.conf
<FilesMatch ".+\.ph(p[3457]?|t|tml)$">
    SetHandler "proxy:fcgi://${phpfpm}"
</FilesMatch>
<FilesMatch ".+\.phps$">
    SetHandler "proxy:fcgi://${phpfpm}"
    # Deny access to raw php sources by default
    # To re-enable it's recommended to enable access to the files
    # only in specific virtual host or directory
    Require all denied
</FilesMatch>
# Deny access to files without filename (e.g. '.php')
<FilesMatch "^\.ph(p[3457]?|t|tml|ps)$">
    Require all denied
</FilesMatch>

# Running PHP scripts in user directories is disabled by default
# 
# To re-enable PHP in user directories comment the following lines
# (from <IfModule ...> to </IfModule>.) Do NOT set it to On as it
# prevents .htaccess files from disabling it.
<IfModule mod_userdir.c>
    <Directory /home/*/public_html>
        php_admin_flag engine Off
    </Directory>
</IfModule>
EOF
sed -i -r 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf

export APACHE_RUN_USER=${APACHE_RUN_USER:-www-data}
export APACHE_RUN_GROUP=${APACHE_RUN_USER:-www-data}
#创建用户
id -u ${APACHE_RUN_USER} 2>/dev/null || {
    useradd  -s /usr/sbin/nologin ${APACHE_RUN_USER}
}

#对必要目录进行授权
chown -R ${APACHE_RUN_USER}:${APACHE_RUN_USER} /var/log/apache2
chown -R ${APACHE_RUN_USER}:${APACHE_RUN_USER} /var/run/apache2
chown -R ${APACHE_RUN_USER}:${APACHE_RUN_USER} /var/cache/fusiondirectory
chown -R ${APACHE_RUN_USER}:${APACHE_RUN_USER} /var/spool/fusiondirectory
[ -d "/etc/fusiondirectory" ] && chown -R ${APACHE_RUN_USER}:${APACHE_RUN_USER} /etc/fusiondirectory
[ -d "/var/lock/apache2" ] && chown -R ${APACHE_RUN_USER}:${APACHE_RUN_USER} /var/lock/apache2

gosu ${APACHE_RUN_USER}:${APACHE_RUN_USER} "$@"