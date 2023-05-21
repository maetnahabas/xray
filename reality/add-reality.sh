NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
clear
domain=$(cat /usr/local/etc/xray/domain)
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                  ${WB}Add reality Account${NC}                 "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -rp "User: " -e user
CLIENT_EXISTS=$(grep -w $user /usr/local/etc/xray/config.json | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                  Add reality Account                 "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "${YB}A client with the specified name was already created, please choose another name.${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
add-reality
fi
done
uuid=$(cat /proc/sys/kernel/random/uuid)
xtls_flow="xtls-rprx-vision"
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#reality$/a\#= '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#reality-grpc$/a\#= '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
realitylink1="reality://$uuid@$domain:443?flow=$xtls_flow&security=tls&sni=$domain#$user" 
realitylink2="reality://$uuid@$domain:80?flow=$xtls_flow&security=tls&sni=$domain#$user" 
cat > /var/www/html/reality/reality-$user.txt << END

Link reality Account
==========================
Link 443   : reality://$uuid@$domain:443?flow=$xtls_flow&security=tls&sni=$domain#$user
==========================
Link 80 : reality://$uuid@$domain:80?flow=$xtls_flow&security=tls&sni=$domain#$user
==========================
END
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
systemctl restart xray
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-reality-$user.txt
echo -e "                  Reality Account                   " | tee -a /user/log-reality-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-reality-$user.txt

echo -e "Format Clash  : http://$domain:8000/reality/reality-$user.txt" | tee -a /user/log-reality-$user.txt
echo -e "=========================" | tee -a /user/log-reality-$user.txt
echo -e "Link 443    : ${realitylink1}" | tee -a /user/log-reality-$user.txt
echo -e "========================="| tee -a /user/log-reality-$user.txt
echo -e "Link 80 : ${realitylink2}" | tee -a /user/log-reality-$user.txt
echo -e "========================="| tee -a /user/log-reality-$user.txt
echo -e "========================="| tee -a /user/log-reality-$user.txt
echo "Script Mod By surun"| tee -a /user/log-reality-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-reality-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-reality-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-reality-$user.txt
echo " " | tee -a /user/log-reality-$user.txt
echo " " | tee -a /user/log-reality-$user.txt
echo " " | tee -a /user/log-reality-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
reality
