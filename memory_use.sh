# 内存使用率统计脚本

# 监控命令：free或者/proc/meminfo

#! /bin/bash

memory_use() {
awk '
{
    if($1=="MemTotal:"){
    	total=$2
    }else if($1=="MemFree:"){
        free=$2
    }else if($1=="Cached:"){
	cached=$2
    }else if($1=="Buffers:"){
        buffers=$2
    }else if($1=="SwapCached:"){
    	swap=$2
    }
}END{
print "TotalUsed:"(total-free)/total*100"%";
print "Cached:"cached/total*100"%";
print "Buffers:"buffers/total*100"%";
print "Swap:"swap/total*100"%";
}' /proc/meminfo
}

memory_use
