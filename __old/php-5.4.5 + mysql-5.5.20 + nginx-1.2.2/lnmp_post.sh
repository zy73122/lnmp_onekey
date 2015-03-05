#!/bin/sh

cur_dir=$(pwd)

echo "============================add service============================"


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
wwwroot=/data/wwwroot
phpmyadminroot=$wwwroot/_pm
tar zxvf phpMyAdmin-3.4.8-all-languages.tar.gz
mv phpMyAdmin-3.4.8-all-languages $phpmyadminroot/
# cp conf/config.inc.php $phpmyadminroot/config.inc.php
mv $phpmyadminroot/config.sample.inc.php  $phpmyadminroot/config.inc.php
mkdir $phpmyadminroot/upload/
mkdir $phpmyadminroot/save/
chmod 755 -R $phpmyadminroot/
chown nobody:nobody -R $phpmyadminroot/

#$i++;
#$cfg['Servers'][$i]['verbose'] = '100.135:3306';
#$cfg['Servers'][$i]['auth_type'] = 'cookie';
#/* Server parameters */
#$cfg['Servers'][$i]['host'] = '10.10.100.135:3306';
#$cfg['Servers'][$i]['connect_type'] = 'tcp';
#$cfg['Servers'][$i]['compress'] = false;
#/* Select mysqli if your server has it */
#$cfg['Servers'][$i]['extension'] = 'mysql';
#$cfg['Servers'][$i]['AllowNoPassword'] = false;
echo "============================phpMyAdmin install completed================================="

#phpinfo
cat >$wwwroot/phpinfo.php<<eof
<?php
phpinfo();
?>
eof

cat >$wwwroot/ext.php<<eof
<?php
print_r(get_loaded_extensions());
?>
eof

cat >$wwwroot/index.html<<eof
hello!<br>
<a href="ext.php">get_loaded_extensions</a>
<a href="phpinfo.php">phpinfo</a>
<a href="_pm">phpmyadmin</a> 
<a href="status">status_nginx</a>
<a href="status_fpm">status_fpm</a>
<a href="fpm.html">status_fpm</a> 
eof