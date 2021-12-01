# 监控目标主机状态

# 监控方法（ping ICMP协议）
# ping通-up，ping不通down

#1、关于禁ping 防止DDos攻击 禁的是陌生人
#2、网络有延迟 假报警问题
#       -ping的取值，次数阈值。3次全失败，失败
#       -ping的频率，秒级ping，5秒一次


#! /bin/bash

for (( i=1;i<4;i++ ))
# 测试代码
    do
	if  ping -c1 $1 &> /dev/null
	    then
		export ping_count"$i"=1
        else
	    export ping_count"$i"=0
        fi
# 时间间隔
    sleep 1
done

# 3次失败报警
if [ $ping_count1 -eq $ping_count2 ] && [ $ping_count2 -eq $ping_count3 ] && [ $ping_count3 -eq 0 ]
    then
	echo -e "$1 is [ \033[31m down \033[0m ]"
else
    echo -e "$1 is [ \033[32m up \033[0m ]"
fi
	
#unset $ping_count1
#unset $ping_count2
#unset $ping_count3


