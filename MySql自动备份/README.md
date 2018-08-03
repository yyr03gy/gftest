##本目录包含如下文件

- mysqlbackup.conf --> 备份的配置文件
- mysqlbackup.sh --> 备份脚本
- remote_run.sh --> 远程运行备份脚本
- remote_add_crontab.png --> 远程执行添加备份任务成功截图
- crontab_show.PNG --> 显示添加的备份计划任务
- git_repo_show.PNG --> git私有仓库的显示



##备份脚本mysqlbackup.sh的使用方式

1. 直接执行 /bin/bash mysqlbackup.sh 是按照备份配置mysqlbackup.conf创建自动备份任务，并且执行的用户要root权限才能授权和创建备份用户等操作
2. 加backup参数 /bin/bash mysqlbackup.sh backup是按照备份配置mysqlbackup.conf执行备份和commit到特定的git仓库




##远程运行脚本remote_run.sh的使用方式

- 远程执行脚本自动输入密码是依赖于expect工具，所以当发现本地机器没有安装就会安装
- 远程执行脚本会到远程主机上执行mysqlbackup.sh脚本创建备份任务
- 远程执行脚本remote_run.sh的运行参数说明如下：
- -h 远程主机
- -P 端口
- -u 用户名（要root权限用户）
- -p 密码
- -d 上传执行脚本到这里指定的目录



##注意：
- 所有文件都要放到同一目录下
- 请按照实际情况修改配置文件当中的值，如数据库ip、端口、用户、密码等
- 注意：
    备份的用户和git仓库都是在配置文件mysqlbackup.conf当中指定，要让计划任务把备份git到私有仓库还要把备份用户的ssh key添加到私有仓库当中并且ssh key不要密码验证才能保证能顺利上传到git私有仓库。
