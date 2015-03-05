#!/bin/sh
# sh mysql.sh | tee mysql.log

cur_dir=$(pwd)
path_mysql=/usr/local/mysql

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
cd $cur_dir
#多实例
mkdir /data/mysql_data_$mysqlport
cp conf/my.cnf /data/mysql_data_$mysqlport
cp init.d.mysqld_3308 /etc/init.d/mysqld_$mysqlport
chmod +x /etc/init.d/mysqld_$mysqlport
sed -i "s/3308/$mysqlport/g" /etc/init.d/mysqld_$mysqlport

chown -R mysql.mysql /data/mysql_data_$mysqlport
/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql/ --datadir=/data/mysql_data_$mysqlport

#/etc/init.d/mysqld_$mysqlport start
echo "============================mysql intall completed========================="