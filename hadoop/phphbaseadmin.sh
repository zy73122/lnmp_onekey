#!/bin/bash
#官网：
#https://github.com/hivefans/phphbaseadmin

cur_dir=$(pwd)

# check python2.7 is intalled
if [ ! -e /usr/bin/python2.7 ]; then
	sh python2.7.sh | tee logs/python2.7.log
fi

#=============================================================
# phphbaseadmin
#=============================================================
#需要安装hbase,thrift，可以参考phphbaseadmin/README.md
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	platform=http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
else
	platform=http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
fi
rpm -Uvh $platform

#git install
if [ ! -e /usr/local/bin/git ]; then
	yum install curl curl-devel zlib-devel openssl-devel perl cpio expat-devel gettext-devel -y
	if [ ! -f "git-1.9.0.tar.gz" ]; then
		wget -c http://git-core.googlecode.com/files/git-1.9.0.tar.gz
	fi
	tar zxvf git-1.9.0.tar.gz
	cd git-1.9.0
	autoconf
	./configure
	make
	make install
fi
#git --version

#(1) 下载，安装
if [ ! -d "/data/wwwroot/phphbaseadmin" ]; then
	git clone https://github.com/hivefans/phphbaseadmin.git
	if [ $? -ne 0 ]; then
		echo '[FAIL]git clone https://github.com/hivefans/phphbaseadmin.git'
		exit
	fi
	mv phphbaseadmin /data/wwwroot/
fi
cd /data/wwwroot/phphbaseadmin/cherrypy
#安装python模块 setuptools
sh setuptools-0.6c11-py2.6.egg 
#安装python包管理工具 pip
tar zxvf pip-1.4.1.tar.gz
cd pip-1.4.1
python27 setup.py install
if [ $? -ne 0 ]; then
	echo '[FAIL]cd pip-1.4.1 && python27 setup.py install'
	exit
fi
#安装python模块 kazoo.client
pip install kazoo
if [ $? -ne 0 ]; then
	echo '[FAIL]pip install kazoo'
	exit
fi
cd ..
tar zxvf CherryPy-3.2.2.tar.gz
cd CherryPy-3.2.2
python27 setup.py install 
if [ $? -ne 0 ]; then
	echo '[FAIL]cd CherryPy-3.2.2 && python27 setup.py install '
	exit
fi
cd ..
echo "Install Finished"
python27 zookeeperadmin.py start
echo "Starting zookeeperadmin.py listen on 2080"
#检查端口2080是否启用

#(2) 启动hbase thrift server （注意端口60010, 9090是否正常开启）
#(3) 修改根目录中的配置文件 config.inc.php,修改$configure['hbase_host']=你的thrift server服务器地址
#(4) 在mysql server中创建数据库phphbaseadmin ,导入database/phphbaseadmin.sql文件，修改application/config/database.php,$db['default']['hostname']、 $db['default']['username'] 、$db['default']['password'] = '';<br>
#(5) 打开浏览器访问 http://serverip/phphbaseadmin，缺省用户名admin 密码admin888登录<br>
#(6) 登录后选择 system->user manager 菜单设置用户所属hbase table表的所属权限<br>
#(7) 选择 Tables->view 菜单即可查看hbase table 记录。
