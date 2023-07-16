NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
echo -e " Dengan Nama Allah Yang Maha Pemurah Lagi Maha Pengasih "
sleep 1
xray_service=$(systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
nginx_service=$(systemctl status nginx | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $xray_service == "running" ]]; then
status_xray="${GB}[ ON ]${NC}"
else
status_xray="${RB}[ OFF ]${NC}"
fi
if [[ $nginx_service == "running" ]]; then
status_nginx="${GB}[ ON ]${NC}"
else
status_nginx="${RB}[ OFF ]${NC}"
fi
# Download
#Download/Upload today
dtoday="$(vnstat -i eth0 | grep "today" | awk '{print $2" "substr ($3, 1, 1)}')"
utoday="$(vnstat -i eth0 | grep "today" | awk '{print $5" "substr ($6, 1, 1)}')"
ttoday="$(vnstat -i eth0 | grep "today" | awk '{print $8" "substr ($9, 1, 1)}')"
#Download/Upload yesterday
dyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $2" "substr ($3, 1, 1)}')"
uyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $5" "substr ($6, 1, 1)}')"
tyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $8" "substr ($9, 1, 1)}')"
#Download/Upload current month
dmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $3" "substr ($4, 1, 1)}')"
umon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $6" "substr ($7, 1, 1)}')"
tmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $9" "substr ($10, 1, 1)}')"
domain=$(cat /usr/local/etc/xray/domain)
domain1=$(cat /var/lib/dnsvps.conf)
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
WKT=$(cat /usr/local/etc/xray/timezone)
DATE=$(date -R | cut -d " " -f -4)
MYIP=$(curl -sS ipv4.icanhazip.com)
clear
#########################
# Color Validation
DF='\e[39m'
Bold='\e[1m'
Blink='\e[5m'
yell='\e[33m'
red='\e[31m'
green='\e[32m'
blue='\e[34m'
PURPLE='\e[35m'
cyan='\e[36m'
Lred='\e[91m'
Lgreen='\e[92m'
Lyellow='\e[93m'
NC='\e[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
LIGHT='\033[0;37m'
# VPS Information
#Domain
#Status certificate
modifyTime=$(stat $HOME/.acme.sh/${domain}_ecc/${domain}.key | sed -n '7,6p' | awk '{print $2" "$3" "$4" "$5}')
modifyTime1=$(date +%s -d "${modifyTime}")
currentTime=$(date +%s)
stampDiff=$(expr ${currentTime} - ${modifyTime1})
days=$(expr ${stampDiff} / 86400)
remainingDays=$(expr 90 - ${days})
tlsStatus=${remainingDays}
if [[ ${remainingDays} -le 0 ]]; then
	tlsStatus="expired"
fi
# OS Uptime
uptime="$(uptime -p | cut -d " " -f 2-10)"
# Download
#Download/Upload today
dtoday="$(vnstat -i eth0 | grep "today" | awk '{print $2" "substr ($3, 1, 1)}')"
utoday="$(vnstat -i eth0 | grep "today" | awk '{print $5" "substr ($6, 1, 1)}')"
ttoday="$(vnstat -i eth0 | grep "today" | awk '{print $8" "substr ($9, 1, 1)}')"
#Download/Upload yesterday
dyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $2" "substr ($3, 1, 1)}')"
uyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $5" "substr ($6, 1, 1)}')"
tyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $8" "substr ($9, 1, 1)}')"
#Download/Upload current month
dmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $3" "substr ($4, 1, 1)}')"
umon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $6" "substr ($7, 1, 1)}')"
tmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $9" "substr ($10, 1, 1)}')"
# Getting CPU Information
cpu_usage1="$(ps aux | awk 'BEGIN {sum=0} {sum+=$3}; END {print sum}')"
cpu_usage="$((${cpu_usage1/\.*} / ${corediilik:-1}))"
cpu_usage+=" %"
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )
CITY=$(curl -s ipinfo.io/city )
WKT=$(curl -s ipinfo.io/timezone )
DAY=$(date +%A)
DATE=$(date +%m/%d/%Y)
IPVPS=$(curl -s ipinfo.io/ip )
cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
tram=$( free -m | awk 'NR==2 {print $2}' )
uram=$( free -m | awk 'NR==2 {print $3}' )
fram=$( free -m | awk 'NR==2 {print $4}' )
clear 
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e ""
echo -e "        ${WB}━━━━━ [ XRAY MultiPORT/Dynamic Path] ━━━━━${NC}       "
echo -e ""
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "\e[33m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\e[92m  _____   ______  _   _   ____   _    _   ____   _____  "
echo -e "\e[92m |  __ \ |  ____|| \ | | / __ \ | |  | | / __ \ |  __ \ "
echo -e "\e[92m | |__) || |__   |  \| || |  | || |__| || |  | || |__) |"
echo -e "\e[92m |  ___/ |  __|  | . | || |  | ||  __  || |  | ||  ___/ "
echo -e "\e[92m | |     | |____ | |\  || |__| || |  | || |__| || |     "
echo -e "\e[92m |_|     |______||_| \_| \____/ |_|  |_| \____/ |_|     "
echo -e "\e[33m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " "                                  
echo -e "\e[33m CPU Model            \e[0m: $cname"
echo -e "\e[33m CPU Frequency        \e[0m: $freq MHz"
echo -e "\e[33m Number Of Cores      \e[0m:  $cores"
echo -e "\e[33m CPU Usage            \e[0m:  $cpu_usage"
echo -e "\e[33m Operating System     \e[0m:  "`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`	
echo -e "\e[33m Kernel               \e[0m:  `uname -r`"
echo -e "\e[33m Total Amount Of RAM  \e[0m:  $tram MB"
echo -e "\e[33m Used RAM             \e[0m:$red  $uram\e[0m MB"
echo -e "\e[33m System Uptime        \e[0m:  $uptime "
echo -e "\e[33m Domain cfront        \e[0m:  $domain"	
echo -e "\e[33m Domain               \e[0m:  $domain1"	
echo -e "\e[33m Ip Vps               \e[0m:  $IPVPS"	
echo -e "\e[33m Date                 \e[0m:  $DATE"
echo -e "\e[33m Script Version       \e[0m:  Freemium"
echo -e "\e[33m Certificate status   \e[0m:  \e[33mExpired in ${tlsStatus} days\e[0m"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "     ${WB}NGINX STATUS :${NC} $status_nginx    ${WB}XRAY STATUS :${NC} $status_xray   "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "          ${WB}━━━━━ [ Bandwidth Monitoring ] ━━━━━${NC}"
echo -e ""
echo -e "\e[33m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\e[33m Traffic\e[0m       \e[33mToday      Yesterday     Month   "
echo -e "\e[33m Download\e[0m      $dtoday    $dyest       $dmon   \e[0m"
echo -e "\e[33m Upload\e[0m        $utoday    $uyest       $umon   \e[0m"
echo -e "\e[33m Total\e[0m       \033[0;36m  $ttoday    $tyest       $tmon  \e[0m "
echo -e "\e[33m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "                ${WB}━━━━━ [ Xray Menu ] ━━━━━${NC}               "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e " ${MB}[•1]${NC} ${YB}Vmess Menu${NC}            ${MB}[•5]${NC} ${YB}APN Menu Setting${NC}"
echo -e " ${MB}[•2]${NC} ${YB}Vless Menu${NC}            ${MB}[•6]${NC} ${YB}Backup Vps Menu${NC}"
echo -e " ${MB}[•3]${NC} ${YB}Trojan Menu${NC}           ${MB}[•7]${NC} ${YB}Restore Vps Menu${NC}"
echo -e " ${MB}[•4]${NC} ${YB}All Xray Menu${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "                 ${WB}━━━━━ [ System ] ━━━━━${NC}                "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e " ${MB}[•8]${NC} ${YB}Restart service${NC}       ${MB}[12]${NC} ${YB}About Script${NC} "
echo -e " ${MB}[•9]${NC} ${YB}Speedtest${NC}             ${MB}[13]${NC} ${YB}Kernel Update${NC}"
echo -e " ${MB}[10]${NC} ${YB}Change Domain${NC}         ${MB}[14]${NC} ${YB}Install BBR${NC}"
echo -e " ${MB}[11]${NC} ${YB}Renew Certificate${NC}     ${MB}[15]${NC} ${YB}Reboot vps${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "                 ${WB}━━━━━ [ Add ON ] ━━━━━${NC}                "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e " ${MB}[16]${NC} ${YB}Install Ads Block${NC}     ${MB}[17]${NC} ${YB}Ads Block Panel${NC}"
echo -e " ${MB}[18]${NC} ${YB}DNS Changer${NC}           ${MB}[19]${NC} ${YB}Streaming Checker${NC}"
echo -e " ${MB}[20]${NC} ${YB}Clear Log${NC}             ${MB}[21]${NC} ${YB}Change Xray-core Mod${NC}"
echo -e " ${MB}[22]${NC} ${YB}WARP+${NC}                 ${MB}[23]${NC} ${YB}Change Xray-core Official${NC} "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e ""
echo -e " ${WB}Press [ ctrl + c ] or Input x To Exit Script${NC}"
echo -e ""
read -p " Select Menu :  "  opt
echo -e ""
case $opt in
1) clear ; vmess ;;
2) clear ; vless ;;
3) clear ; trojan ;;
4) clear ; allxray ;;
5) clear ; apn ;;
6) clear ; backup ;;
7) clear ; restore ;;
8) clear ; restart ;;
9) clear ; speedtest ;;
10) clear ; dns ;;
11) clear ; certxray ;;
12) clear ; about ;;
13) clear ; kernel-updt ;;
14) clear ; bbr ;;
15) clear ; reboot ;;
16) clear ; ins-helium ;;
17) clear ; helium ;;
18) clear ; dnss ;;
19) clear ; nf ;;
20) clear ; clear-log ;;
21) clear ; xraymod ;;
22) clear ; warpy ;;
23) clear ; xrayofficial ;;
x) exit ;;
*) echo -e "wrong number" ; sleep 0.5 ; menu ;;
esac
