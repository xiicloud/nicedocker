#!/bin/sh

WDIR=/tmp/docker_xywfa
[ -d /tmp/docker_xywfa ] || mkdir /tmp/docker_xywfa
[ -d /nicescalen ] || mkdir /nicescale
NICESCALEDIR=/opt/nicescale/support
[ -d $NICESCALEDIR ] || mkdir -p $NICESCALEDIR
[ -d $NICESCALEDIR/bin ] || mkdir -p $NICESCALEDIR/bin
[ -d $NICESCALEDIR/etc ] || mkdir -p $NICESCALEDIR/etc

SERVICE_TYPES="mysql redis redis_cache redis_store memcached apache_php haproxy tomcat"
REPOHOST=repo.nicescale.com

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
  [ ! -f /etc/yum.repos.d/epel.repo ] &&
  wget http://epel.mirror.net.in/epel/6/i386/epel-release-6-8.noarch.rpm &&
  rpm -ivh epel-release-6-8.noarch.rpm
  yum -y install git docker-io
  service docker start
  chkconfig docker on
else
  echo unsupported linux distribution
fi
git clone https://github.com/NiceScale/nicedocker.git
cp nicedocker/cgmount.sh $NICESCALEDIR/bin/
cp nicedocker/nicedocker $NICESCALEDIR/bin/
cp nicedocker/nicedocker.ini $NICESCALEDIR/etc/
chmod 755 $NICESCALEDIR/cgmount.sh
chmod 755 $NICESCALEDIR/nicedocker
ln -s $NICESCALEDIR/nicedocker /usr/local/bin/nicedocker
ln -s $NICESCALEDIR/nicedocker /usr/local/bin/dockernice

for s in $SERVICE_TYPES; do
  docker pull $REPOHOST:5000/$s
done

echo rebooting after 10 seconds ....
sleep 10
reboot
