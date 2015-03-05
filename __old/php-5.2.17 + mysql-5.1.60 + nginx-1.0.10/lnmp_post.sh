#!/bin/sh

cur_dir=$(pwd)

echo "============================add service============================"
cp init.d.nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx

chkconfig --level 345 php-fpm on
chkconfig --level 345 nginx on
chkconfig --level 345 mysql on

echo "Starting LNMP..."
/etc/init.d/mysql start
/etc/init.d/php-fpm start
/etc/init.d/nginx start
echo "===========================add service completed===================="


echo "===================================== Check install ==================================="
clear
if [ -s /usr/local/nginx ]; then
  echo "/usr/local/nginx [found]"
  else
  echo "Error: /usr/local/nginx not found!!!"
fi

if [ -s /usr/local/php ]; then
  echo "/usr/local/php [found]"
  else
  echo "Error: /usr/local/php not found!!!"
fi

if [ -s /usr/local/mysql ]; then
  echo "/usr/local/mysql [found]"
  else
  echo "Error: /usr/local/mysql not found!!!"
fi

echo "========================== Check install ================================"


echo "============================phpMyAdmin install================================="
#phpmyadmin
tar zxvf phpmyadmin-latest.tar.gz
mv phpMyAdmin-3.4.8-all-languages /web/wwwroot/phpmyadmin/
cp conf/config.inc.php /web/wwwroot/phpmyadmin/config.inc.php
sed -i 's/LNMPORG/LNMP.org'$RANDOM'VPSer.net/g' /web/wwwroot/phpmyadmin/config.inc.php
mkdir /web/wwwroot/phpmyadmin/upload/
mkdir /web/wwwroot/phpmyadmin/save/
chmod 755 -R /web/wwwroot/phpmyadmin/
chown www:www -R /web/wwwroot/phpmyadmin/
echo "============================phpMyAdmin install completed================================="

#phpinfo
cat >/web/wwwroot/phpinfo.php<<eof
<?php
phpinfo();
?>
eof

cat >/web/wwwroot/ext.php<<eof
<?php
print_r(get_loaded_extensions());
?>
eof

cat >/web/wwwroot/index.html<<eof
hello!<br>
<a href="ext.php">get_loaded_extensions</a>
<a href="phpinfo.php">phpinfo</a>
eof