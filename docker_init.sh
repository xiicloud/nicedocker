#!/bin/sh

WDIR=/tmp/docker_xywfa
mkdir /tmp/docker_xywfa
mkdir /nicescale
cd $WDIR
distribution=`head -1 /etc/issue.net |cut -f1 -d' '`
version=`head -1 /etc/issue.net |cut -f3 -d' '`
if [ "$distribution" = "Ubuntu" ]; then
  apt-get update
  case $version:
    "Trusty")
      apt-get -y install docker.io
      ln -sf /usr/bin/docker.io /usr/local/bin/docker
      ;;
    "Precise")
      apt-get -y install linux-image-generic-lts-raring linux-headers-generic-lts-raring
      [ -e /usr/lib/apt/methods/https ] || {
          apt-get install apt-transport-https
        }
      apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
      echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
      apt-get update
      apt-get -y install lxc-docker
      ;;
    "Raring"|"Saucy")
      apt-get -y install linux-image-extra-`uname -r`
      apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
      echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
      apt-get update
      apt-get -y install lxc-docker
      ;;
    *)
      echo unsupported distribution $version
  esac
  apt-get -y install aufs-tools git
elif [ "$distribution" = "CentOS" ]; then
  [ "$version" < "6.5" ] && echo not supported version && exit 1
  yum -y install aufs-tools git docker-io
  service docker start
  chkconfig docker on
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

echo rebooting after 10 seconds ....
sleep 10
reboot
