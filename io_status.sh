# 磁盘io监控，明确知晓HD的使用情况

# 监控纸币奥 IO队列长度 IOPS吞吐量

# iostat队列长度，明确反馈IO是否忙
# iostat由sysstat提供，rpm -qf `which iostat`

#! /bin/bash

io() {
    # 监控设备的数量
    device_num=`iostat -d -x|grep -e "sd[a-Z]"|wc -l`
    iostat -d -x 1 3|grep -e "sd[a-Z]"|tail -n +$(($device_num+1))|awk '{io_long[$1]+=$9}END{for(i in io_long){print i,io_long[i]}}'
}

# 队列长度如何判断 2-3就比较大了
while true
    do
	io
	sleep 5
done
