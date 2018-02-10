##文件说明

1. docker-compose.yml --- docker-compose 文件
2. install_rancher.sh --- 本地安装rancher,rancher compose,rancher cli stable 版本并启动rancher server服务
3. remote_run.sh --- git 脚本库到本地机器，然后传到远程机器指定目录上执行install_rancher.sh脚本。
4. install_rancher_success.PNG --- 安装并启动rancher成功图

##运行说明 


- 注意，运行install_rancher.sh脚本的用户需要root用户。
- 远程执行脚本remote_run.sh的运行参数说明如下：
- -h 远程主机
- -P 端口
- -u 用户名（执行安装要root用户）
- -p 密码
- -d 上传执行脚本的路径