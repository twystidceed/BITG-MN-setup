#!/bin/bash
# Twystid's Masternode Setup Script V3.0 for Ubuntu 16.04 LTS
#
# Script will attempt to auto detect primary public IP address
# This script is capable of installing with or without swap depending on your VPS
# Usage:
# bash bare-setup.sh 
#

#Color codes
RED='\033[0;91m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

#TCP port
PORT=27003
RPC=27004

#GLOBAL VARIABLES - Check the daemon deployment section for proper deployment
#this is the Github Source for the binaries
SOURCE='https://github.com/BareCrypto/bare-core/releases/download/v1.1.0.3/BARE_v1.1.0.3_ubuntu16_deamon.tar.gz'

#The archive itself from the source
ARCHIVE=BARE_v1.1.0.3_ubuntu16_deamon.tar.gz

#name of the folder created with the git clone when clonign the repository
FOLDER=BARE-MN-setup

#official name
NAME='Bare'

#name2 is the actual name of the binary when installed on VPS [CASE SENSISTIVE]
NAME2=bare

#Simply the Ticker of the coin for referenceing in the script - no usage case not sensitive
TICKER=BARE

#actual name of the hidden folder for the coin [CASE SENSITIVE]
HIDDEN=.bare

#Actual name of the conf file in the hidden folder [CASE SENSITIVE]
CONF=bare.conf

#actual name od the coin daemon [CASE SENSITIVE]
DAEMON=bared

#Actual name of the coin daemon -cli [CASE SENSITIVE]
CLI=bare-cli

#name of the monitor script [CASE SENSITIVE]
MONITOR=baremon.sh

#only enable if needed due to binaries being extracted to a second folder within the cloned folder
#FOLDER2=qyno-2.0.0/

#Clear keyboard input buffer
function clear_stdin { while read -r -t 0; do read -r; done; }

#Delay script execution for N seconds
function delay { echo -e "${GREEN}Sleep for $1 seconds...${NC}"; sleep "$1"; }

#Stop daemon if it's already running
function stop_daemon {
    if pgrep -x $DAEMON > /dev/null; then
        echo -e "${YELLOW}Attempting to stop $DAEMON${NC}"
        $CLI stop
        delay 30
        if pgrep -x $DAEMON > /dev/null; then
            echo -e "${RED}$DAEMON daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            pkill -9 $DAEMON
            delay 30
            if pgrep -x $DAEMON > /dev/null; then
                echo -e "${RED}Can't stop $DAEMON! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}

#Function detect_ubuntu

 if [[ $(lsb_release -d) == *16.04* ]]; then
   UBUNTU_VERSION=16
else
   echo -e "${RED}You are not running Ubuntu 16.04, Installation is cancelled.${NC}"
   exit 1

fi


#Process command line parameters
genkey=$1

clear
echo -e "${PURPLE}####### #     # #     #  #####  ####### ### ######  ${NC}"
echo -e "${PURPLE}   #    #  #  #  #   #  #     #    #     #  #     # ${NC}"
echo -e "${PURPLE}   #    #  #  #   # #   #          #     #  #     # ${NC}"
echo -e "${PURPLE}   #    #  #  #    #     #####     #     #  #     # ${NC}"
echo -e "${PURPLE}   #    #  #  #    #          #    #     #  #     # ${NC}"
echo -e "${PURPLE}   #    #  #  #    #    #     #    #     #  #     # ${NC}"
echo -e "${PURPLE}   #     ## ##     #     #####     #    ### ######  ${NC}"
echo -e
echo -e "${PURPLE}      #     # ### #     # ### #     #  #####  ${NC}"
echo -e "${PURPLE}      ##   ##  #  ##    #  #  ##    # #     # ${NC}"
echo -e "${PURPLE}      # # # #  #  # #   #  #  # #   # #       ${NC}"
echo -e "${PURPLE}      #  #  #  #  #  #  #  #  #  #  # #  #### ${NC}"
echo -e "${PURPLE}      #     #  #  #   # #  #  #   # # #     # ${NC}"
echo -e "${PURPLE}      #     #  #  #    ##  #  #    ## #     # ${NC}"
echo -e "${PURPLE}      #     # ### #     # ### #     #  #####  ${NC}"
echo -e
echo -e "${GREEN}$NAME Masternode Setup Script V3 for Ubuntu 16.04 LTS${NC}"
echo -e
echo -e 
sleep 3


genkey=$3
#Enter the new BLS genkey
clear
echo -e "${YELLOW}AXE Coin DIP003 Masternode Setup Script V2 for Ubuntu 16.04 LTS${NC}"
	read -e -p "Enter your BLS key:" genkey3;
              read -e -p "Confirm your BLS key: " genkey4;

#Confirming match
  if [ $genkey3 = $genkey4 ]; then
     echo -e "${GREEN}MATCH! ${NC} \a" 
else 
     echo -e "${RED} Error: BLS key do not match. Try again...${NC} \a";exit 1
fi
sleep .5
clear

# Determine primary public IP address
dpkg -s dnsutils 2>/dev/null >/dev/null || sudo apt-get -y install dnsutils
publicip=$(dig +short myip.opendns.com @resolver1.opendns.com)

if [ -n "$publicip" ]; then
    echo -e "${YELLOW}IP Address detected:" $publicip ${NC}
else
    echo -e "${RED}ERROR: Public IP Address was not detected!${NC} \a"
    clear_stdin
    read -e -p "Enter VPS Public IP Address: " publicip
    if [ -z "$publicip" ]; then
        echo -e "${RED}ERROR: Public IP Address must be provided. Try again...${NC} \a"
        exit 1
    fi
fi
#Check Deps
if [ -d "/var/lib/fail2ban/" ]; 
then
    echo -e "${GREEN}Dependencies already installed...${NC}"
else
    echo -e "${GREEN}Updating system and installing required packages...${NC}"

sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y autoremove
sudo apt-get -y install wget nano htop jq
sudo apt-get -y install libzmq3-dev
sudo apt-get -y install libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
sudo apt-get -y install libevent-dev
sudo apt-get instal unzip
sudo apt -y install software-properties-common
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get -y update
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev
sudo apt-get install unzip
sudo apt-get -y install libminiupnpc-dev
sudo apt-get -y install fail2ban
sudo service fail2ban restart
sudo apt-get install -y libdb5.3++-dev libdb++-dev libdb5.3-dev libdb-dev && ldconfig
sudo apt-get install -y unzip libzmq3-dev build-essential libssl-dev libboost-all-dev libqrencode-dev libminiupnpc-dev libboost-system1.58.0 libboost1.58-all-dev libdb4.8++ libdb4.8 libdb4.8-dev libdb4.8++-dev libevent-pthreads-2.0-5
   fi

#Network Settings
echo -e "${GREEN}Installing Network Settings...${NC}"
{
sudo apt-get install ufw -y
} &> /dev/null
echo -ne '[##                 ]  (10%)\r'
{
sudo apt-get update -y
} &> /dev/null
echo -ne '[######             ] (30%)\r'
{
sudo ufw default deny incoming
} &> /dev/null
echo -ne '[#########          ] (50%)\r'
{
sudo ufw default allow outgoing
sudo ufw allow ssh
} &> /dev/null
echo -ne '[###########        ] (60%)\r'
{
sudo ufw allow $PORT/tcp
sudo ufw allow $RPC/tcp
sudo ufw allow 9936/tcp
} &> /dev/null
echo -ne '[###############    ] (80%)\r'
{
sudo ufw allow 22/tcp
sudo ufw limit 22/tcp
} &> /dev/null
echo -ne '[#################  ] (90%)\r'
{
echo -e "${YELLOW}"
sudo ufw --force enable
echo -e "${NC}"
} &> /dev/null
echo -ne '[###################] (100%)\n'

#Generating Random Password for axed JSON RPC
rpcuser=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

#Create 2GB swap file
#if grep -q "SwapTotal" /proc/meminfo; then
if grep -q "swapfile" /etc/fstab; then
    echo -e "${GREEN}Skipping disk swap configuration...${NC} \n"
else
    echo -e "${YELLOW}Creating 2GB disk swap file. \nThis may take a few minutes!${NC} \a"
    touch /var/swap.img
    chmod 600 /var/swap.img
    dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
    mkswap /var/swap.img 2> /dev/null
    swapon /var/swap.img 2> /dev/null
    if [ $? -eq 0 ]; then
        echo '/var/swap.img none swap sw 0 0' >> /etc/fstab
        echo -e "${GREEN}Swap was created successfully!${NC} \n"
    else
        echo -e "${RED}Operation not permitted! Optional swap was not created.${NC} \a"
        rm /var/swap.img
    fi
fi

#Installing Daemon
 cd ~
wget https://github.com/AXErunners/axe/releases/download/v1.4.1/axecore-1.4.1-x86_64-linux-gnu.tar.gz
tar -xzf axecore-1.4.1-x86_64-linux-gnu.tar.gz -C ~/AXE-MN-setup
rm -rf axecore-1.4.1-x86_64-linux-gnu.tar.gz

stop_daemon
 
 # Deploy binaries to /usr/bin
 sudo rm ~/AXE-MN-setup/axecore-1.4.1/bin/axe-qt
 sudo rm ~/AXE-MN-setup/axecore-1.4.1/bin/test*
 sudo cp ~/AXE-MN-setup/axecore-1.4.1/bin/axe* /usr/bin/
 sudo chmod 755 -R ~/AXE-MN-setup
 sudo chmod 755 /usr/bin/axe*
 
 # Deploy masternode monitoring script
 cp ~/AXE-MN-setup/axemon.sh /usr/local/bin
 sudo chmod 711 /usr/local/bin/axemon.sh
 
 #Create axe datadir
 if [ ! -f ~/.axecore/axe.conf ]; then 
 	sudo mkdir ~/.axecore
 fi

echo -e "${YELLOW}Creating axe.conf...${NC}"


cat <<EOF > ~/.axecore/axe.conf
rpcuser=$rpcuser
rpcpassword=$rpcpassword
EOF

    sudo chmod 755 -R ~/.axecore/axe.conf

    #Starting daemon first time
    axed -daemon
echo -ne '[##                 ] (15%)\r'
sleep 6
echo -ne '[######             ] (30%)\r'
sleep 9
echo -ne '[########           ] (45%)\r'
sleep 6
echo -ne '[############       ] (67%)\r'
sleep 9
echo -ne '[################   ] (72%)\r'
sleep 10
echo -ne '[###################] (100%)\r'
echo -ne '\n'
    
    #Stopping daemon to create axe.conf
    stop_daemon

# Create axe.conf
cat <<EOF > ~/.axecore/axe.conf
rpcuser=$rpcuser
rpcpassword=$rpcpassword
rpcport=$RPC
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logintimestamps=1
maxconnections=10
externalip=$publicip:$PORT
masternode=1
masternodeblsprivkey=$genkey3
EOF

#Finally, starting axe daemon with new axe.conf
axed -daemon
echo -ne '[##                 ] (15%)\r'
sleep 10
echo -ne '[######             ] (30%)\r'
sleep 5
echo -ne '[########           ] (45%)\r'
sleep 5
echo -ne '[##############     ] (72%)\r'
sleep 10
echo -ne '[###################] (100%)\r'
axe-cli addnode 198.13.50.26:9937 onetry
echo -ne '\n'

#Install Sentinel 
echo -e "${YELLOW}Installing sentinel...${NC}"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get -y install python-pip
sudo apt-get -y install virtualenv
      cd ~/.axecore
	  git clone https://github.com/AXErunners/sentinel.git

    cd ~/.axecore/sentinel
      virtualenv venv
      ./venv/bin/pip install -r requirements.txt
      ./venv/bin/python bin/sentinel.py
    chmod -R 755 database
    cd
    crontab -l > sentinelcron
    echo "* * * * * cd /root/.axecore/sentinel && ./venv/bin/python bin/sentinel.py 2>&1 >> sentinel-cron.log" >> sentinelcron

crontab sentinelcron
rm sentinelcron

#Setting auto start cron job for axed
cronjob="@reboot sleep 30 && axed -daemon"
crontab -l > tempcron
if ! grep -q "$cronjob" tempcron; then
    echo -e "${GREEN}Configuring crontab job...${NC}"
    echo $cronjob >> tempcron
    crontab tempcron
fi
rm tempcron

echo -e "========================================================================
${YELLOW}Masternode setup is complete!${NC}
========================================================================
Masternode was installed with VPS IP Address: ${YELLOW}$publicip${NC}
Masternode BLS Key: ${YELLOW}$genkey3${NC}
======================================================================== \a"

clear_stdin
read -p "*** Press any key to continue ***" -n1 -s

echo -e "1) Wait for the node wallet on this VPS to sync with the other nodes
on the network. Eventually the status 'WAITING_FOR_PROTX' status will change
to display the ProTx details such as the 'ownerAddress' and other information 
from the initial setup of the transactions, which will indicate a comlete sync, 
although it may take several minutes to several hours depending on the network state.
Your initial Masternode Status may read:
    ${YELLOW}Waiting for ProTx to appear on-chain${NC}, which is normal and expected.
2) Wait at least until 'IsBlockchainSynced' status becomes 'true'. The state of the masternode
status should update to read 'READY'. This indicates complete sync and proper setup.
At this point you should not have to do any additional steps.
Currently your masternode is syncing with the AXE network...
The following screen will display in real-time
the list of peer connections, the status of your masternode,
node synchronization status and additional network and node stats.
"
clear_stdin
read -p "*** Press any key to continue ***" -n1 -s

echo -e "
========================================================================
To view masternode configuration produced by this script in axe.conf:
${YELLOW}cat ~/.axecore/axe.conf${NC}
Here is your axe.conf generated by this script:
-------------------------------------------------${YELLOW}"
cat ~/.axecore/axe.conf
echo -e "${NC}-------------------------------------------------
NOTE: To edit axe.conf, first stop the axed daemon,
then edit the axe.conf file and save it in nano: (Ctrl-X + Y + Enter),
then start the axed daemon back up:
             to stop:   ${YELLOW}axe-cli stop${NC}
             to edit:   ${YELLOW}axe ~/.axecore/axe.conf${NC}
             to start:  ${YELLOW}axed${NC}
========================================================================
To view AXE debug log showing all MN network activity in realtime:
             ${YELLOW}tail -f ~/.axecore/debug.log${NC}
========================================================================
To monitor system resource utilization and running processes:
                   ${YELLOW}htop${NC}
========================================================================
To view the list of peer connections, status of your masternode, 
sync status etc. in real-time, run the axemon.sh script:
                 ${YELLOW}axemon.sh${NC}
or just type 'node' and hit <TAB> to autocomplete script name.
========================================================================
Enjoy your AXE Masternode and thanks for using this setup script!

If you found this script useful, please donate to : 
${GREEN}no donations at this time ${NC}
...and make sure to check back for updates!
"
delay 30
# Run axemon.sh
axemon.sh

# EOF
