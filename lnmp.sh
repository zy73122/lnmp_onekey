#!/bin/bash

cur_dir=$(pwd)
PHP_VERIOSN=php-5.6.2
MYSQL_VERIOSN=php-5.6.2
NGINX_VERIOSN=nginx-1.6.2
PHPMYADMIN_VERIOSN=phpMyAdmin-4.2.11-all-languages
ROCKMONGO_VERIOSN=rockmongo-1.1.5
#config for mysql
mysql_basedir=/usr/local/mysql
mysql_datadir=/data/mysql_data_3306
mysql_logdir=/data/mysql_log
#config for nginx
nginx_basedir=/usr/local/nginx
#config for php
php_basedir=/usr/local/php
wwwroot=/data/wwwroot
lnmproot=$wwwroot/lnmp
nginxlogs=/data/nginxlogs
#webtools
phpmyadmin_root=$lnmproot/_pm
rockmongo_root=$lnmproot/_rm
phpredis_root=$lnmproot/_pr

#source ./lnmp_nginx.sh

function get_char()
{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
}

function clog()
{
	msg=$1
	echo "######### $msg"
}

function install_pre()
{
	clog "pre install starting.."
	
	# Check if user is root
	if [ $(id -u) != "0" ]; then
		clog "Error: You must be root to run this script, please use root to install lnmp"
		exit 1
	fi

	#Disable SeLinux
	#setenforce 0
	if [ -s /etc/selinux/config ]; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	fi

	#Close some services
	for SERVICES in abrtd acpid auditd avahi-daemon cpuspeed haldaemon mdmonitor messagebus udev-post; do chkconfig ${SERVICES} off; done

	clog "create user/dir"
	if [ ! -d $wwwroot ]; then
		mkdir -p $wwwroot
		chmod +w $wwwroot
		mkdir -p $nginxlogs
		#chmod 777 $nginxlogs
		mkdir -p $lnmproot
		chmod +w $lnmproot

		#groupadd www
		#useradd -s /sbin/nologin -g www www
		chown -R nobody:nobody $wwwroot $lnmproot
	fi

	clog "create user/dir completed"

	clog "dependencies install"
	#autoconf flex file unzip nano gcc-g77
	#for packages in patch make gcc gcc-c++ bison libtool libtool-libs kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal fonts-chinese gettext gettext-devel gmp-devel pspell-devel cmake php-pear pcre-devel;
	#do yum -y install $packages; done
	depends='patch make gcc gcc-c++ bison libtool libtool-libs kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal fonts-chinese gettext gettext-devel gmp-devel pspell-devel cmake php-pear pcre-devel libtool wget man unzip git screen'
	for i in $depends
	do
		installlist=`rpm -qa|grep $i`
		if [ "$installlist" != "" ]; then
			echo "exclude $i"
			continue
		else
			echo "install $i"
			yum install -y $i
		fi
	done
	clog "dependencies install completed"

	clog "dependencies2 install"
	cd $cur_dir

	#errexit
	set -e

	export LD_LIBRARY_PATH=/usr/local/lib;

	#if [ ! -d "/usr/local/autoconf-2.13" ]; then
	#	# php5.3.10 need this version
	#	if [ ! -f "autoconf-2.13.tar.gz" ]; then
	#		wget -c http://down1.chinaunix.net/distfiles/autoconf-2.13.tar.gz
	#	fi
	#	tar -zxf autoconf-2.13.tar.gz
	#	cd autoconf-2.13/
	#	./configure --prefix=/usr/local/autoconf-2.13
	#	make && make install
	#	cd ../
	#fi

	if [ ! -f "/usr/local/lib/libiconv.so" ]; then
		if [ ! -f "libiconv-1.14.tar.gz" ]; then
			wget -c http://down1.chinaunix.net/distfiles/libiconv-1.14.tar.gz
		fi
		tar -zxf libiconv-1.14.tar.gz
		cd libiconv-1.14/
		./configure
		make && make install
		cd ../
	fi

	if [ ! -f "/usr/local/lib/libmcrypt.so" ]; then
		if [ ! -f "libmcrypt-2.5.8.tar.gz" ]; then
			wget -c http://softlayer.dl.sourceforge.net/sourceforge/mcrypt/libmcrypt-2.5.8.tar.gz
		fi
		tar -zxf libmcrypt-2.5.8.tar.gz
		cd libmcrypt-2.5.8/
		./configure
		make && make install
		/sbin/ldconfig
		cd libltdl/
		./configure --enable-ltdl-install
		make && make install
		cd ../../
	fi

	if [ ! -f "/usr/local/lib/libmhash.so" ]; then
		cd $cur_dir
		if [ ! -f "mhash-0.9.9.9.tar.gz" ]; then
			wget -c http://blog.s135.com/soft/linux/nginx_php/mhash/mhash-0.9.9.9.tar.gz
		fi
		tar -zxf mhash-0.9.9.9.tar.gz
		cd mhash-0.9.9.9/
		./configure
		make && make install
		cd ../
	fi

	if [ ! -f "/usr/local/lib/libmcrypt.so" ]; then
		cd $cur_dir
		if [ ! -f "mcrypt-2.6.8.tar.gz" ]; then
			wget -c http://ncu.dl.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz
		fi
		tar -zxf mcrypt-2.6.8.tar.gz
		cd mcrypt-2.6.8/
		./configure
		make && make install
		cd ../
	fi

	if [ ! -f "/usr/local/bin/pcregrep" ]; then
		cd $cur_dir
		if [ ! -f "pcre-8.12.tar.gz" ]; then
			wget -c http://ftp.exim.llorien.org/pcre/pcre-8.12.tar.gz
		fi
		tar -zxf pcre-8.12.tar.gz
		cd pcre-8.12/
		./configure
		make && make install
		cd ../
	fi

	set +e
		
	#
	ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
	ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
	ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
	ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
	ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
	ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
	ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
	ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
	ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1

	if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
		ln -s /usr/lib64/libpng.* /usr/lib/
		ln -s /usr/lib64/libjpeg.* /usr/lib/
	fi

	if [ ! `grep -l "/lib"    '/etc/ld.so.conf'` ]; then
		echo "/lib" >> /etc/ld.so.conf
	fi

	if [ ! `grep -l '/usr/lib'    '/etc/ld.so.conf'` ]; then
		echo "/usr/lib" >> /etc/ld.so.conf
	fi

	if [ -d "/usr/lib64" ] && [ ! `grep -l '/usr/lib64'    '/etc/ld.so.conf'` ]; then
		echo "/usr/lib64" >> /etc/ld.so.conf
	fi

	if [ ! `grep -l '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
		echo "/usr/local/lib" >> /etc/ld.so.conf
	fi
	/sbin/ldconfig
	
	clog "dependencies2 install completed"
	clog "pre install completed"
}

function install_nginx()
{
	if [ -f $nginx_basedir ]; then
		clog "nginx has been installed"
		return
	fi
	
	clog "nginx install starting.."
	
	yum -y install pcre-devel openssl openssl-devel
	if [ ! -f "$NGINX_VERIOSN.tar.gz" ]; then
		wget -c http://nginx.org/download/$NGINX_VERIOSN.tar.gz
	fi
	tar zxf $NGINX_VERIOSN.tar.gz
	cd $NGINX_VERIOSN
	./configure --user=nobody --group=nobody --prefix=$nginx_basedir --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6
	make
	make install
	cd ../

	mv $nginx_basedir/conf/nginx.conf $nginx_basedir/conf/nginx.conf.old
	cp conf/nginx.conf $nginx_basedir/conf/nginx.conf
	#sed -i 's/localhost/'$domain'/g' $nginx_basedir/conf/nginx.conf
	#sed -i 's#/data/wwwroot#/data/wwwroot#g' $nginx_basedir/conf/nginx.conf
	#sed -i 's#/data/nginxlogs#/data/nginxlogs#g' $nginx_basedir/conf/nginx.conf

	#mv $nginx_basedir/conf/fcgi.conf $nginx_basedir/conf/fcgi.conf.old
	#cp conf/fcgi.conf $nginx_basedir/conf/fcgi.conf

	cp init.d.nginx /etc/init.d/nginx
	chmod +x /etc/init.d/nginx

	clear
	if [ ! -s $nginx_basedir ]; then
	  echo "Error: $nginx_basedir not found!!!"
	  exit
	fi
	
	clog "nginx install completed"

	echo "Starting Nginx..."
	chkconfig --level 345 nginx on
	/etc/init.d/nginx start

}

function install_php()
{
	#if [ -d $php_basedir ]; then
		#clog "php has been installed"
		#return
	#fi
	
	clog "php install starting.."
	#yum install -y mysql-devel

	#export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
	#export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader

	#if [ ! -d "$php_basedir" ]; then

		if [ ! -f "$PHP_VERIOSN.tar.gz" ]; then
			wget -c http://cn2.php.net/distributions/$PHP_VERIOSN.tar.gz
		fi
		tar zxf $PHP_VERIOSN.tar.gz
		cd $PHP_VERIOSN/
		./buildconf --force
		#./configure --prefix=$php_basedir --with-config-file-path=$php_basedir/etc --with-mysql=$mysql_basedir --with-mysqli=$mysql_basedir/bin/mysql_config --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --enable-exif --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext
		./configure --prefix=$php_basedir --with-config-file-path=$php_basedir/etc --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-mysqli=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-sysvshm --enable-sysvmsg --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --enable-exif --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --enable-opcache
		make ZEND_EXTRA_LIBS='-liconv'

		#for error
		#ln -s $mysql_basedir/lib/libmysqlclient.so /usr/lib/libmysqlclient.so
		ldconfig
		#cp ext/phar/phar.php ext/phar/phar.phar

		make install
		cd ..
		
		#Services
		cp init.d.php-fpm5.3 /etc/init.d/php-fpm
		chmod +x /etc/init.d/php-fpm 
		chkconfig --level 345 php-fpm on
	#fi

	###### config php
	if [ ! -d "$php_basedir/etc" ]; then
		mkdir -p $php_basedir/etc
	fi
	cp $PHP_VERIOSN/php.ini-development $php_basedir/etc/php.ini

	#ln -s $php_basedir/bin/php /usr/bin/php
	#ln -s $php_basedir/bin/phpize /usr/bin/phpize
	#ln -s $php_basedir/sbin/php-fpm /usr/bin/php-fpm

	##### php extensions
	#sed -i 's#; extension_dir = "./"#extension_dir = "$php_basedir/lib/php/extensions/no-debug-non-zts-20090626/"\n#' $php_basedir/etc/php.ini
	sed -i 's/post_max_size = 8M/post_max_size = 50M/g' $php_basedir/etc/php.ini
	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' $php_basedir/etc/php.ini
	sed -i 's/;date.timezone =/date.timezone = PRC/g' $php_basedir/etc/php.ini
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' $php_basedir/etc/php.ini
	sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' $php_basedir/etc/php.ini
	sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $php_basedir/etc/php.ini
	#opcache
	cat >>$php_basedir/etc/php.ini<<EOF
[opcache]
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=2
opcache.fast_shutdown=1
opcache.enable_cli=1
zend_extension = opcache.so
EOF

	##### config php-fpm
	mkdir -p $php_basedir/logs
	cp $php_basedir/etc/php-fpm.conf.default $php_basedir/etc/php-fpm.conf
	sed -i 's#;pid = run/php-fpm.pid#pid = /var/run/php-fpm.pid#g' $php_basedir/etc/php-fpm.conf
	sed -i 's#user = nobody#user = nobody#g' $php_basedir/etc/php-fpm.conf
	sed -i 's#group = nobody#group = nobody#g' $php_basedir/etc/php-fpm.conf
	#sed -i 's#listen = 127.0.0.1:9000#listen = /tmp/php-cgi.sock#g' $php_basedir/etc/php-fpm.conf


	###### enable status
	# example: http://192.168.1.155/status_fpm
	# vi nginx.conf
	# location ~ ^/(status_fpm|ping)$ {
	# include fastcgi_params;
	# fastcgi_pass 127.0.0.1:9000;
	# fastcgi_param SCRIPT_FILENAME $fastcgi_script_name;
	# #allow 127.0.0.1;
	# #allow your.localdomain;
	# #deny all;
	# }
	sed -i 's#;pm.status_path = /status#pm.status_path = /status_fpm#g' $php_basedir/etc/php-fpm.conf
	sed -i 's#;ping.path = /ping#ping.path = /ping#g' $php_basedir/etc/php-fpm.conf
	sed -i 's#;ping.response = pong#ping.response = pong#g' $php_basedir/etc/php-fpm.conf
	cp $php_basedir/php/fpm/status.html $wwwroot/fpm.html

	# *.so files in dir: /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/
	# php -m | grep rabbit
	
	clog "php install completed"
	
	clear
	if [ ! -s $php_basedir ]; then
	  echo "Error: $php_basedir not found!!!"
	  exit
	fi
	
	echo "Starting PHP..."
	chkconfig --level 345 php-fpm on
	/etc/init.d/php-fpm start
}

function install_mysql()
{
	if [ -d $mysql_basedir ]; then
		clog "MySQL has been installed"
		return
	fi
	
	clog "MySQL install starting.."

	# add user
	groupadd mysql
	useradd -s /sbin/nologin -M -g mysql mysql

	#set mysql root password
	mysqlrootpwd=""
	echo "Please input the root password of mysql:"
	read -p "(Default password: root):" mysqlrootpwd
	echo "==========================="
	echo mysqlrootpwd="$mysqlrootpwd"
	echo "==========================="
	
	echo ""
	echo "Press any key to start..."
	char=`get_char`
		
	# pre depends install
	depends='gcc gcc-c++ cmake make ncurses ncurses-devel'
	for i in $depends
	do
		installlist=`rpm -qa|grep $i`
		if [ "$installlist" != "" ]; then
			echo "exclude $i"
			continue
		else
			echo "install $i"
			yum install -y $i
		fi
	done

	# MySQL install
	cd $cur_dir
	if [ ! -f "mysql-5.6.21.tar.gz" ]; then
		#wget -c http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.15.tar.gz
		wget -c http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.21.tar.gz
	fi
	tar -zxf mysql-5.6.21.tar.gz
	cd mysql-5.6.21
	rm -f CMakeCache.txt
	cmake ./ 1>/dev/null
	make && make install

	if [ ! -d $mysql_datadir ]; then
		mkdir $mysql_datadir
	fi
	if [ ! -d $mysql_logdir ]; then
		mkdir $mysql_logdir
	fi
	chown -R mysql.mysql $mysql_basedir $mysql_datadir $mysql_logdir
	$mysql_basedir/scripts/mysql_install_db --user=mysql --basedir=$mysql_basedir --datadir=$mysql_datadir
	cd $cur_dir

	# use default my.cnf
	#cp $mysql_basedir/support-files/my-medium.cnf /etc/my.cnf
	#sed -i 's/skip-locking/skip-external-locking/g' /etc/my.cnf
	cp conf/my.cnf $mysql_datadir
	sed -i "s/3308/3306/g" $mysql_datadir/my.cnf
	#$mysql_basedir/bin/mysqld_safe --user=mysql &

	# use default mysql.server
	#cp $mysql_basedir/support-files/mysql.server /etc/init.d/mysqld
	cp init.d.mysqld_3308 /etc/init.d/mysqld_3306
	sed -i "s/3308/3306/g" /etc/init.d/mysqld_3306
	chmod 755 /etc/init.d/mysqld_3306

	cat > /etc/ld.so.conf.d/mysql.conf<<EOF
$mysql_basedir/lib
/usr/local/lib
EOF
	ldconfig

	ln -s $mysql_basedir/lib /usr/lib/mysql
	ln -s $mysql_basedir/include/mysql /usr/include/mysql
	ln -s $mysql_basedir/bin/mysql /usr/bin/mysql
	ln -s $mysql_basedir/bin/mysqldump /usr/bin/mysqldump
	ln -s $mysql_basedir/bin/myisamchk /usr/bin/myisamchk
	# ln -s /tmp/mysql.sock /var/lib/mysql/mysql.sock

	clog "MySQL install completed"
	
	clear
	if [ ! -s $mysql_basedir ]; then
	  clog "Error: $mysql_basedir not found!!!"
	  exit
	fi
	
	clog "Starting MySQL..."
	chkconfig --level 345 mysqld_3306 on
	/etc/init.d/mysqld_3306 start

	# set password
	if [ "$mysqlrootpwd" != "" ]; then
		#$mysql_basedir/bin/mysqladmin -S/tmp/mysql_3306.sock -uroot -p password $mysqlrootpwd
		echo "grant all on *.* to root@'192.168.%' identified by '$mysqlrootpwd'; flush privileges;" | mysql -S/tmp/mysql_3306.sock -uroot -p
	fi
	
	#$mysql_basedir/bin/my_print_defaults mysqld server mysql_server mysql.server --defaults-file=/data/mysql_data_3306/my.cnf
	#$mysql_basedir/bin/mysqld --basedir=$mysql_basedir --datadir=/data/mysql_data_3306/ --defaults-file=/data/mysql_data_3306/my.cnf
}

function install_mysql_anyport()
{
	if [ -d $mysql_basedir ]; then
		clog "MySQL $mysqlport has been installed"
		return
	fi
	
	clog "MySQL $mysqlport install starting.."
	
	#set mysql root password
	mysqlport=""
	echo "Please input the port of mysql:"
	read -p "(Default port: root):" mysqlport
	if [ "$mysqlrootpwd" = "" ]; then
		echo "port not empty"
	fi
	echo "==========================="
	echo mysqlport="$mysqlport"
	echo "==========================="
	
	echo ""
	echo "Press any key to start..."
	char=`get_char`
		
	cd $cur_dir
	#多实例
	mkdir /data/mysql_data_$mysqlport
	cp conf/my.cnf /data/mysql_data_$mysqlport
	cp init.d.mysqld_3308 /etc/init.d/mysqld_$mysqlport
	chmod +x /etc/init.d/mysqld_$mysqlport
	sed -i "s/3308/$mysqlport/g" /etc/init.d/mysqld_$mysqlport

	chown -R mysql.mysql /data/mysql_data_$mysqlport
	$mysql_basedir/scripts/mysql_install_db --user=mysql --basedir=$mysql_basedir --datadir=/data/mysql_data_$mysqlport

	clog "MySQL $mysqlport install complete"
	
	clog "Starting MySQL $mysqlport..."
	#chkconfig --level 345 mysqld_$mysqlport on
	/etc/init.d/mysqld_$mysqlport start
}

function install_phpMyAdmin()
{
	if [ -d $phpmyadmin_root ]; then
		clog "phpMyAdmin has been installed"
		return
	fi
	
	clog "phpMyAdmin install starting.."

	if [ ! -f "$PHPMYADMIN_VERIOSN.tar.gz" ]; then
		wget -c http://jaist.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.2.11/$PHPMYADMIN_VERIOSN.tar.gz
	fi
	
	tar zxvf $PHPMYADMIN_VERIOSN.tar.gz
	mv $PHPMYADMIN_VERIOSN $phpmyadmin_root
	# cp conf/config.inc.php $phpmyadmin_root/config.inc.php
	mv $phpmyadmin_root/config.sample.inc.php  $phpmyadmin_root/config.inc.php
	mkdir $phpmyadmin_root/upload/
	mkdir $phpmyadmin_root/save/
	chmod 755 -R $phpmyadmin_root/
	chown nobody:nobody -R $phpmyadmin_root/

	#$i++;
	#$cfg['Servers'][$i]['verbose'] = '100.135:3306';
	#$cfg['Servers'][$i]['auth_type'] = 'cookie';
	#/* Server parameters */
	#$cfg['Servers'][$i]['host'] = '10.10.100.135:3306';
	#$cfg['Servers'][$i]['connect_type'] = 'tcp';
	#$cfg['Servers'][$i]['compress'] = false;
	#/* Select mysqli if your server has it */
	#$cfg['Servers'][$i]['extension'] = 'mysql';
	#$cfg['Servers'][$i]['AllowNoPassword'] = false;

	clog "phpMyAdmin install complete"
	
}

function install_rockmongo()
{
	if [ -d $rockmongo_root ]; then
		clog "rockmongo has been installed"
		return
	fi
	
	clog "rockmongo install starting.."
		
	if [ ! -d "$rockmongo_root" ]; then
		if [ ! -f "$ROCKMONGO_VERIOSN.zip" ]; then
			wget http://rockmongo.com/release/$ROCKMONGO_VERIOSN.zip
		fi
		unzip $ROCKMONGO_VERIOSN.zip
		mv rockmongo $rockmongo_root
	fi

	clog "rockmongo install complete"
}

function install_phpredis()
{
	if [ -d $phpredis_root ]; then
		clog "phpredis has been installed"
		return
	fi
	
	clog "phpredis install starting.."
	
	env GIT_SSL_NO_VERIFY=true git clone https://github.com/ErikDubbelboer/phpRedisAdmin.git
	mv phpRedisAdmin $phpredis_root
	#wget https://github.com/ErikDubbelboer/phpRedisAdmin/archive/master.zip --no-check-certificate 
	#unzip master
	#mv phpRedisAdmin-master predis
	cd $phpredis_root
	env GIT_SSL_NO_VERIFY=true git clone https://github.com/nrk/predis.git vendor

	cp includes/config.sample.inc.php includes/config.inc.php

	clog "phpredis install complete"
}

function install_webtools()
{
	install_phpMyAdmin
	install_rockmongo
	install_phpredis
	
	#phpinfo
	cat >$wwwroot/phpinfo.php<<eof
<?php
phpinfo();
?>
eof

	cat >$wwwroot/ext.php<<eof
<?php
print_r(get_loaded_extensions());
?>
eof

	cat >$wwwroot/index.html<<eof
hello!<br>
<a href="ext.php">get_loaded_extensions</a>
<a href="phpinfo.php">phpinfo</a>
<a href="fpm.html">status_fpm</a> 
<a href="../status">status_nginx</a>
<a href="../status_fpm">status_fpm</a>
<a href="_pm">phpmyadmin</a> 
<a href="_rm">rockmongo</a> 
<a href="_pr">phpredis</a> 
eof

}

cd $cur_dir
	
cat <<EOF 
#==========================================#
  1 install Pre
  2 install Nginx
  3 install PHP 
  4 install MySQL 
  5 install MySQL Any Port
  6 install LNMP 
  7 install webtools(phpMyAdmin,rockmongo,phpredis)
#==========================================#
Select your service(1 | 2 | 3 | 4 | 5 | 6)
EOF

echo "Input a number: " 
read num 
case $num in
    1)
		install_pre
    ;;
    2)
		install_nginx
    ;;
    3)
        install_php
    ;;
    4)
        install_mysql
    ;;
    5)
        install_mysql_anyport
    ;;
    6)
		install_pre
		install_nginx
        install_php
        install_mysql
    ;;
    7)
        install_webtools
    ;;
	
    *) 
		echo "Input error"          
		echo "Select your service(1 | 2 | 3 | 4 | 5 | 6)"          
;; 
esac 

