#!/bin/bash

cur_dir=$(pwd)
#=============================================================
# python2.7
#=============================================================
# system packages
yum -y install python-devel openssl openssl-devel gcc sqlite sqlite-devel mysql-devel libxml2-devel libxslt-devel

# Python
if [ ! -e /usr/bin/python2.7 ]; then
	if [ ! -f Python-2.7.6.tgz ]; then
		wget https://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz --no-check-certificate
	fi
	tar zxf Python-2.7.6.tgz
	cd Python-2.7.6
	./configure --prefix=/usr/local/python2.7 --with-threads --enable-shared
	make && make install
	ln -s /usr/local/python2.7/lib/libpython2.7.so /usr/lib
	ln -s /usr/local/python2.7/lib/libpython2.7.so.1.0 /usr/lib
	ln -s /usr/local/python2.7/bin/python2.7 /usr/bin
	ln -s /usr/bin/python2.7 /usr/bin/python27
	echo "/usr/local/python2.7/lib" >> /etc/ld.so.conf.d/python2.7.conf
	/sbin/ldconfig
	#/sbin/ldconfig -v
fi
if [ ! -e /usr/bin/python2.7 ]; then
	echo '[FAIL]/usr/bin/python2.7 not found!!!'
	exit
fi

# easyinstall and pip
if [ ! -f distribute-0.6.49.tar.gz ]; then
	wget http://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz --no-check-certificate
fi
tar zxf distribute-0.6.49.tar.gz
cd distribute-0.6.49
/usr/local/python2.7 setup.py install
easy_install pip
# ln -s /usr/local/python2.7/bin/pip /usr/bin


# preinstall packages
pip install mysql-python ipython requests readline beautifulsoup4 html5lib
ln -s /usr/local/python2.7/bin/ipython /usr/bin

#wget https://github.com/zagfai/webtul/archive/v0.31.zip
#unzip v0.31
#cd webtul-0.31 && sudo python setup.py install


##### simplejson install
#if [ ! -f "simplejson-2.3.1.tar.gz" ]; then
#	wget http://mirrors.tuna.tsinghua.edu.cn/pypi/packages/source/s/simplejson/simplejson-2.3.1.tar.gz
#fi
#tar zxf simplejson-2.3.1.tar.gz
#cd simplejson-2.3.1
#python setup.py install
#if [ $? -eq 0 ]; then exit; fi
#cd ..


#### python-networkx
#/usr/local/python2.7/bin/easy_install setuptools
#/usr/local/python2.7/bin/easy_install networkx


#### Image Library£¨PIL£©
#wget http://zlib.net/zlib-1.2.8.tar.gz
#tar zxvf zlib-1.2.8.tar.gz
#cd zlib-1.2.8
#./configure
#make && make install
#pip install PIL --allow-external PIL --allow-unverified PIL


# Done
python2.7 -V
