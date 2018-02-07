FROM ubuntu:latest

# 创建默认的mysql运行用户
RUN useradd -s /usr/sbin/nologin mysql

# 安装gosu 1.10
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	fetchDeps=' \
		ca-certificates \
		wget \
        lsb-release \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \ 
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
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
    
#	apt-get purge -y --auto-remove $fetchDeps
   
# 安装mysql 5.x lastest
WORKDIR /tmp

RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.9-1_all.deb

RUN dpkg -i ./mysql-apt-config_0.8.9-1_all.deb

RUN apt-get update

RUN echo "mysql-community-server mysql-community-server/root-pass password mypassword" | debconf-set-selections

RUN echo "mysql-community-server mysql-community-server/re-root-pass password mypassword" | debconf-set-selections

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server

RUN apt-get -y install tzdata

#目录 /var/lib/mysql  /var/run/mysqld的初始化
RUN rm -rf /var/lib/mysql/* && mkdir -p /var/run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
# 确保目录 /var/run/mysqld (mysql的lockfile和socker的目录) 任意用户都可写
	&& chmod 777 /var/run/mysqld
    
# 挂载数据卷
VOLUME /var/lib/mysql

#接入点脚本，用于初始化root用户密码等
COPY ./mysqlinit.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mysqlinit.sh
ENTRYPOINT ["mysqlinit.sh"]

EXPOSE 3306
CMD ["mysqld"]
