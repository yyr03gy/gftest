##文件说明
1.install_docker.sh --- 自动安装docker,docker-compose lastest版本
2.remote_run.sh --- git 脚本库到本地机器，然后传到远程机器指定目录上执行install_docker.sh脚本。
3.install_success.PNG --- 执行远程脚本图


##使用说明 

注意，运行install_docker.sh脚本的用户需要root用户。
运行安装docker-compose的时候可能会出现如下错误：
    curl: (7) Failed to connect to github-production-release-asset-2e65be.s3.amazonaws.com port 443: Connection refused
    是到墙外网络不稳定的原因，有时重试多几次才会成功
远程执行脚本remote_run.sh的运行参数说明如下：
-h 远程主机
-P 端口
-u 用户名（执行安装docker docker-compose要root用户）
-p 密码
-d 上传执行脚本的路径