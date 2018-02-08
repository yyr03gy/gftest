##文件说明
1.autoinstall.sh --- 自动下载nginx lastest镜像和部署nginx 服务
2.docker-compose.yml --- docker-compose 文件
3.nginx.conf --- nginx 配置文件
4.rancher_api.conf --- rancher api 的配置文件（access_key,secret_key,url...）
5.rancher-compose.yml --- rancher-compose文件
6.remote_run.sh --- 远程执行脚本
8..env --- docker-compose.yml的变量文件
9.rancher_config.PNG --- rancher 上的nginx服务配置图
10.rancher_run_status.PNG --- 运行状态图
11.rancher_run_status2.PNG --- 运行状态图2
13.run_remote.PNG --- 远程执行脚本运行图

##使用说明
修改配置文件rancher_api.conf,填上对应的rancher url,key等
直接执行remote_run.sh在远程主机上部署mysql5.x lastest服务，脚本参数说明如下：
-h 远程主机ip/域名
-P SSH端口
-u 用户名（要root权限用户）
-p 密码
-d 上传上述部署文件的路径