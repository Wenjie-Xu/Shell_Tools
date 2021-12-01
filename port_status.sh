# 监控端口状态

# 监控方法
# 1)通过systemctl、service 状态
# 2)通过lsof -i查看端口是否存在
# 3)查看进程ps -ef

#### 服务假死怎么办，服务down了，上述东西还在
# 4)测试端口是否有响应（推荐）
#    telnet协议

#! /bin/bash

#main
port_status () {
    # 创建临时文件
    temp_file=`mktemp port_temp.XXX`

    # 判断依赖命令telnet是否存在
    [ ! -x /usr/bin/telnet ] && echo "telnet command is not fund" && exit 1
    
    # 测试端口 $1 IP $2 port
    (telnet $1 $2 <<EOF
        quit
EOF
) &> $temp_file

    # 检索^]
    if grep "\^]" $temp_file &> /dev/null
	then
	    echo -e "$1:$2 is [\033[32mopen\033[0m]"
    else
	echo -e "$1:$2 is [\033[31mdown\033[0m]"
    fi

    # 删除临时文件
    rm -rf $temp_file
}

port_status $1 $2
