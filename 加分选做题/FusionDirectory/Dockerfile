FROM ubuntu:latest

#导入sources.lists
ADD sources.list /etc/apt

# 安装gosu 1.10
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	fetchDeps=' \
		ca-certificates \
		wget \
        curl \
        lsb-release \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    set +e;\
    gosu_aws_url="`curl -Ls -o /dev/null -w %{url_effective} -m 3 https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch`";\
    gosuasc_aws_url="`curl -Ls -o /dev/null -w %{url_effective} -m 3 https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc)`";\
    set -e;\
	wget -O /usr/local/bin/gosu "`echo ${gosu_aws_url}|sed 's/^https:/http:/'`"; \    
	wget -O /usr/local/bin/gosu.asc "`echo ${gosuasc_aws_url}|sed 's/^https:/http:/'`"; \
    \
# 验证指纹
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
# 验证gosu是否安装成功
	gosu nobody true

#RUN apt-get update && apt-get -y install fusiondirectory libapache2-mod-php7.0;\
#    ln -s /etc/apache2/mods-available/proxy.load /etc/apache2/mods-enabled/proxy.load;\
#    ln -s /etc/apache2/mods-available/proxy_fcgi.load /etc/apache2/mods-enabled/proxy_fcgi.load;\
#    chmod 777 -R /var/cache/fusiondirectory

ADD source_install.sh /tmp
RUN ["/bin/bash","/tmp/source_install.sh"]

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data 

COPY startup.sh /usr/local/sbin
RUN chmod +x /usr/local/sbin/startup.sh
ENTRYPOINT ["startup.sh"]

EXPOSE 8080

CMD [ "apachectl", "-f", "/etc/apache2/apache2.conf", "-D", "FOREGROUND" ]

