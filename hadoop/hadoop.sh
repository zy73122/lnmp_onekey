#!/bin/bash
#官网：
#https://github.com/hivefans/phphbaseadmin

cur_dir=$(pwd)

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

