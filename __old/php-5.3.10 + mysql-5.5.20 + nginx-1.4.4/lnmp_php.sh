#!/bin/bash

cur_dir=$(pwd)

echo "============================php install======================"
#yum install -y mysql-devel

cd $cur_dir
tar zxf php-5.3.10.tar.gz
cd php-5.3.10/
./buildconf --force
#./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --enable-exif --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --enable-exif --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext
make ZEND_EXTRA_LIBS='-liconv'

#for error
#ln -s /usr/local/mysql/lib/libmysqlclient.so /usr/lib/libmysqlclient.so
ldconfig
#cp ext/phar/phar.php ext/phar/phar.phar

make install

mkdir -p /usr/local/php/etc
cp php.ini-development /usr/local/php/etc/php.ini
cd ../

ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize
ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm


# php extensions
sed -i 's#; extension_dir = "./"#extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/"\n#' /usr/local/php/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini


cat >>/usr/local/php/etc/php.ini<<EOF

;test
EOF

# php-fpm
mkdir -p /usr/local/php/logs
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
sed -i 's#;pid = run/php-fpm.pid#pid = /var/run/php-fpm.pid#g' /usr/local/php/etc/php-fpm.conf
sed -i 's#user = nobody#user = nobody#g' /usr/local/php/etc/php-fpm.conf
sed -i 's#group = nobody#group = nobody#g' /usr/local/php/etc/php-fpm.conf
sed -i 's#listen = 127.0.0.1:9000#listen = /tmp/php-cgi.sock#g' /usr/local/php/etc/php-fpm.conf


# enable status
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
sed -i 's#;pm.status_path = /status#pm.status_path = /status_fpm#g' /usr/local/php/etc/php-fpm.conf
sed -i 's#;ping.path = /ping#ping.path = /ping#g' /usr/local/php/etc/php-fpm.conf
sed -i 's#;ping.response = pong#ping.response = pong#g' /usr/local/php/etc/php-fpm.conf
cp /usr/local/php/php/fpm/status.html /data/wwwroot/fpm.html


cp init.d.php-fpm5.3 /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm 

chkconfig --level 345 php-fpm on
echo "============================php+eaccelerator install completed======================"

/etc/init.d/php-fpm start


echo "============================php_ext install======================"
cd $cur_dir

wget http://pecl.php.net/get/memcache-2.2.7.tgz
tar zxf memcache-2.2.7.tgz
cd memcache-2.2.7/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --enable-memcache
make && make install
cd ../

tar zxf libmemcached-1.0.4.tar.gz
cd libmemcached-1.0.4/
#/usr/local/php/bin/phpize
./configure --prefix=/usr/local/libmemcached --with-memcached
make && make install
cd ../

wget http://pecl.php.net/get/memcached-2.1.0.tgz
tar zxf memcached-2.1.0.tgz
cd memcached-2.1.0/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-libmemcached-dir=/usr/local/libmemcached --enable-memcached
make && make install
cd ../

tar zxf mongo-1.2.7.tgz
cd mongo-1.2.7/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --enable-mongo=share
make && make install
cd ../

tar zxf APC-3.1.11.tgz
cd APC-3.1.11/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --enable-apc --enable-mmap --enable-apc-spinlocks --disable-apc-pthreadmutex
make && make install
cd ../

# need 2.63 version autoconf
# cp /usr/local/autoconf-2.63/bin/* /usr/bin/
tar zxf rabbitmq-c.tar.gz
tar zxf rabbitmq-codegen.tar.gz
mv rabbitmq-codegen-c7c5876a05bb/ rabbitmq-c-ce1eaceaee94/codegen
cp -Rf rabbitmq-c-ce1eaceaee94/codegen /codegen
cd rabbitmq-c-ce1eaceaee94/
autoreconf -i && ./configure 
make && make install 
cd ../

tar zxf php-rabbit.r91.tar.gz
cd php-rabbit
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-rabbit
make && make install 
cd ../

tar zxf eaccelerator-eaccelerator-e19b15a.tar.gz
cd eaccelerator-eaccelerator-e19b15a
/usr/local/php/bin/phpize
./configure --enable-shared --with-php-config=/usr/local/php/bin/php-config
make && make install 
cd ../
mkdir /tmp/eaccelerator
chmod 0777 /tmp/eaccelerator

echo "extension = memcache.so">>/usr/local/php/etc/php.ini
echo "extension = memcached.so">>/usr/local/php/etc/php.ini
echo "extension = mongo.so">>/usr/local/php/etc/php.ini
echo "extension = apc.so">>/usr/local/php/etc/php.ini
echo "extension = rabbit.so">>/usr/local/php/etc/php.ini
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


# *.so files in dir: /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/
# php -m | grep rabbit

echo "============================php_ext install completed======================"