#!/bin/bash

set -ex
fetchDeps='ca-certificates wget curl lsb-release'
apt-get update
apt-get install -y --no-install-recommends $fetchDeps
#rm -rf /var/lib/apt/lists/*
dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"
set +e
gosu_aws_url="`curl -Ls -o /dev/null -w %{url_effective} -m 3 https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch`"
gosuasc_aws_url="`curl -Ls -o /dev/null -w %{url_effective} -m 3 https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc)`"
set -e
wget -O /usr/local/bin/gosu "${gosu_aws_url/#https:/http:}"
wget -O /usr/local/bin/gosu.asc "${gosuasc_aws_url/#https:/http:}"
# 验证指纹
export GNUPGHOME="$(mktemp -d)"
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu
rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc
chmod +x /usr/local/bin/gosu
# 验证gosu是否安装成功
gosu nobody true