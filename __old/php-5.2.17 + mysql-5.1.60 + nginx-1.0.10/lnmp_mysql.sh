#!/bin/bash
# sh mysql.sh | tee mysql.log

cur_dir=$(pwd)

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
tar -zxvf mysql-5.1.60.tar.gz
cd mysql-5.1.60/
./configure --prefix=/usr/local/mysql --with-extra-charsets=all --enable-thread-safe-client --enable-assembler --with-charset=utf8 --enable-thread-safe-client --with-extra-charsets=all --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile
make && make install
cd ../

#chown -R mysql:mysql /usr/local/mysql
/usr/local/mysql/bin/mysql_install_db --user=mysql --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/var/

cp /usr/local/mysql/share/mysql/my-medium.cnf /etc/my.cnf
sed -i 's/skip-locking/skip-external-locking/g' /etc/my.cnf
/usr/local/mysql/bin/mysql_install_db --user=mysql
chown -R mysql /usr/local/mysql/var
chgrp -R mysql /usr/local/mysql/.
cp /usr/local/mysql/share/mysql/mysql.server /etc/init.d/mysql
chmod 755 /etc/init.d/mysql

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib/mysql
/usr/local/lib
EOF
ldconfig

ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
ln -s /usr/local/mysql/include/mysql /usr/include/mysql
/etc/init.d/mysql start

ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk

/usr/local/mysql/bin/mysqladmin -u root password $mysqlrootpwd

/etc/init.d/mysql restart
echo "============================mysql intall completed========================="

netstat -tlnp | grep mysql
/etc/init.d/mysql stop