#!/bin/sh

WDIR=/tmp/docker_xywfa
mkdir /tmp/docker_xywfa
mkdir /nicescale
cd $WDIR
distribution=`head -1 /etc/issue.net |cut -f1 -d' '`
if [ "$distribution" = "Ubuntu" ]; then
  apt-get -y install aufs-tools git lxc-docker-0.11.1
elif [ "$distribution" = "CentOS" ]; then
  yum -y install aufs-tools git docker.io
else
  echo unsupported linux distribution
fi
git clone https://github.com/NiceScale/nicedocker.git
cp nicedocker/cgmount.sh /nicescale/
cp nicedocker/nicedocker /nicescale/
cp nicedocker/nicedocker.ini /nicescale/
chmod 755 /nicescale/cgmount.sh
chmod 755 /nicescale/nicedocker
ln -s /nicescale/nicedocker /usr/local/bin/nicedocker
ln -s /nicescale/nicedocker /usr/local/bin/dockernice

rm -fr $WDIR
