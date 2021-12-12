#! /bin/bash

# 将mysql的binlog日志备份到备份服务器

# 思考
# 1)确定binlog的位置，和备份的时间间隔
	# 当前要备份的binlog是谁
	# 刷新binlog日志，生成新的binlog用于存储备份节点后的数据
# 2)打包binlog日志，以年月日_binlog.tar.gz
# 3)生成校验码 md5sum
# 4)将校验码和压缩包存入到文件夹：年-月=日 再次打包
# 5)使用scp拷贝到备份机器
# 6)备份机器解压收到的目录压缩包，通过校验码 校验binlog压缩包是否完整
	# 完整完成备份--发邮件给管理员，明确备份成功
	# 不完整报错--发邮件给管理员，要求手动备份

# variables
# 数据库参数
db_username='root'
db_password='asdASD123@'
binlog_dir='/var/lib/mysql'
# 目标服务器参数
to_role='root'
to_password='xwjxws123A'
to_addr='192.168.56.102'
# 备份文件地址
to_dir='/home/xuwenjie/Documents/mysql_backup'
# 校验目录
data_to_dir='/home/xuwenjie/Documents/mysql_backup_date'

# function
backup_check() {
	# 1、检测当前用户，要求为root
	if [ ! `whoami` == 'root' ];then
        echo -e '\033[31m[ERROR]\033[0m Need root to execute~'
        exit 1
    fi
	# 2 检查mysqld服务是否开启
	NET_NUM=`netstat -ntlp|grep mysql|wc -l`
	if [ $NET_NUM -lt 1 ];then
		echo -e '\033[31m[ERROR]\033[0m Mysql is not running'
        exit 1
	else
		echo -e '\033[32m[INFO]\033[0m Mysql is running, ready to backup~'
    fi
}

backup() {
	# 获得信息
	current_binlog=`mysql -u $db_username -p"$db_password" -e 'show master status'|egrep "mysql-bin.[[:digit:]]*"|awk '{print $1}'`
	
	# 准备备份
	# 1 刷新binlog，会产生新的binlog，保证上一份binlog的完整性
	mysql -u $db_username -p"$db_password" -e 'flush logs'
	# 2 打包要备份的binlog
	tar -zcf `date +%F`.binlog.tar.gz $binlog_dir/$current_binlog 1>/dev/null
	# 3 生成打包前校验码	
	md5sum `date +%F`.binlog.tar.gz > `date +%F`_md5sum.txt
	# 4 存入文件
	[ ! -d `date +%F` ] && mkdir `date +%F`
	mv `date +%F`.binlog.tar.gz `date +%F`
	mv `date +%F`_md5sum.txt `date +%F`
	# 5 打包目录
	tar -zcf `date +%F`.tar.gz `date +%F` 1>/dev/null
	# 6 拷贝
	# 要求提前做证数认证，信任
	scp `date +%F`.tar.gz $to_role@$to_addr:$to_dir 1>/dev/null
	if [ $? -ne 0 ];then
		echo -e "\033[31m [ERROR]\033[0m Scp `date +%F`.tar.gz fail"
		exit 1
	fi
	# 7 校验
	ssh $to_role@$to_addr "tar zxf $to_dir/`date +%F`.tar.gz -C $data_to_dir"
	ssh $to_role@$to_addr "cd $data_to_dir/`date +%F`;md5sum -c $data_to_dir/`date +%F`/`date +%F`_md5sum.txt"
	if [ $? -eq 0 ];then
		echo -e "\033[32m [INFO]\033[0m Success"
		ssh $to_role@$to_addr "rm -rf $data_to_dir/`date +%F`"
		rm -rf `date +%F`*
	else
		echo -e "\033[31m [ERROR]\033[0m Error"
	fi
}

backup_check
backup