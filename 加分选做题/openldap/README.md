##文件说明
- autobuild.sh --- 构建openldap镜像并跟据docker-compose.yml和rancher-compose.yml部署服务
- docker-compose.yml --- docker-compose文件
- Dockerfile --- openldap的docker file
- init_slapd.sh --- entrypoint脚本，用于初始化ldap
- rancher_api.conf --- rancher api配置文件（url,key）
- remote_run.sh --- 远程执行脚本文件，git clone 代码并上传到远程主机执行autobuild.sh脚本
- sources.list --- 中科大的apt源，国内源，加速下载

##使用说明
- 在docker-compose.yml当中已经设置了固定ip（10.42.88.87）
- 直接执行remote_run.sh在远程主机上部署openldap服务，脚本参数说明如下：
- -h 远程主机ip/域名
- -P SSH端口
- -u 用户名（要root权限用户）
- -p 密码
- -d 上传上述部署文件的路径
- 执行完毕后会按照rancher_api.conf当中定义的rancher地址部署到rancher上，注意rancher_api.conf当中的access key和secret key的设置要正确。