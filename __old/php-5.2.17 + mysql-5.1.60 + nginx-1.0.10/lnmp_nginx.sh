#!/bin/bash

cur_dir=$(pwd)

#set main domain name

	domain="localhost"
	echo "Please input domain:"
	read -p "(Default domain: localhost):" domain
	if [ "$domain" = "" ]; then
		domain="localhost"
	fi
	echo "==========================="
	echo domain="$domain"
	echo "==========================="
	
	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
	echo ""
	echo "Press any key to start..."
	char=`get_char`


echo "============================nginx install================================="
cd $cur_dir
tar zxvf pcre-8.12.tar.gz
cd pcre-8.12/
./configure
make && make install
cd ../

tar zxvf nginx-1.0.10.tar.gz
cd nginx-1.0.10/
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6
make && make install
cd ../

rm -f /usr/local/nginx/conf/nginx.conf
cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
sed -i 's/www.lnmp.org/'$domain'/g' /usr/local/nginx/conf/nginx.conf
sed -i 's#/home/wwwroot#/web/wwwroot#g' /usr/local/nginx/conf/nginx.conf
sed -i 's#/home/wwwlogs#/web/wwwlogs#g' /usr/local/nginx/conf/nginx.conf

rm -f /usr/local/nginx/conf/fcgi.conf
cp conf/fcgi.conf /usr/local/nginx/conf/fcgi.conf
echo "============================nginx install completed================================="
