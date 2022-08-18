#!/bin/bash
EnterNodeID(){
        read -p "Enter NodeID:" NODEID
        if [ -z $NODEID ];then
                echo "ENTER NODEID!"
                exit
        fi
}

GetCertificate(){
        read -p "Enter your domain to get certificate [domain.com]:" domain
        if [ -z $domain ];then
                echo "INPUT DOMAIN!"
                exit
        fi
        curl -fsSL https://github.com/mikucloud/tj/raw/master/sign.sh | bash -s $domain
}

Trojan(){
        if ls /root/.cert | grep "key" > /dev/null
                then
                read -p "cert exist, do you want change? [y/N]:" input
                case $input in
                        [yY][eE][sS]|[yY])
                                GetCertificate
                                ;;
                        *)
                                echo "There will be no change to the certificate files."
                                ;;
                esac
        else
                GetCertificate
        fi
        echo "trojan starting..."
        docker run -d --name=trojan_node_$NODEID \
        -v /root/.cert:/root/.cert \
        -e API=$1 \
        -e TOKEN=$2 \
        -e NODE=$NODEID \
        -e LICENSE=NULL \
        -e SYNCINTERVAL=60 \
        --restart=always \
        --network=host \
        mikucloud/tidalab:1.2
}

V2Ray(){
        if ls /root/.cert | grep "key" > /dev/null
                then
                read -p "cert exist, do you want change? [y/N]:" input
                case $input in
                        [yY][eE][sS]|[yY])
                                echo "Yes"
                                GetCertificate
                                ;;
                        *)
                                echo "There will be no change to the certificate files."
                                ;;
                esac
        else
                read -p "Cert don't exist, do you want Use TLS? [y/N]:" input
                case $input in
                        [yY][eE][sS]|[yY])
                                GetCertificate
                                ;;
                        *)
                                echo "There will be no change to the certificate files."
                                ;;
                esac
        fi
        echo "v2ray starting..."
        docker run -d --name=aurora_node_$NODEID \
        -v /root/.cert:/root/.cert \
        -e API=$1 \
        -e TOKEN=$2 \
        -e NODE=$NODEID \
        -e LICENSE=NULL \
        -e SYNCINTERVAL=60 \
        --restart=always \
        --network=host \
        mikucloud/aurora
}

SS(){
        echo "ss here."
        docker run -d --name=ss_node_$NODEID \
        -v /root/.cert:/root/.cert \
        -e API=$1 \
        -e TOKEN=$2 \
        -e NODE=$NODEID \
        -e LICENSE=NULL \
        -e SYNCINTERVAL=60 \
        --restart=always \
        --network=host \
        mikucloud/ss:1.1
}

echo "                                   "
echo "       _ _           _           _ "
echo " _____|_| |_ _ _ ___| |___ _ _ _| |"
echo "|     | | '_| | |  _| | . | | | . |"
echo "|_|_|_|_|_,_|___|___|_|___|___|___|"
echo "                                   "
echo
echo "Preparing :) ..."
apt-get update
apt-get install unzip wget curl -y > /dev/null
apt-get install -y ntp
service ntp restart
systemctl disable firewalld
systemctl stop firewalld
docker -v
if [ $? -eq  0 ]; then
        echo "Docker installed."
else
        echo "Install docker..."
        curl -fsSL https://get.docker.com | bash
        systemctl start docker
        service docker start
        systemctl enable docker.service
fi


echo "Select :
0. Trojan
1. V2Ray
2. SS
3. Gen Cert
4. BBRplus
"

read -p " 请输入数字 [0]:" num
num=${num:-0}
case "$num" in
        0)
        EnterNodeID
        Trojan
        ;;
        1)
        EnterNodeID
        V2Ray
        ;;
        2)
        EnterNodeID
        Ss
        ;;
        3)
        GetCertificate
        ;;
        *)
        echo "Unknown Error."
        ;;
esac
