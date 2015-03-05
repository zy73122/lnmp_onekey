#!/bin/bash

cur_dir=$(pwd)
PHP_BIN=/usr/local/php/bin/php
PHP_IZE=/usr/local/php/bin/phpize
PHP_CONFIG=/usr/local/php/bin/php-config
PHP_INI=/usr/local/php/etc/php.ini

#errexit
set -e

function php_restart()
{
	/etc/init.d/php-fpm restart
}

function install_ext_memcache()
{
	echo '#==============================================='
	echo '# memcache 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep memcache`" ]; then
		echo "memcache has been installed"
		return
	fi
	if [ ! -f "memcache-2.2.7.tgz" ]; then
		wget -c http://pecl.php.net/get/memcache-2.2.7.tgz
	fi
	tar zxf memcache-2.2.7.tgz
	cd memcache-2.2.7/
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config --enable-memcache
	make && make install
	cd ../
	echo "extension = memcache.so">>/usr/local/php/etc/php.ini
}

function install_ext_memcached()
{
	echo '#==============================================='
	echo '# memcached 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep memcached`" ]; then
		echo "memcached has been installed"
		return
	fi
	if [ ! -d "/usr/local/libmemcached-1.0.4" ]; then
		if [ ! -f "libmemcached-1.0.4.tar.gz" ]; then
			wget -c https://launchpad.net/libmemcached/1.0/1.0.4/+download/libmemcached-1.0.4.tar.gz
		fi
		tar zxf libmemcached-1.0.4.tar.gz
		cd libmemcached-1.0.4/
		./configure --prefix=/usr/local/libmemcached-1.0.4 --with-memcached
		make && make install
		cd ../
	fi

	if [ ! -f "memcached-2.2.0.tgz" ]; then
		wget -c http://pecl.php.net/get/memcached-2.2.0.tgz
	fi
	tar zxf memcached-2.2.0.tgz
	cd memcached-2.2.0/
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config --with-libmemcached-dir=/usr/local/libmemcached-1.0.4 --enable-memcached --disable-memcached-sasl
	make && make install
	cd ../
	echo "extension = memcached.so">>/usr/local/php/etc/php.ini
}

function install_ext_phpredis()
{
	echo '#==============================================='
	echo '# phpredis 扩展安装'
	echo '#==============================================='
	#https://github.com/owlient/phpredis/releases
	if [ "`$PHP_BIN -m | grep redis`" ]; then
		echo "phpredis has been installed"
		return
	fi
	if [ ! -f "phpredis-2.1.1.tar.gz" ]; then
		wget -c https://github.com/owlient/phpredis/archive/2.1.1.tar.gz -O phpredis-2.1.1.tar.gz
	fi
	tar zxvf phpredis-2.1.1.tar.gz
	cd phpredis-2.1.1
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	make && make install
	cd ../
	echo "extension = redis.so">>/usr/local/php/etc/php.ini
}

function install_ext_mongo()
{
	echo '#==============================================='
	echo '# mongo 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep mongo`" ]; then
		echo "mongo has been installed"
		return
	fi
	if [ ! -f "mongo-1.5.7.tgz" ]; then
		wget -c http://pecl.php.net/get/mongo-1.5.7.tgz
	fi
	tar zxf mongo-1.5.7.tgz
	cd mongo-1.5.7
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config --enable-mongo=share
	make && make install
	cd ../
	echo "extension = mongo.so">>/usr/local/php/etc/php.ini
}

function install_ext_pdo_mysql()
{
	echo '#==============================================='
	echo '# pdo_mysql 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep pdo_mysql`" ]; then
		echo "pdo_mysql has been installed"
		return
	fi
	if [ ! -f "PDO_MYSQL-1.0.2.tgz" ]; then
		wget -c http://pecl.php.net/get/PDO_MYSQL-1.0.2.tgz
	fi
	tar zxvf PDO_MYSQL-1.0.2.tgz 
	cd PDO_MYSQL-1.0.2
	/usr/local/php/bin/phpize
    #export CPPFLAGS='-I/usr/local/mysql/include/'
	./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql
	#vi Makefile
	#INCLUDES = ... I/usr/local/mysql/include [/mysql]
	make && make install
	cd ../
	echo "extension = pdo_mysql.so">>/usr/local/php/etc/php.ini
}

function install_ext_imagick()
{
	echo '#==============================================='
	echo '# imagick 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep imagick`" ]; then
		echo "imagick has been installed"
		return
	fi
	# yum install ImageMagick-devel
	if [ ! -f "imagick-3.0.1.tgz" ]; then
		wget -c http://pecl.php.net/get/imagick-3.0.1.tgz
	fi
	tar zxvf imagick-3.0.1.tgz 
	cd imagick-3.0.1
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	make && make install
	cd ../
	echo "extension = imagick.so">>/usr/local/php/etc/php.ini
}

function install_ext_yaf()
{
	echo '#==============================================='
	echo '# yaf 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep yaf`" ]; then
		echo "yaf has been installed"
		return
	fi
	if [ ! -f "yaf-2.2.9.tgz" ]; then
		wget -c http://pecl.php.net/get/yaf-2.2.9.tgz
	fi
	tar zxvf yaf-2.2.9.tgz
	cd yaf-2.2.9
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	make && make install
	cd ../
	echo "extension = yaf.so">>/usr/local/php/etc/php.ini
}

function install_ext_amqp()
{
	echo '#==============================================='
	echo '# amqp 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep amqp`" ]; then
		echo "amqp has been installed"
		return
	fi
	#dependencies: 
	#wget -c http://ftp.gnu.org/gnu/autoconf/autoconf-2.63.tar.gz 
	#tar zxvf autoconf-2.63.tar.gz 
	# cd autoconf-2.63
	# ./configure
	# make && make install
	# cd ../
	if [ ! -f "rabbitmq-c-master.zip" ]; then
		wget -c https://github.com/alanxz/rabbitmq-c/archive/master.zip -O rabbitmq-c-master.zip
	fi
	unzip rabbitmq-c-master.zip
	cd rabbitmq-c-master
	autoreconf -i && ./configure
	make && make install

	if [ ! -f "amqp-1.0.9.tgz" ]; then
		wget -c http://pecl.php.net/get/amqp-1.0.9.tgz
	fi
	tar -zxf amqp-1.0.9.tgz
	cd amqp-1.0.9
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config --with-amqp
	make && make install
	echo "extension = amqp.so">>/usr/local/php/etc/php.ini
}

function install_ext_phprabbit()
{
	echo '#==============================================='
	echo '# php-rabbit 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep rabbit`" ]; then
		echo "php-rabbit has been installed"
		return
	fi
	# need 2.63 version autoconf
	#if [ ! -f "autoconf-2.63.tar.gz" ]; then
	#	wget -c http://down1.chinaunix.net/distfiles/autoconf-2.63.tar.gz
	#fi
	#tar zxvf autoconf-2.63.tar.gz
	#cd autoconf-2.63/
	#./configure
	#make && make install
	#cd ../
	##cp /usr/local/autoconf-2.63/bin/* /usr/bin/
	if [ ! -f "rabbitmq-c.tar.gz" ]; then
		wget -c http://hg.rabbitmq.com/rabbitmq-c/archive/ce1eaceaee94.tar.gz -O rabbitmq-c.tar.gz
	fi
	if [ ! -f "rabbitmq-codegen.tar.gz" ]; then
		wget -c http://hg.rabbitmq.com/rabbitmq-codegen/archive/c7c5876a05bb.tar.gz -O rabbitmq-codegen.tar.gz
	fi
	tar zxf rabbitmq-c.tar.gz
	tar zxf rabbitmq-codegen.tar.gz
	mv rabbitmq-codegen-c7c5876a05bb/ rabbitmq-c-ce1eaceaee94/codegen
	cp -Rf rabbitmq-c-ce1eaceaee94/codegen /codegen
	cd rabbitmq-c-ce1eaceaee94
	autoreconf -i
	./configure 
	make && make install 
	cd ../

	tar zxf php-rabbit.r91.tar.gz
	cd php-rabbit
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config --with-rabbit
	make && make install 
	cd ../
	echo "extension = rabbit.so">>/usr/local/php/etc/php.ini
}

function install_ext_zendguard()
{
	echo '#==============================================='
	echo '# zendguard 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep ZendGuardLoader`" ]; then
		echo "zendguard has been installed"
		return
	fi
	echo 'Sorry,unsupport...'
	exit
	if [ ! -f "ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz" ]; then
		wget -c http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz 
	fi
	
	tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
	cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/
	echo "zend_extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/ZendGuardLoader.so" >> /usr/local/php/etc/php.ini
}

function install_ext_ketama()
{
	echo '#==============================================='
	echo '# ketama 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep ketama`" ]; then
		echo "ketama has been installed"
		return
	fi
	if [ ! -f "ketama-master.zip" ]; then
		wget -c https://github.com/RJ/ketama/archive/master.zip -O ketama-master.zip
	fi
	unzip ketama-master.zip
	cd ketama-master
	cd libketama
	make && make install
	ln -s /usr/lib/libketama.so /usr/local/lib/libketama.so.1
	cd ..

	cd php_ketama
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	make && make install
	cd ../..
	echo "extension = ketama.so">>/usr/local/php/etc/php.ini
}

function install_ext_eaccelerator()
{
	echo '#==============================================='
	echo '# eaccelerator 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep eaccelerator`" ]; then
		echo "eaccelerator has been installed"
		return
	fi
	if [ ! -f "eaccelerator-eaccelerator-e19b15a.tar.gz" ]; then
		echo "please download eaccelerator first!"
		return
	fi
	tar zxf eaccelerator-eaccelerator-e19b15a.tar.gz
	cd eaccelerator-eaccelerator-e19b15a
	/usr/local/php/bin/phpize
	./configure --enable-shared --with-php-config=/usr/local/php/bin/php-config
	make && make install 
	cd ../
	mkdir /tmp/eaccelerator
	chmod 0777 /tmp/eaccelerator

	echo "
	;If you use a thread safe build of PHP you must use "zend_extension_ts" instead of "zend_extension". 
	extension="eaccelerator.so"
	eaccelerator.shm_size="16"
	eaccelerator.cache_dir="/tmp/eaccelerator"
	eaccelerator.enable="1"
	eaccelerator.optimizer="1"
	eaccelerator.check_mtime="1"
	eaccelerator.debug="0"
	eaccelerator.filter=""
	eaccelerator.shm_ttl="0"
	eaccelerator.shm_prune_period="0"
	eaccelerator.shm_only="0"
	">>/usr/local/php/etc/php.ini
}

function install_ext_apc()
{
	echo '#==============================================='
	echo '# APC 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep apc`" ]; then
		echo "APC has been installed"
		return
	fi
	if [ ! -f "APC-3.1.9.tgz" ]; then
		wget -c http://pecl.php.net/get/APC-3.1.9.tgz
	fi
	tar zxf APC-3.1.9.tgz
	cd APC-3.1.9
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config --enable-apc --enable-mmap --enable-apc-spinlocks --disable-apc-pthreadmutex
	make && make install
	cd ../
	echo "extension = apc.so">>/usr/local/php/etc/php.ini
}

function install_ext_fastdfs()
{
	echo '#==============================================='
	echo '# FastDFS 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep fastdfs`" ]; then
		echo "FastDFS has been installed"
		return
	fi
	if [ ! -f "FastDFS_v4.06.tar.gz" ]; then
		wget -c http://fastdfs.googlecode.com/files/FastDFS_v4.06.tar.gz
	fi
	tar zxvf FastDFS_v4.06.tar.gz
	cd FastDFS
	./make.sh
	./make.sh install
	cd client
	make && make install
	cd ../php_client/
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	make && make install

	cp ../conf/client.conf /etc/fdfs/
	cat fastdfs_client.ini >> /usr/local/php/etc/php.ini
	cd ../..

	##ndfs服务端安装
	#mkdir /data/fastdfs
	#mkdir /data/images
	#vim /etc/fdfs/tracker.conf
	#base_path=/data/fastdfs

	#vim /etc/fdfs/storage.conf
	#base_path=/data/fastdfs
	#store_path0=/data/images

	#/usr/local/bin/fdfs_trackerd /etc/fdfs/tracker.conf
	#/usr/local/bin/fdfs_storaged /etc/fdfs/storage.conf
}

function install_ext_swoole()
{
	echo '#==============================================='
	echo '# swoole 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep swoole`" ]; then
		echo "swoole has been installed"
		return
	fi

	if [ ! -f "swoole-1.7.7-stable.tar.gz" ]; then
		wget -c https://github.com/swoole/swoole-src/archive/swoole-1.7.7-stable.tar.gz
	fi
	tar zxf swoole-1.7.7-stable.tar.gz
	cd swoole-src-swoole-1.7.7-stable
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config --enable-async-mysql
	make && make install
	cd ../
	echo "extension = swoole.so">>/usr/local/php/etc/php.ini
}

function install_ext_libevent()
{
	echo '#==============================================='
	echo '# libevent 扩展安装'
	echo '#==============================================='
	if [ "`$PHP_BIN -m | grep libevent`" ]; then
		echo "libevent has been installed"
		return
	fi

	#if [ ! -f "libevent-2.0.21-stable.tar.gz" ]; then
	#	wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
	#fi
	#cd libevent-2.0.16-stable
	#./configure
	#make && make install

	if [ ! -f "libevent-0.1.0.tgz" ]; then
		wget -c http://pecl.php.net/get/libevent-0.1.0.tgz
	fi
	tar zxf libevent-0.1.0.tgz
	cd libevent-0.1.0
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	make && make install
	cd ../
	echo "extension = libevent.so">>/usr/local/php/etc/php.ini
}

cat <<EOF 
#==========================================#
  1 install memcache
  2 install memcached
  3 install phpredis
  4 install mongo
  5 install pdo_mysql
  6 install imagick
  7 install yaf
  8 install amqp
  9 install phprabbit
  10 install zendguard
  11 install ketama
  12 install eaccelerator
  13 install apc
  14 install fastdfs
  15 install swoole
#==========================================#
Select your ext(1 | 2 | 3 | ..)
EOF

echo "Input a number: " 
read num 
case $num in   
    1)
        install_ext_memcache
		php_restart
    ;;
    2)
        install_ext_memcached
		php_restart
    ;;
    3)
        install_ext_phpredis
		php_restart
    ;;
    4)
        install_ext_mongo
		php_restart
    ;;
    5)
        install_ext_pdo_mysql
		php_restart
    ;;
    6)
        install_ext_imagick
		php_restart
    ;;
    7)
        install_ext_yaf
		php_restart
    ;;
    8)
        install_ext_amqp
		php_restart
    ;;
    9)
        install_ext_phprabbit
		php_restart
    ;;
    10)
        install_ext_zendguard
		php_restart
    ;;
    11)
        install_ext_ketama
		php_restart
    ;;
    12)
        install_ext_eaccelerator
		php_restart
    ;;
    13)
        install_ext_apc
		php_restart
    ;;
    14)
        install_ext_fastdfs
		php_restart
    ;;
    15)
        install_ext_swoole
		php_restart
    ;;
    16)
        install_ext_libevent
		php_restart
    ;;
    *) 
		echo "Input error"          
		echo "Select your ext(1 | 2 | 3 | ..)"          
;; 
esac 
