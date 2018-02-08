##文件说明如下：
1.Dockerfile ---- 构建mysql5.x lastest的docker file文件
2.docker-compose.yml ---- docker-compose 文件
3.rancher-compose.yml ---- rancher-compose 文件
4.mysqld.cnf ---- mysqld的配置文件
5..env ---- docker-compose.yml的变量定义文件
7.authbuild.sh ---- 自动构建并根据docker-compose.yml,rancher-compose.yml文件部署mysql服务
8.mysqlinit.sh ---- mysql容器的entrypoint脚本，用于初始化root用户密码和以docker-compose.yml当中指定的用户运行mysql进程
9.rancher_api.conf ---- rancher 的api参数设置(key,url)，用于rancher-compose调用rancher的api
10.remote_run.sh ---- 把本部署功能到远程机器上执行
11.check_mysql.sh ---- 测试mysql服务是否正常的脚本（不加参数运行显示用法）
12.run_remote_start.PNG ---- 开始执行远程脚本（remote_run.sh）图
13.run_remote_finish.PNG ---- 成功执行远程本图
14.check_mysql.PNG ---- 检查mysql链接成功图
15.rancher_status_show.PNG ---- rancher mysql5运行效果图
16.rancher_mysql5_config.PNG ---- rancher mysql5 配置参数图

##使用说明
修改配置文件rancher_api.conf,填上对应的rancher url,key等
直接执行remote_run.sh在远程主机上部署mysql5.x lastest服务，脚本参数说明如下：
-h 远程主机ip/域名
-P SSH端口
-u 用户名（要root权限用户）
-p 密码
-d 上传上述部署文件的路径

