#!/bin/bash

function docker_install { #add docker repo, install docker
    apt update
    apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    apt update
    apt-cache policy docker-ce
    apt install -y docker-ce
}

function systemctl_install { # download service file, start
    cd /etc/systemd/system/
    curl -fsSL "http://end2end.network/install/mqttproxy.service" | sed -e "s~\${FOLDER}~$FOLDER~" > mqttproxy.service
    cd $FOLDER
    systemctl daemon-reload
    if [ "$AUTOSTART" = 1 ]; then
        printf "Adding to autostart\n"
        systemctl enable mqttproxy
    elif [ ! "$QUIET" = 1 ]; then
        read -p "Add to autostart? [yN]" -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            systemctl enable mqttproxy
	    printf "\nService is in /etc/systemctl/system/mqttproxy.service\n"
        fi
    fi
    printf "Starting\n"
    systemctl start mqttproxy
}




if [ ! "$EUID" =  0 ]; then
    printf "Please run as root\n"
  exit
fi


FOLDER=/opt/mqttproxy
OPTS=$(getopt -o 'f:qhisa' -l 'interval::' --name "$0" -- "$@")
if [ $? != 0 ] ; then echo "Failed to parse options...exiting."; exit 1 ; fi

while true ; do
  case "$1" in
    -f)FOLDER="$2"
       shift 2;;
    -h)printf "
-f -- install folder
\n-h -- this message\
\n-q -- quiet, doesn't install docker or systemctl service\
\n-i -- install docker, don't ask\
\n-s -- install systemctl service file\
\n-a -- add systemctl service to autostart \n"
       shift
       exit;;
    -q)QUIET=1
       shift;;
    -i)INSTALL=1
       shift;;
    -s)SYSTEMCTL=1
       shift;;
    -a)AUTOSTART=1
       shift;;
    --interval)
       INTERVAL="$2"
       shift;;
    --ban_attempts)
       BAN_ATTEMPTS="$2"
       shift;;
    --ban_time)
       BAN_TIME="$2"
       shift;;
    --ban_find_interval)
       BAN_FIND_INTERVAL="$2"
       shift;;
    --)shift
       break;;
    * )echo "Internal error!"
       exit 1;;
  esac
done



mkdir -p $FOLDER
cd $FOLDER
printf "Installing in $FOLDER\n"

if [ "$INSTALL" = 1 ]; then
    docker_install
elif [ ! "$QUIET" = 1 ]; then
    read -p "Install Docker? [yN]" -n 1 -r
    echo
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        docker_install    
    fi
fi

if ! command -v docker &> /dev/null
then
    printf "docker could not be found\n"
    exit
fi
DOCKER=$(command -v docker)

printenv | grep "INTERVAL\|BAN_ATTEMPTS\|BAN_TIME\|BAN_INTERVAL" > ./env

if command -v systemctl &> /dev/null 
then
    if [ "$SYSTEMCTL" = 1 ]; then
        systemctl_install
    elif [ ! "$QUIET" = 1 ]; then
        read -p "Add systemctl service? [yN]" -n 1 -r
        echo
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
            systemctl_install
        fi
    fi
else
    printf "No systemctl\n"
fi

printf "docker stop mqttproxy;
$DOCKER pull niksaysit/mqttproxy;
$DOCKER run --rm \\
--name=mqttproxy \\
-p 2022:22 \\
-v $FOLDER/keys/:/opt/keys/ \\
-v $FOLDER/ag/work/:/opt/adguardhome/work/ \\
-v $FOLDER/ag/conf/:/opt/adguardhome/conf/ \\
--env-file ./env \\
--cap-add=NET_ADMIN \\
niksaysit/mqttproxy" > ./mqttproxy.sh
printf "Launcher is in $FOLDER/mqttproxy.sh" 
printf "\n"
