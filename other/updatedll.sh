#!/bin/bash
# ==========================================
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# =========================================
# Getting
#
cd
# collor status
error1="${RED} [ERROR] ${NC}"
success="${GREEN} [OK] ${NC}"
# ==========================================
# link hosting kalian

wget -O xp "https://raw.githubusercontent.com/anpenohopi/Xray/main/other/xp.sh"
wget -O dns "https://raw.githubusercontent.com/anpenohopi/Xray/main/other/dns.sh"
wget -O certxray "https://raw.githubusercontent.com/anpenohopi/Xray/main/other/certxray.sh"
wget -O xraymod "https://raw.githubusercontent.com/anpenohopi/Xray/main/other/xraymod.sh"
wget -O xrayofficial "https://raw.githubusercontent.com/anpenohopi/Xray/main/other/xrayofficial.sh"

## Chmod Vmess
# update by Surun
## Chmod Other
chmod +x xp
chmod +x dns
chmod +x certxray
chmod +x xraymod
chmod +x xrayofficial
chmod +x about
clear
echo -e "Update Selesai..."
sleep 1
	menu
