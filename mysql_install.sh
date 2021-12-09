#! /bin/bash

# variables

VERSION=57
SOFTWARE_DIR=/home/xuwenjie/Softwares
MYSQL_DATADIR_DIR=/usr/local/mysql/data
MYSQL_REPO="mysql80-community-release-el7-3.noarch.rpm"

# functions
check() {
    # 1、检测当前用户，要求为root
    if [ ! `whoami` == 'root' ];then
        echo -e '\033[31m[ERROR]\033[0m Need root to execute~'
        exit 1
    fi

    # 2、检测是否有wget
    [ ! -x /usr/bin/wget ] && echo -e '\033[31m[ERROR]\033[0m Not find command /usr/bin/wget' && exit 1

    # 3、安装依赖
    if ! (yum -y install gcc-* pcre-devel zlib-devel elinks yum-utils 1> /dev/null);then
	    echo "ERROR: yum install error"
	    exit 1
    fi
}

install_pre() {
    # 1、检查并安装mysql对应版本的yum仓库
    REPO_COUNT=`yum repolist all|grep -e "mysql$VERSION.*x86_64"|wc -l`
    # 如果没有mysql的源
    if [ $REPO_COUNT -lt 1 ];then
        cd $SOFTWARE_DIR
        # 检查是否存在yum文件
        if [ ! -f $MYSQL_REPO ];then
            echo -e "\033[32m[INFO]\033[0m Start download mysql yum-repo..."
            if ! (wget -P $SOFTWARE_DIR https://repo.mysql.com/$MYSQL_REPO &> /dev/null);then
                echo -e "\033[31m[ERROR]\033[0m Wget mysql yum-repo '$MYSQL_REPO' fail"
                exit 1
            fi
        fi
        # 下载成功，安装，否则报错
        [ -f $MYSQL_REPO ] && (echo -e "\033[32m[INFO]\033[0m Start install yum-repo..." && rpm -ih $MYSQL_REPO &> /dev/null) || (echo -e "\033[31m[ERROR]\033[0m No file '$MYSQL_REPO', install fail" && exit 1)
        REPO_COUNT=`yum repolist all|grep -e "mysql$VERSION.*x86_64"|wc -l`
    fi
    # 安装后检查
    [ $REPO_COUNT -eq 1 ] && echo -e "\033[32m[INFO]\033[0m Already get yum-repo :'$MYSQL_REPO'" || (echo -e "\033[31m[ERROR]\033[0m Still can not find yum-repo, Please check" && exit 1)

    # 2、切换指定源版本
    echo -e "\033[32m[INFO]\033[0m Strat to checkout yum-version"
    # 找到enable的，全部变成disabled
    for NOW_ENABLE_VERSION in `yum repolist all|grep -e "mysql.*x86_64"|awk '{if($6=="enabled:"){print $1}}'|cut -d "/" -f1`
        do
            [[ ${NOW_ENABLE_VERSION: 0:1} == '!' ]] && NOW_ENABLE_VERSION= ${NOW_ENABLE_VERSION: 1}
            if ! (yum-config-manager --disable $NOW_ENABLE_VERSION 1> /dev/null);then
                echo -e '\033[31m[ERROR]\033[0m Yum config Fail,please check~'
                exit 1
            fi
    done
    # 将目标版本变成enable
    TO_ENABLE_VERSION=`yum repolist all|grep -e "mysql$VERSION.*x86_64"|awk '{print $1}'|cut -d "/" -f1`
    [[ ${TO_ENABLE_VERSION: 0:1} == '!' ]] && TO_ENABLE_VERSION= ${TO_ENABLE_VERSION: 1}
    if ! (yum-config-manager --enable $TO_ENABLE_VERSION 1> /dev/null);then
        echo -e '\033[31m[ERROR]\033[0m Yum config Fail,please check~'
        exit 1
    fi
    # 检查切换是否成功
    IS_ENABLE=`yum repolist all|grep -e "mysql$VERSION.*x86_64"|awk '{print $6}'`
    [[ $IS_ENABLE == 'enabled:' ]] && echo -e "\033[32m[INFO]\033[0m Prepare version:$VERSION success,ready to install" || (echo -e '\033[31m[ERROR]\033[0m Yum config Fail,please check~' && exit 1)
}



install() {
    # 使用yum安装mysql
    echo -e "\033[32m[INFO]\033[0m Strat to install mysql..."
    if ! (yum -y install mysql-community-server 1> /dev/null && yum -y install mysql-devel 1> /dev/null);then
        echo -e '\033[31m[ERROR]\033[0m Yum install fail,please check~'
        exit 1
    fi
    echo -e '\033[32m[INFO]\033[0m Yum install success'
    # 检查是否有命令文件，用systemd来启停检查
    if [ -x `which mysql` ] && [ -f /etc/my.cnf ]
        then
        # 启动失败，修改配置
        if ! (systemctl restart mysqld &> /dev/null && systemctl status mysqld &> /dev/null && systemctl stop mysqld &> /dev/null);then
            # 修改配置文件
            echo -e '\033[32m[INFO]\033[0m Start to config mysql data dir...'
            mkdir -p $MYSQL_DATADIR_DIR
            if ! (sed -i.bnk -r "s/^(datadir).*/datadir=${MYSQL_DATADIR_DIR//\//\\/}/" /etc/my.cnf);then echo -e '\033[31m[ERROR]\033[0m Mysql config error';exit 1;fi
            echo -e '\033[32m[INFO]\033[0m Config mysql data dir success'
        fi
        # 二次启动
        if (systemctl restart mysqld &> /dev/null && systemctl status mysqld &> /dev/null && systemctl stop mysqld &> /dev/null);then
            # systemd启动
            TEMP_PASSWD=`grep 'temporary password' /var/log/mysqld.log|awk 'END{print $NF}'`
            echo -e "\033[32m[INFO]\033[0m Mysql install and start success!"
            echo "TEMP_PASSWD : $TEMP_PASSWD"
        else
            echo -e '\033[31m[ERROR]\033[0m Unknow mysql start error,please check' && exit 1
        fi
    else
        echo -e '\033[31m[ERROR]\033[0m Cant find mysql config file,please check'
        exit 1
    fi
}

test() {
    # 1、开启服务，检查端口使用，NAME打开文件的确切名称
    # 2、检测是否有配置文件，有的话，找到临时密码
    # 创建临时文件，使用用户名和密码登录，看是否有user表
    echo 'hello'
}

# callback
check
install_pre
install