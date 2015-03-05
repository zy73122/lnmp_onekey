#!/bin/bash

cur_dir=$(pwd)
#=============================================================
# thrift
#=============================================================
#官网：http://thrift.apache.org/ 
#如果使用PHP操作Hbase，推荐使用Facebook开源出来的thrift，官网是：http://thrift.apache.org/ ，它是一个类似ice的中间件，用于不同系统语言间信息交换

#安装官方文档：http://thrift.apache.org/docs/install/

#安装依赖
yum -y install automake libtool flex bison pkgconfig gcc-c++ boost-devel libevent-devel zlib-devel python-devel ruby-devel perl-CPAN openssl-devel

#下载 & 编译安装
if [ ! -d /usr/local/thrift ]; then

    #安装依赖 Upgrade autoconf/automake/bison
    if [ ! -f autoconf-2.69.tar.gz ]; then
        wget -c http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
    fi
    tar xvf autoconf-2.69.tar.gz
    cd autoconf-2.69
    ./configure --prefix=/usr/local/autoconf-2.69
    make && make install
    cd ..
    
    PATH=/usr/local/autoconf-2.69/bin:$PATH
    
    if [ ! -f automake-1.14.tar.gz ]; then
        wget -c http://ftp.gnu.org/gnu/automake/automake-1.14.tar.gz
    fi
    tar xvf automake-1.14.tar.gz
    cd automake-1.14
    ./configure --prefix=/usr
    make && make install
    cd ..
    
    # 为了支持c++
    if [ ! -f boost_1_55_0.tar.gz ]; then
        wget -c http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz
    fi
    tar xvf boost_1_55_0.tar.gz
    cd boost_1_55_0
    ./bootstrap.sh
    ./b2 install
    cd ..
    #
    
    if [ ! -f thrift-0.9.1.tar.gz ]; then
        wget -c http://apache.dataguru.cn/thrift/0.9.1/thrift-0.9.1.tar.gz
    fi
    tar zxvf thrift-0.9.1.tar.gz
    cd thrift-0.9.1
    ./configure --prefix=/usr/local/thrift
    #./configure --prefix=/usr/hbase/thrift --with-php=/usr/local/php/bin/php 感觉应该用这个
    make && make install
    cd ..
    #'''
    #thrift 0.9.1
    #Building C++ Library ......... : no
    #Building C (GLib) Library .... : yes
    #Building Java Library ........ : no
    #Building C# Library .......... : no
    #Building Python Library ...... : yes
    #Building Ruby Library ........ : no
    #Building Haskell Library ..... : no
    #Building Perl Library ........ : no
    #Building PHP Library ......... : yes
    #Building Erlang Library ...... : yes
    #Building Go Library .......... : no
    #Building D Library ........... : no
    #'''
    
fi
if [ ! -d /usr/local/thrift ]; then
    echo '[FAIL]/usr/local/thrift not found!!!'
    exit
fi

ln -s /usr/local/thrift/bin/thrift /usr/bin
mkdir thrift_test
cd thrift_test

cat >>./hello.thrift<<EOF
namespace php Services.HelloWorld
service HelloWorld
{
    string sayHello(1:string name);
}
EOF

#生成php语言的接口文件  语法：thrift --gen <language> <Thrift filename>
thrift --gen cpp hello.thrift
thrift --gen php hello.thrift
thrift --gen py hello.thrift
#生成的文件位置：./gen-<language>
ls 

# Done

