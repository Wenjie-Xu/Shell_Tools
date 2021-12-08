#! /bin/bash

# variables

VERSION=57
SOFTWARE_DIR=/home/xuwenjie/Softwares
MYSQL_REPO="mysql80-community-release-el7-3.noarch.rpm"

# functions
check() {
    # 1、检测当前用户，要求为root
    if [ ! $USER == 'root' ];then
        echo -e '\033[31m[ERROR]\033[0m Need root to execute~'
        exit 1
    fi
    # 2、检测是否有wget
    [ ! -x /usr/bin/wget ] && echo -e '\033[31m[ERROR]\033[0m Not find command /usr/bin/wget' && exit 1
}

install_pre() {
    # 1、检查是否有mysql对应版本的yum仓库
    REPO_COUNT=`yum repolist all|grep -e "mysql$VERSION.*x86_64"|wc -l`
    if [ $REPO_COUNT -lt 1 ];then # 如果没有mysql的源
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
        [ -f $MYSQL_REPO ] && rpm -ih $MYSQL_REPO &> /dev/null && echo -e "\033[32m[INFO]\033[0m Start install yum-repo..." || (echo -e "\033[31m[ERROR]\033[0m No file '$MYSQL_REPO', install fail" && exit 1)
        REPO_COUNT=`yum repolist all|grep -e "mysql$VERSION.*x86_64"|wc -l`
    fi
    # 安装后检查
    [ $REPO_COUNT -eq 1 ] && echo -e "\033[32m[INFO]\033[0m Already get yum-repo :'$MYSQL_REPO'" || (echo -e "\033[31m[ERROR]\033[0m Still can not find yum-repo, Please check" && exit 1)

    # 2、切换源版本
    IS_ENABLE=`yum repolist all|grep -e "mysql$VERSION.*x86_64"|awk '{print $NF}'`
    if [[ $IS_ENABLE == 'disable' ]];then
        # awk找到enable的那个，将它用命令disbale掉，在enable对应版本（$1为源名）
        echo 'hi'
    fi
}



install() {
    # 使用yum安装mysql
    echo 'hello'
    # 检查是否有命令文件，有的话用systemd来重启、开启，关闭，list-units检查，否则报错检查
    
}

test() {
    # 1、开启服务，检查端口使用，NAME打开文件的确切名称
    # 2、检测是否有配置文件，有的话，找到临时密码
    # 创建临时文件，使用用户名和密码登录，看是否有user表
    echo 'hello'
}

# callback

# check
install_pre