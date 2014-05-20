#!/bin/sh

WDIR=/tmp/docker_xywfa
mkdir /tmp/docker_xywfa
mkdir /nicescale
cd $WDIR
apt-get -y install aufs-tools git
wget https://get.docker.io/builds/Linux/x86_64/docker-latest.tgz
tar zxf docker-latest.tgz -C /
git clone https://github.com/NiceScale/nicedocker.git
cp nicedocker/{cgmount.sh,nicedocker,nicedocker.ini} /nicescale/
chmod 755 /nicescale/cgmount.sh
chmod 755 /nicescale/nicedocker
ln -s /nicescale/nicedocker /usr/local/bin/nicedocker
ln -s /nicescale/nicedocker /usr/local/bin/dockernice

# put /nicescale/cgmount.sh to autostart
echo "#!/bin/sh

/nicescale/cgmount.sh
/usr/local/bin/docker -d &
" > /nicescale/docker.init
chmod 755 /nicescale/docker.init
ln -s /nicescale/docker.init /etc/rc{2,3,4,5}.d/S95docker

# put docker daemon to init and upstart/systemd
cat << EOF > /etc/init/docker.conf
description "Docker daemon"

start on filesystem
stop on runlevel [!2345]

respawn

script
  DOCKER=/usr/local/bin/docker
  "$DOCKER" -d &
end script
EOF

rm -fr $WDIR
