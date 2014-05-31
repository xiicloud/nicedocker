#!/bin/sh

echo "docker init beginning ..."

tv=`date +%s`
WDIR=/tmp/docker_$tv
[ -d $WDIR ] || mkdir /tmp/$WDIR

[ -d /nicescale ] || mkdir /nicescale
NICESCALEDIR=/opt/nicescale/support
[ -d $NICESCALEDIR/bin ] || mkdir -p $NICESCALEDIR/bin
#[ -d $NICESCALEDIR/etc ] || mkdir -p $NICESCALEDIR/etc

SERVICE_TYPES="mysql redis redis_cache redis_store memcached apache_php haproxy tomcat"
REPOHOST=nicedocker.com
get_repo() {
  local name
  local region
  if [ -f $CSP_FILE ]; then
    . $CSP_FILE
    echo $region.$name.$REPOHOST
  else
    echo $REPOHOST
  fi
}

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
#/bin/cp nicedocker/nicedocker.ini $NICESCALEDIR/etc/
/bin/cp nicedocker/nsexec $NICESCALEDIR/bin/
chmod 755 $NICESCALEDIR/bin/cgmount.sh
chmod 755 $NICESCALEDIR/bin/nicedocker
chmod 755 $NICESCALEDIR/bin/nsexec
ln -sf $NICESCALEDIR/bin/nicedocker /usr/local/bin/nicedocker
ln -sf $NICESCALEDIR/bin/nicedocker /usr/local/bin/dockernice
ln -sf $NICESCALEDIR/bin/nsexec /usr/local/bin/nsexec

repohost=`get_repo`
for s in $SERVICE_TYPES; do
  docker pull $repohost:5000/nicescale/$s
done

cd /
rm -fr $WDIR
[ $distribution = "Ubuntu" -a $version = "12" ] &&
echo "Ubuntu 12.04 should reboot for new kernel."
echo "docker and images ready now."
#echo rebooting after 10 seconds ....
#sleep 10
#reboot
