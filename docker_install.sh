#! /bin/bash

# variables
DOCKER_DNS="http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo"

# functions
check() {
    # 1、权限检查
    if [ `whoami` != 'root' ];then
        echo -e '\033[31m[ERROR]\033[0m Need root to execute~';exit 1
    fi
    # 2、安装依赖(yum-utils)
    if !( yum install -y yum-utils > /dev/null );then
        echo "ERROR: yum install error";exit 1
    fi
}

install_pre() {
    # 1、检查是否有对应的docker-yum仓库
    REPO_COUNT=`yum repolist all | grep docker-ce-stable/ | wc -l`
    if [ $REPO_COUNT -lt 1 ];then
        yum-config-manager --add-repo $DOCKER_DNS > /dev/null
        REPO_COUNT=`yum repolist all | grep docker-ce-stable/ | wc -l`
    fi
    # 安装后检查
    [ $REPO_COUNT -eq 1 ] && echo -e "\033[32m[INFO]\033[0m Already get yum-repo" || (echo -e "\033[31m[ERROR]\033[0m Still can not find yum-repo, Please check" && exit 1)

    # 2、检查是否enable
    IS_ENABLE=`yum repolist all | grep docker-ce-stable/|awk '{print $7}'`
    [[ $IS_ENABLE == 'enabled:' ]] && echo -e "\033[32m[INFO]\033[0m Prepare repo success,ready to install" || (echo -e '\033[31m[ERROR]\033[0m Yum config Fail,please check~' && exit 1)
}

install() {
    # 使用yum安装docker
    echo 1
}

test() {
    # 使用systemctl进行启动测试
    # 检查docker版本号
    echo 1
}

# callback
install_pre