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
# yum -y install pcre-devel openssl openssl-devel
wget http://nginx.org/download/nginx-1.4.4.tar.gz
tar zxf nginx-1.4.4.tar.gz
cd nginx-1.4.4
./configure --user=nobody --group=nobody --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6
make && make install
cd ../

mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.old
cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
sed -i 's/localhost/'$domain'/g' /usr/local/nginx/conf/nginx.conf
sed -i 's#/data/wwwroot#/data/wwwroot#g' /usr/local/nginx/conf/nginx.conf
sed -i 's#/data/nginxlogs#/data/nginxlogs#g' /usr/local/nginx/conf/nginx.conf

#mv /usr/local/nginx/conf/fcgi.conf /usr/local/nginx/conf/fcgi.conf.old
#cp conf/fcgi.conf /usr/local/nginx/conf/fcgi.conf

cp init.d.nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx

chkconfig --level 345 nginx on
echo "============================nginx install completed================================="

/etc/init.d/nginx start