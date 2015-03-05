#!/bin/sh
# sh mysql.sh | tee mysql.log

cur_dir=$(pwd)
basedir=/usr/local/mysql
datadir=/data/mysql_data_3306
logdir=/data/mysql_log

if [ -f $basedir ]; then
	echo "MySQL has been install?"
	exit
fi

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
	

echo "============================mysql install=================================="
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
if [ ! -f "mysql-5.6.15.tar.gz" ]; then
	wget http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.15.tar.gz
fi
tar -zxf mysql-5.6.15.tar.gz
cd mysql-5.6.15
rm -f CMakeCache.txt
cmake ./ 1>/dev/null
if [ "$?" -ne "0" ]; then 
	exit
fi
make
if [ "$?" -ne "0" ]; then 
	exit
fi
make install

if [ ! -d $datadir ]; then
	mkdir $datadir
fi
if [ ! -d $logdir ]; then
	mkdir $logdir
fi
chown -R mysql.mysql /usr/local/mysql $datadir $logdir
/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=$basedir --datadir=$datadir
cd $cur_dir

# use default my.cnf
#cp /usr/local/mysql/support-files/my-medium.cnf /etc/my.cnf
#sed -i 's/skip-locking/skip-external-locking/g' /etc/my.cnf
cp conf/my.cnf $datadir
sed -i "s/3308/3306/g" $datadir/my.cnf
#/usr/local/mysql/bin/mysqld_safe --user=mysql &

# use default mysql.server
#cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
cp init.d.mysqld_3308 /etc/init.d/mysqld_3306
sed -i "s/3308/3306/g" /etc/init.d/mysqld_3306
chmod 755 /etc/init.d/mysqld_3306

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
ldconfig

ln -s /usr/local/mysql/lib /usr/lib/mysql
ln -s /usr/local/mysql/include/mysql /usr/include/mysql
ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
# ln -s /tmp/mysql.sock /var/lib/mysql/mysql.sock

chkconfig --level 345 mysqld_3306 on
echo "============================mysql intall completed========================="

echo "===================================== Check install ==================================="
clear
if [ -s /usr/local/mysql ]; then
  echo "/usr/local/mysql [found]"
  else
  echo "Error: /usr/local/mysql not found!!!"
fi

echo "========================== Check install ================================"

echo "Starting MySQL..."
/etc/init.d/mysqld_3306 start

# set password
if [ "$mysqlrootpwd" != "" ]; then
	#/usr/local/mysql/bin/mysqladmin -S/tmp/mysql_3306.sock -uroot -p password $mysqlrootpwd
	echo "grant all on *.* to root@'192.168.%' identified by '$mysqlrootpwd'; flush privileges;" | mysql -S/tmp/mysql_3306.sock -uroot -p
fi

#/usr/local/mysql/bin/my_print_defaults mysqld server mysql_server mysql.server --defaults-file=/data/mysql_data_3306/my.cnf
#/usr/local/mysql/bin/mysqld --basedir=/usr/local/mysql --datadir=/data/mysql_data_3306/ --defaults-file=/data/mysql_data_3306/my.cnf