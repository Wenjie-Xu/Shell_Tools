#! /bin/bash

# 创建user01-user20，随机六位数密码
check() {
    # 1、检测当前用户，要求为root
	if [ ! `whoami` == 'root' ];then
        echo -e '\033[31m[ERROR]\033[0m Need root to execute~'
        exit 1
    fi
}

add() {
    read -p '输入想要创建的用户数 : ' num
    temp_file=`mktemp pw.XXX`
    #1)创建user
    for i in `seq -s ' ' -w 1 $num`
        do
            useradd user$i
    done
    #2)生成随机密码文件
    cat /dev/urandom | strings -6 | grep -E '^[a-Z]{6}$' | head -n $num > $temp_file

    #3)设置密码
    echo -e "username\t\tpasswd" > user_add_result.txt
    for i in `seq -s ' ' -w 1 $num`
        do
            pw=`head -n $i $temp_file | tail -n 1`
            echo $pw|passwd --stdin user$i &> /dev/null
            echo -e "user$i\t\t$pw" >> user_add_result.txt
    done

    #4)输出清单
    clear
    echo -e "\033[32m[INFO]\033[0m User add success, passwd file is user_add_result.txt"
    cat user_add_result.txt

    rm -rf $temp_file
}

check
add