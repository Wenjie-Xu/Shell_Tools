# Nginx安装脚本

# 安装用户 root
# 安装前准备 - 依赖包、源码包获得
# 安装
# 启动、测试

#! /bin/bash

#variables
nginx_pkg="nginx-1.18.0.tar.gz"
nginx_source_doc=`echo $nginx_pkg|cut -d "." -f1-3` 
download_dir="/home/xuwenjie/Softwares/"
install_dir="/usr/local/nginx"
nginx_user="www"
nginx_group="www"

# functions
check() {
    # 检测当前用户，要求为root
    if [ "$USER" != 'root' ];then
	echo "需要root权限"
	exit 1
    fi
    # 检查wget命令
    [ ! -x /usr/bin/wget ] && echo "没有找到命令：/usr/bin/wget" && exit 1
    #if [ ! -x /usr/bin/wget ];then
	#echo "没有找到命令：/usr/bin/wget"
	#exit 1
    #fi
}

install_pre() {
    # 1、安装依赖
	if ! (yum -y install gcc-* pcre-devel zlib-devel elinks 1> /dev/null)
		then
			echo "ERROR: yum install error"
			exit 1
	fi

	# 2、下载源码包
	if wget -P $download_dir https://nginx.org/download/$nginx_pkg &> /dev/null
		then
			cd $download_dir
			tar -zxf $nginx_pkg
			if [ ! -d $nginx_source_doc ];then
				echo "ERROR: not found $nginx_source_doc"
				exit 1
			fi
	else
		echo "ERROR: wget nginx fail"
	fi
}

install() {
	# 1、创建nginx管理用户
	useradd -r -s /sbin/nologin $nginx_user
	# 2、安装nginx源码
	cd $download_dir$nginx_source_doc
	echo "nginx configure......"
	if ./configure --prefix=$install_dir --user=$nginx_user --group=$nginx_group 1>/dev/null
	    then
		echo "nginx make......"
		if make 1>/dev/null;then
		    echo "nginx install......."
		    if make install 1>/dev/null;then
		        echo "nginx install success"
		    else
			echo "ERROR: nginx install fail";exit 1
		    fi
		else
		    echo "ERROR: nginx make fail";exit 1
		fi
	else
	    echo "ERROR: nginx configure fail";exit 1
	fi
}

nginx_test() {
    if $install_dir/sbin/nginx;then
	# 尝试连接localhost
	elinks http://localhost -dump
	echo "nginx start SUCCESS!"
    else
	echo "ERROR: nginx start FAIL"	
    fi
}

#### callable
echo "This is nginx install script"
read -p "press Y install,press C cancel :" ch
if [ $ch == 'Y' ];then
    check;install_pre;install;nginx_test
elif [ $ch =='C' ];then
    exit;
fi
