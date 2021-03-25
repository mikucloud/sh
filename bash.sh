#!/bin/sh
echo "                                   "
echo "       _ _           _           _ "
echo " _____|_| |_ _ _ ___| |___ _ _ _| |"
echo "|     | | '_| | |  _| | . | | | . |"
echo "|_|_|_|_|_,_|___|___|_|___|___|___|"
echo "                                   "

echo 'Start ...'
if cat /etc/os-release | grep "centos" > /dev/null
    then
    yum install unzip wget curl -y > /dev/null
    yum update curl -y
    yum -y install ntpdate
    timedatectl set-timezone Asia/Shanghai
    ntpdate ntp1.aliyun.com
else
    apt-get install unzip wget curl -y > /dev/null
    apt-get update curl -y
    apt-get install -y ntp
    service ntp restart
fi

echo 'disable firewalld ...'
systemctl disable firewalld
systemctl stop firewalld

echo 'install docker ...'
curl -fsSL https://get.docker.com | bash

#echo 'install docker-compose ...'
#curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#chmod a+x /usr/local/bin/docker-compose
#rm -f `which dc`
#ln -s /usr/local/bin/docker-compose /usr/bin/dc

systemctl start docker
service docker start
systemctl enable docker.service
#systemctl status docker.service

echo 'start aurora ...'
docker run -d --name=aurora \
-v /root/.cert:/root/.cert \
-e API=$1 \
-e TOKEN=$2 \
-e NODE=$3 \
-e LICENSE=$4 \
-e SYNCINTERVAL=60 \
--restart=always \
--network=host \
mikucloud/aurora

echo 'install competed.'
