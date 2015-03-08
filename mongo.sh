#!/bin/bash

cur_dir=$(pwd)
#=============================================================
# mongodb
#=============================================================
#yum install -y mysql-devel

if [ ! -e /usr/local/mongodb/bin/mongod ]; then
	if [ ! -f "mongodb-linux-x86_64-2.4.5.tgz" ]; then
		wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.4.5.tgz
	fi
	tar zxvf mongodb-linux-x86_64-2.4.5.tgz
	mv mongodb-linux-x86_64-2.4.5 /usr/local/mongodb
	mkdir /data/mongodb/27017/data /data/mongodb/27017/etc /data/mongodb/27017/logs -p

	ln -s /usr/local/mongodb/bin/mongod /usr/bin

	echo "============================mongodb install completed======================"

	echo "===================================== Check install ==================================="
	clear
	if [ ! -s /usr/local/mongodb/bin/mongod ]; then
	  echo "[FAIL]/usr/local/mongodb/bin/mongod not found!!!"
	fi
fi

echo "========================== Check install ================================"
#
cat >/data/mongodb/27017/etc/mongodb.conf<<eof
dbpath =/data/mongodb/27017/data/
logpath =/data/mongodb/27017/logs/mongodb.log
logappend = true
#以守护进程的方式运行，创建服务器进程
fork = true
port = 27017
rest = true
profile = 1
slowms = 500

# 开启密码认证
#auth = true

# 主服务器配置
master = true
#类似于mysql的日志滚动，单位mb
oplogSize = 10000

# 从服务器配置
#slave = true
#source=10.48.100.1:27017   #指定主mongodb server
#slavedelay=10              #延迟复制，单位为秒
#autoresync=true            #当发现从服务器的数据不是最新时，向主服务器请求同步数据

journal =true

pidfilepath = /data/mongodb/27017/mongodb.pid
directoryperdb = /data/mongodb/27017/data/
eof

# Starting MongoDB 
#/usr/local/mongodb/bin/mongod --config /data/mongodb/27017/etc/mongodb.conf
#rm -f /data/mongodb/27017/mongod.lock
#/usr/local/mongodb/bin/mongod --master --dbpath=/data/mongodb/27017 --logpath=/data/mongodb/27017/logs.log --logappend --port=27017 --fork
# mongod --shutdown --dbpath=/data/mongodb/27017

# service install
cp initd/init.d.mongo_27017 /etc/init.d/mongo_27017
chmod 755 /etc/init.d/mongo_27017
chkconfig --level 345 mongo_27017 on
/etc/init.d/mongo_27017 start

echo "Starting MongoDB listen on 27017"

#=============================================================
# rockmongo
#=============================================================
if [ ! -d "/data/wwwroot/_rm" ]; then
	if [ ! -f "rockmongo-1.1.5.zip" ]; then
		wget http://rockmongo.com/release/rockmongo-1.1.5.zip
	fi
	unzip rockmongo-1.1.5.zip
	mv rockmongo /data/wwwroot/_rm
fi

