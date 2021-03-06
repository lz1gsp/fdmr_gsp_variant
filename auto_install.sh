#!/bin/bash
#
###  HBmonitor2  ###
apt update &&
apt upgrade -y &&
cd /opt &&
apt install git -y &&
git clone https://github.com/sp2ong/HBMonv2.git &&
cd HBMonv2 &&
git checkout webserver-python &&
chmod +x install.sh &&
./install.sh &&
cp config_SAMPLE.py config.py &&
# edit config.py and change what you necessary
cp utils/hbmon.service /lib/systemd/system/ &&
cp /opt/HBMonv2/log/hbmon-empty.log /opt/HBMonv2/log/hbmon.log &&
# monitor.py 
systemctl enable hbmon &&
#systemctl start hbmon
#systemctl status hbmon
###  FreeDMR Server
cd &&
apt-get install docker.io -y &&
apt update &&
#apt-get update --fix-missing
#reboot
apt-get install docker-compose -y &&
#reboot
apt purge needrestart -y &&
apt-get install conntrack  &&
echo '{ "userland-proxy": false}' > /etc/docker/daemon.json &&
systemctl restart docker &&
#systemctl status docker
mkdir /etc/freedmr &&
chmod 755 /etc/freedmr &&
mkdir -p /etc/freedmr/json &&
cd /etc/freedmr/json &&
curl http://downloads.freedmr.uk/downloads/local_subscriber_ids.json -o subscriber_ids.json &&
curl http://downloads.freedmr.uk/downloads/talkgroup_ids.json -o talkgroup_ids.json &&
curl https://www.radioid.net/static/rptrs.json -o peer_ids.json &&
touch /etc/freedmr/json/sub_map.pkl &&
chmod -R 777 /etc/freedmr/json &&
cat << EOF > /etc/freedmr/freedmr.cfg
[GLOBAL]
PATH: ./
PING_TIME: 10
MAX_MISSED: 3
USE_ACL: True
REG_ACL: DENY:0-100000
SUB_ACL: DENY:0-100000
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL
GEN_STAT_BRIDGES: True
ALLOW_NULL_PASSPHRASE: True
ANNOUNCEMENT_LANGUAGES:
SERVER_ID: 0
DATA_GATEWAY: False

[REPORTS]
REPORT: True
REPORT_INTERVAL: 10
REPORT_PORT: 4321
REPORT_CLIENTS: *

[LOGGER]
LOG_FILE: freedmr.log
LOG_HANDLERS: file-timed,console-timed
LOG_LEVEL: DEBUG
LOG_NAME: FreeDMR

[ALIASES]
TRY_DOWNLOAD: False
PATH: ./
PEER_FILE: peer_ids.json
SUBSCRIBER_FILE: subscriber_ids.json
TGID_FILE: talkgroup_ids.json
PEER_URL: https://www.radioid.net/static/rptrs.json
SUBSCRIBER_URL: http://downloads.freedmr.uk/downloads/local_subscriber_ids.json
TGID_URL: TGID_URL: http://downloads.freedmr.uk/downloads/talkgroup_ids.json
STALE_DAYS: 7
SUB_MAP_FILE: sub_map.pkl

[MYSQL]
USE_MYSQL: False
USER: hblink
PASS: mypassword
DB: hblink
SERVER: 127.0.0.1
PORT: 3306
TABLE: repeaters

[OBP-TEST]
MODE: OPENBRIDGE
ENABLED: False
IP:
PORT: 62044
NETWORK_ID: 1
PASSPHRASE: mypass
TARGET_IP: 
TARGET_PORT: 62044
USE_ACL: True
SUB_ACL: DENY:1
TGID_ACL: PERMIT:ALL
RELAX_CHECKS: True
ENHANCED_OBP: True
PROTO_VER: 3

[SYSTEM]
MODE: MASTER
ENABLED: True
REPEAT: True
MAX_PEERS: 1
EXPORT_AMBE: False
IP: 127.0.0.1
PORT: 54000
PASSPHRASE:
GROUP_HANGTIME: 5
USE_ACL: True
REG_ACL: DENY:1
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL
DEFAULT_UA_TIMER: 10
SINGLE_MODE: True
VOICE_IDENT: True
TS1_STATIC:
TS2_STATIC:
DEFAULT_REFLECTOR: 0
ANNOUNCEMENT_LANGUAGE: en_GB
GENERATOR: 100

[ECHO]
MODE: PEER
ENABLED: True
LOOSE: False
EXPORT_AMBE: False
IP: 127.0.0.1
PORT: 54916
MASTER_IP: 127.0.0.1
MASTER_PORT: 54915
PASSPHRASE: passw0rd
CALLSIGN: ECHO
RADIO_ID: 1000001
RX_FREQ: 449000000
TX_FREQ: 444000000
TX_POWER: 25
COLORCODE: 1
SLOTS: 1
LATITUDE: 00.0000
LONGITUDE: 000.0000
HEIGHT: 0
LOCATION: Earth
DESCRIPTION: ECHO
URL: www.freedmr.uk
SOFTWARE_ID: 20170620
PACKAGE_ID: MMDVM_FreeDMR
GROUP_HANGTIME: 5
OPTIONS:
USE_ACL: True
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL
ANNOUNCEMENT_LANGUAGE: en_GB
EOF
echo "BRIDGES = {'9990': [{'SYSTEM': 'ECHO', 'TS': 2, 'TGID': 9990, 'ACTIVE': True, 'TIMEOUT': 2, 'TO_TYPE': 'NONE', 'ON': [], 'OFF': [], 'RESET': []},]}" > /etc/freedmr/rules.py &&

chown -R 54000 /etc/freedmr &&
mkdir -p /var/log/freedmr &&
touch /var/log/freedmr/freedmr.log &&
chown -R 54000 /var/log/freedmr &&
mkdir -p /var/log/FreeDMRmonitor &&
touch /var/log/FreeDMRmonitor/lastheard.log &&
touch /var/log/FreeDMRmonitor/hbmon.log &&
chown -R 54001 /var/log/FreeDMRmonitor &&
cd /etc/freedmr &&

curl https://raw.githubusercontent.com/lz1gsp/fdmr_gsp_variant/main/docker-compose.yml -o docker-compose.yml &&

echo Run FreeDMR container...
docker-compose up -d

echo FreeDMR setup complete!

