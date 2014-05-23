#!/bin/sh

echo "docker init beginning ..."
WDIR=/tmp/docker_xywfa
[ -d /tmp/docker_xywfa ] || mkdir /tmp/docker_xywfa
[ -d /nicescale ] || mkdir /nicescale
NICESCALEDIR=/opt/nicescale/support
RSYNCDIR=/opt/nicescale/service_init
[ -d $NICESCALEDIR ] || mkdir -p $NICESCALEDIR
[ -d $NICESCALEDIR/bin ] || mkdir -p $NICESCALEDIR/bin
[ -d $NICESCALEDIR/etc ] || mkdir -p $NICESCALEDIR/etc
[ -d $RSYNCDIR ] || mkdir -p $RSYNCDIR

SERVICE_TYPES="mysql redis redis_cache redis_store memcached apache_php haproxy tomcat"
REPOHOST=repo.nicescale.com

cd $WDIR
distribution=`head -1 /etc/issue.net |cut -f1 -d' '`
if [ "$distribution" = "Ubuntu" ]; then
  version=`head -1 /etc/issue.net |cut -f2 -d' '`
  version=`echo $version|cut -f1 -d'.'`
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
  echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
  apt-get update
  case $version in
    "14")
      apt-get -y install lxc-docker
      #apt-get -y install docker.io
      #ln -sf /usr/bin/docker.io /usr/local/bin/docker
      service lxc-docker start
      ;;
    "12")
      apt-get -y install linux-image-generic-lts-raring linux-headers-generic-lts-raring
      [ -e /usr/lib/apt/methods/https ] || {
          apt-get install apt-transport-https
        }
      apt-get -y install lxc-docker
      service lxc-docker start
      ;;
    "13")
      apt-get -y install lxc-docker
      service lxc-docker start
      ;;
    *)
      echo unsupported distribution $version
  esac
  apt-get -y install aufs-tools git
elif [ "$distribution" = "CentOS" ]; then
  version=`head -1 /etc/issue.net |cut -f3 -d' '`
  [ `echo $version'>'6.4|bc -l` -eq 0 ] && echo not supported version && exit 1
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
/bin/cp nicedocker/cgmount.sh $NICESCALEDIR/bin/
/bin/cp nicedocker/nicedocker $NICESCALEDIR/bin/
/bin/cp nicedocker/nicedocker.ini $NICESCALEDIR/etc/
chmod 755 $NICESCALEDIR/bin/cgmount.sh
chmod 755 $NICESCALEDIR/bin/nicedocker
ln -sf $NICESCALEDIR/bin/nicedocker /usr/local/bin/nicedocker
ln -sf $NICESCALEDIR/bin/nicedocker /usr/local/bin/dockernice

for s in $SERVICE_TYPES; do
  docker pull $REPOHOST:5000/$s
done

cd $WDIR
wget https://github.com/NiceScale/service_init/archive/latest.tar.gz &&
tar zxf latest.tar.gz &&
cd service_init-latest &&
tar zxf service_init.tgz &&
/bin/mv service_init/* $RSYNCDIR/

cd /
rm -fr $WDIR
echo "docker and images ready now."
[ $distribution = "Ubuntu" -a $version = "Precise" ] &&
echo "Ubuntu 12.04 should reboot for new kernel."
#echo rebooting after 10 seconds ....
#sleep 10
#reboot
