# 统计系统中前十名使用内存最多的进程

#! /bin/bash

memory() {
    # 创建临时文件，用于接收top内容
    temp_file=`mktemp memory.XXX`
    # 收集任务管理器信息
    top -b -n1 > $temp_file
    # 按进程统计内存使用大小
    tail -n +8 $temp_file|awk '{array[$NF]+=$6}END{for (i in array)print array[i]/1024" MB",i}'|sort -k 1 -n -r|head -10 

    rm $temp_file
}

cpu() {
    # 创建临时文件，用于接收top内容
    temp_file=`mktemp cpu.XXX`
    # 收集任务管理器信息
    top -b -n1 > $temp_file
    # 按进程统计内存使用大小
    tail -n +8 $temp_file|awk '{array[$NF]+=$9}END{for (i in array)print array[i]/1024" MB",i}'|sort -k 1 -n -r|head -10

    rm $temp_file
}
echo "memory" "----------"
memory

echo "cpu" "-------------"
cpu
