#!/bin/sh
# sh mysql.sh | tee mysql.log

cur_dir=$(pwd)
path_mysql=/usr/local/mysql

#set mysql root password

	mysqlrootpwd="root"
	echo "Please input the root password of mysql:"
	read -p "(Default password: root):" mysqlrootpwd
	if [ "$mysqlrootpwd" = "" ]; then
		mysqlrootpwd="root"
	fi
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
cd $cur_dir
tar -zxf mysql-5.5.20.tar.gz
cd mysql-5.5.20/
cmake ./ 1>/dev/null
make && make install
cd /usr/local/mysql

chown -R mysql /usr/local/mysql /usr/local/mysql/data
chgrp -R mysql /usr/local/mysql
/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/data/

cp /usr/local/mysql/support-files/my-medium.cnf /etc/my.cnf
sed -i 's/skip-locking/skip-external-locking/g' /etc/my.cnf
/usr/local/mysql/bin/mysqld_safe --user=mysql &

cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chmod 755 /etc/init.d/mysqld

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
ldconfig

ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
ln -s /usr/local/mysql/include/mysql /usr/include/mysql
ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk

/etc/init.d/mysqld start
/usr/local/mysql/bin/mysqladmin -u root password $mysqlrootpwd

chkconfig --level 345 mysqld on
echo "============================mysql intall completed========================="

netstat -tlnp | grep mysql