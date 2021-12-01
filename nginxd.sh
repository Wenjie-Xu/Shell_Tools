#! /bin/bash

process=nginx
nginxd=/usr/sbin/nginx
pid_file=/run/nginx.pid

# 判断进程数量
if [ -f $pid_file ];then
    PID=`cat $pid_file`
    pids=`ps -ef|grep $PID|grep -v "grep"|wc -l`    
else
    pids=0
fi

# 系统函数库
. /etc/init.d/functions

function start {
    # 进程文件和进程同时存在，说明进程已经启动
    if [ -f $pid_file ] && [ $pids -ge 1 ];then
	echo "Nginx is running"
    # 有进程文件，但是没有进程，删除进程文件后启动
    elif [ -f $pid_file ] && [$pids -lt 1 ];then
	rm -rf $pid_file
	action "Nginx Run " $nginxd
    else
	action "Nginx Run " $nginxd
    fi
}

function stop {
    # 进程文件和进程同时存在 
    if [ -f $pid_file ] && [ $pids -ge 1 ];then
        action "Nginx Stop" killall -s QUIT $process 
	rm -rf $pid_file
    # 有进程文件，但是没有进程
    elif [ -f $pid_file ] && [$pids -lt 1 ];then
        rm -rf $pid_file
    else   
        action "Nginx Stop" killall -s QUIT $process 2>/dev/null
    fi
}

function restart {
    stop
    sleep 2
    start
}

function reload {
    if [ -f $pid_file ] && [ $pids -ge 1 ];then
	action "Nginx reload" killall -s HUP $process 
    elif [ ! -f $pid_file ] || [ ! $pids -ge 1 ];then
	echo "Nginx Is Not Running"
    else
	action "Nginx reload" killall -s HUP $process 2> /dev/null
    fi
}

function status {
    if [ -f $pid_file ] && [ $pids -ge 1 ];then
	echo -e "Nginx Is [\033[33m Running \033[0m]"
    else
	echo -e "Nginx Is [\033[31m Stop \033[0m]"
    fi
}

# callback 

case $1 in
start)
    start;;
stop)
    stop;;
restart)
    restart;;
reload)
    reload;;
status)
    status;;
*)
    echo -e "\033[35m USEAGE: \033[0m start | stop | restart | reload |status";;
esac
