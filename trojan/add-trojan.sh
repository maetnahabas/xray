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
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                  ${WB}Add Trojan Account${NC}                "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -rp "User: " -e user
user_EXISTS=$(grep -w $user /usr/local/etc/xray/config.json | wc -l)
if [[ ${user_EXISTS} == '1' ]]; then
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                  ${WB}Add Trojan Account${NC}                "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "${YB}A client with the specified name was already created, please choose another name.${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
add-trojan
fi
done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#trojan$/a\#& '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#trojan-grpc$/a\#& '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
trojanlink1="trojan://$uuid@$domain:443?path=/trojan&security=tls&host=$domain&type=ws&sni=$domain#$user"
trojanlink2="trojan://${uuid}@$domain:80?path=/trojan&security=none&host=$domain&type=ws#$user"
trojanlink4="trojan://${uuid}@cdn.who.int:80?path=/trojan&security=none&host=cdn.who.int.$domain&type=ws#$user"
trojanlink3="trojan://${uuid}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=trojan-grpc&sni=$domain#$user"
trojanlink4="trojan://${uuid}@cdn.who.int:80?path=/trojan&security=none&host=cdn.who.int.$domain&type=ws#$user"
trojanlink5="trojan://${uuid}@api.useinsider.com:80?path=/trojan&security=none&host=$domain&type=ws#$user"
trojanlink6="trojan://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=trojan-grpc&sni=open.spotify.com#${user}"
trojanlink7="trojan://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=trojan-grpc&sni=playtv.unifi.com.my#${user}"
trojanlink8="trojan://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=trojan-grpc&sni=music.u.com.my#${user}"
trojanlink9="trojan://${uuid}@prod-in.viu.com.${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=trojan-grpc&sni=prod-in.viu.com#${user}"
trojanlink10="trojan://${uuid}@www.speedtest.net:80?path=/trojan&security=none&host=www.speedtest.net.$domain&type=ws#$user"
trojanlink11="trojan://$uuid@$domain:443?path=/trojan&security=tls&encryption=none&host=$domain&type=ws&sni=music.u.com.my#$user"
trojanlink12="trojan://$uuid@$domain:443?path=/trojan&security=tls&encryption=none&host=$domain&type=ws&sni=open.spotify.com#$user"
trojanlink13="trojan://$uuid@$domain:443?path=/trojan&security=tls&encryption=none&host=$domain&type=ws&sni=playtv.unifi.com.my#$user"
cat > /var/www/html/trojan/trojan-$user.txt << END
==========================
Trojan WS (CDN) TLS
==========================
- name: Trojan-$user
server: $domain
port: 443
type: trojan
password: $uuid
network: ws
sni: $domain
skip-cert-verify: true
udp: true
ws-opts:
path: /trojan
headers:
Host: $domain
==========================
Trojan gRPC (CDN)
==========================
- name: Trojan-$user
server: $domain
port: 443
type: trojan
password: $uuid
network: grpc
sni: $domain
skip-cert-verify: true
udp: true
grpc-opts:
grpc-service-name: "trojan-grpc"
==========================
Link Trojan Account
==========================
Link TLS  : trojan://$uuid@$domain:443?path=/trojan&security=tls&host=$domain&type=ws&sni=$domain#$user
==========================
Link NTLS : trojan://${uuid}@$domain:80?path=/trojan&security=none&host=$domain&type=ws#$user
==========================
Link gRPC : trojan://${uuid}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=trojan-grpc&sni=$domain#$user
==========================
END
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
systemctl restart xray
clear
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-trojan-$user.txt
echo -e "                   Trojan Account                  " | tee -a /user/log-trojan-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-trojan-$user.txt
echo -e "Remarks       : ${user}" | tee -a /user/log-trojan-$user.txt
echo -e "ISP           : $ISP" | tee -a /user/log-trojan-$user.txt
echo -e "City          : $CITY" | tee -a /user/log-trojan-$user.txt
echo -e "Host/IP       : ${domain}" | tee -a /user/log-trojan-$user.txt
echo -e "Wildcard      : (bug.com).${domain}" | tee -a /user/log-trojan-$user.txt
echo -e "Port TLS      : 443" | tee -a /user/log-trojan-$user.txt
echo -e "Port NTLS     : 80" | tee -a /user/log-trojan-$user.txt
echo -e "Port gRPC     : 443" | tee -a /user/log-trojan-$user.txt
echo -e "Alt Port TLS  : 2053, 2083, 2087, 2096, 8443" | tee -a /user/log-trojan-$user.txt
echo -e "Alt Port NTLS : 8080, 8880, 2052, 2082, 2086, 2095" | tee -a /user/log-trojan-$user.txt
echo -e "Password      : ${uuid}" | tee -a /user/log-trojan-$user.txt
echo -e "Network       : Websocket, gRPC" | tee -a /user/log-trojan-$user.txt
echo -e "Path          : /trojan" | tee -a /user/log-trojan-$user.txt
echo -e "ServiceName   : trojan-grpc" | tee -a /user/log-trojan-$user.txt
echo -e "Alpn          : h2, http/1.1" | tee -a /user/log-trojan-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-trojan-$user.txt
echo -e "Link TLS      : ${trojanlink1}" | tee -a /user/log-trojan-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-trojan-$user.txt
echo -e "Link NTLS     : ${trojanlink2}" | tee -a /user/log-trojan-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-trojan-$user.txt
echo -e "Link gRPC     : ${trojanlink3}" | tee -a /user/log-trojan-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "Link Yes4g   : ${trojanlink4}"| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "========================="| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "Link Digi Booster   : ${trojanlink5}"| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "========================="| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "Link Redone/Beone music(GRPC)   : ${trojanlink6}"| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "========================="| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "Link Redone/Beone music(WS)   : ${trojanlink12}"| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "========================="| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "Link Unifi Freeze (GRPC): ${trojanlink7}"| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "========================="| tee -a /user/log-trojan-$user.txt
echo -e "Link Unifi Freeze CWS): ${trojanlink13}"| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "========================="| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "Link umobile (GRPC): ${trojanlink8}"| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "========================="| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "Link umobile (WS): ${trojanlink11}"| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "========================="| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "Link maxis tv: ${trojanlink9}"| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "========================="| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "Link celcom freeze kuota/booster : ${trojanlink10}"| tee -a /user/log-trojan-$user.txt
echo -e " "| tee -a /user/log-trojan-$user.txt
echo -e "========================="| tee -a /user/log-trojan-$user.txt
echo "Script Mod By surun"| tee -a /user/log-trojan-$user.txt

echo -e "————————————————————————————————————————————————————" | tee -a /user/log-trojan-$user.txt
echo -e "Format Clash  : http://$domain:8000/trojan/trojan-$user.txt" | tee -a /user/log-trojan-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-trojan-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-trojan-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-trojan-$user.txt
echo " " | tee -a /user/log-trojan-$user.txt
echo " " | tee -a /user/log-trojan-$user.txt
echo " " | tee -a /user/log-trojan-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
trojan
