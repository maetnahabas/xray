#!/bin/bash

rm -rf xray
clear
# ANSI Escape Code
export NC='\e[0m'
## Foreground
export DEFBOLD='\e[39;1m'
export RB='\e[31;1m'
export GB='\e[32;1m'
export YB='\e[33;1m'
export BB='\e[34;1m'
export MB='\e[35;1m'
export CB='\e[35;1m'
export WB='\e[37;1m'

secs_to_human() {
    echo "Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds"
}
start=$(date +%s)

#update
apt update -y
apt full-upgrade -y
apt dist-upgrade -y
apt install socat curl screen cron neofetch screenfetch netfilter-persistent vnstat fail2ban -y
mkdir /backup
mkdir /user
clear

# Install Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" - install --beta
cp /usr/local/bin/xray /backup/xray.official.backup
curl -s ipinfo.io/city >> /usr/local/etc/xray/city
curl -s ipinfo.io/org | cut -d " " -f 2-10 >> /usr/local/etc/xray/org
curl -s ipinfo.io/timezone >> /usr/local/etc/xray/timezone
clear

# Download Xray Mod
wget -O /backup/xray.mod.backup "https://github.com/dharak36/Xray-core/releases/download/v1.0.0/xray.linux.64bit"
cd
clear

# Install Speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest
clear

# set time GMT +1
ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Install Nginx
apt install nginx -y
rm /var/www/html/*.html
mkdir -p /var/www/html/vmess
mkdir -p /var/www/html/vless
mkdir -p /var/www/html/trojan
mkdir -p /var/www/html/shadowsocks
mkdir -p /var/www/html/shadowsocks2022
mkdir -p /var/www/html/socks5
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
systemctl restart nginx
clear

# Domain recomanded
touch /usr/local/etc/xray/domain
echo "Domain recomanded"
echo " "
read -rp "Domain recomanded🦁 : " -e dns
if [ -z $dns ]; then
echo -e "Nothing input for domain!"
else
echo "$dns" > /usr/local/etc/xray/domain
echo "DNS=$dns" > /var/lib/dnsvps.conf
fi
clear

# Install Cert
systemctl stop nginx
domain=$(cat /usr/local/etc/xray/domain)
curl https://get.acme.sh | sh
source ~/.bashrc
cd .acme.sh
bash acme.sh --issue -d $domain --server letsencrypt --keylength ec-256 --fullchain-file /usr/local/etc/xray/fullchain.crt --key-file /usr/local/etc/xray/private.key --standalone --force

# Setting
uuid=$(cat /proc/sys/kernel/random/uuid)
cipher="aes-128-gcm"
cipher2="2022-blake3-aes-128-gcm"
serverpsk=$(openssl rand -base64 16)
userpsk=$(openssl rand -base64 16)
echo "$serverpsk" > /usr/local/etc/xray/serverpsk
# Set Xray Conf
cat > /usr/local/etc/xray/config.json << END
{
  "log" : {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": "10001",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$uuid",
            "alterId": 0
#vmess
          }
        ]
      },
      "streamSettings":{
        "network": "ws",
        "wsSettings": {
          "path": "/vmess",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "10002",
      "protocol": "vless",
      "settings": {
        "decryption":"none",
        "clients": [
          {
            "id": "$uuid"
#vless
          }
        ]
      },
      "streamSettings":{
        "network": "ws",
        "wsSettings": {
          "path": "/vless",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "10003",
      "protocol": "trojan",
      "settings": {
        "decryption":"none",
        "clients": [
          {
            "password": "$uuid"
#trojan
          }
        ]
      },
      "streamSettings":{
        "network": "ws",
        "wsSettings": {
          "path": "/trojan",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "10006",
      "protocol": "shadowsocks",
      "settings": {
        "clients": [
            {
              "method": "$cipher",
              "password": "$uuid"
#shadowsocks
            }
          ],
        "network": "tcp,udp"
      },
      "streamSettings":{
        "network": "ws",
        "wsSettings": {
          "path": "/shadowsocks",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "10005",
      "protocol": "shadowsocks",
      "settings": {
        "method": "$cipher2",
        "password": "$serverpsk",
        "clients": [
          {
            "password": "$userpsk"
#shadowsocks2022
          }
        ],
        "network": "tcp,udp"
      },
      "streamSettings":{
        "network": "ws",
        "wsSettings": {
          "path": "/shadowsocks2022",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "10006",
      "protocol": "socks",
      "settings": {
        "auth": "password",
        "accounts": [
            {
              "user": "private",
              "pass": "server"
#socks
            }
          ],
        "udp": true,
        "ip": "127.0.0.1"
      },
      "streamSettings":{
        "network": "ws",
        "wsSettings": {
          "path": "/socks5",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "20001",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$uuid",
            "alterId": 0
#vmess-grpc
          }
        ]
      },
      "streamSettings":{
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "vmess-grpc",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "20002",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$uuid",
            "alterId": 0
#vmess-grpc
          }
        ]
      },
      "streamSettings":{
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "vmess-grpc",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "20002",
      "protocol": "vless",
      "settings": {
        "decryption":"none",
        "clients": [
          {
            "id": "$uuid"
#vless-grpc
          }
        ]
      },
      "streamSettings":{
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "vless-grpc",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "20003",
      "protocol": "trojan",
      "settings": {
        "decryption":"none",
        "clients": [
          {
            "password": "$uuid"
#trojan-grpc
          }
        ],
        "udp": true
      },
      "streamSettings":{
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "trojan-grpc",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "20004",
      "protocol": "shadowsocks",
      "settings": {
        "clients": [
            {
              "method": "$cipher",
              "password": "$uuid"
#shadowsocks-grpc
            }
          ],
        "network": "tcp,udp"
      },
      "streamSettings":{
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "shadowsocks-grpc",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "20005",
      "protocol": "shadowsocks",
      "settings": {
        "method": "$cipher2",
        "password": "$serverpsk",
        "clients": [
          {
            "password": "$userpsk"
#shadowsocks2022-grpc
          }
        ],
        "network": "tcp,udp"
      },
      "streamSettings":{
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "shadowsocks2022-grpc",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "20006",
      "protocol": "socks",
      "settings": {
        "auth": "password",
        "accounts": [
            {
              "user": "private",
              "pass": "server"
#socks-grpc
            }
          ],
        "udp": true,
        "ip": "127.0.0.1"
      },
      "streamSettings":{
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "socks5-grpc",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "tag": "block"
    }
  ]
}
END

# Set Nginx Conf
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes 1;
pid /var/run/nginx.pid;
events {
	multi_accept on;
	worker_connections 1024;
}
http {
	gzip on;
	gzip_vary on;
	gzip_comp_level 5;
	gzip_types text/plain application/x-javascript text/xml text/css;
	autoindex on;
	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	server_tokens off;
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;
	client_max_body_size 32M;
	client_header_buffer_size 8m;
	large_client_header_buffers 8 8m;
	fastcgi_buffer_size 8m;
	fastcgi_buffers 8 8m;
	fastcgi_read_timeout 600;
	#CloudFlare IPv4
	set_real_ip_from 199.27.128.0/21;
	set_real_ip_from 173.245.48.0/20;
	set_real_ip_from 103.21.244.0/22;
	set_real_ip_from 103.22.200.0/22;
	set_real_ip_from 103.31.4.0/22;
	set_real_ip_from 141.101.64.0/18;
	set_real_ip_from 108.162.192.0/18;
	set_real_ip_from 190.93.240.0/20;
	set_real_ip_from 188.114.96.0/20;
	set_real_ip_from 197.234.240.0/22;
	set_real_ip_from 198.41.128.0/17;
	set_real_ip_from 162.158.0.0/15;
	set_real_ip_from 104.16.0.0/12;
	#Incapsula
	set_real_ip_from 199.83.128.0/21;
	set_real_ip_from 198.143.32.0/19;
	set_real_ip_from 149.126.72.0/21;
	set_real_ip_from 103.28.248.0/22;
	set_real_ip_from 45.64.64.0/22;
	set_real_ip_from 185.11.124.0/22;
	set_real_ip_from 192.230.64.0/18;
	real_ip_header CF-Connecting-IP;
	include /etc/nginx/conf.d/*.conf;
}
EOF

# Set Xray Nginx Conf
cat > /etc/nginx/conf.d/xray.conf << EOF
    server {
             listen 81;
             listen [::]:81;
             root /var/www/html;
        }
    server {
             listen 80;
             listen [::]:80;
             listen 2052;
             listen [::]:2052;
             listen 2082;
             listen [::]:2082;
             listen 2086;
             listen [::]:2086;
             listen 2095;
             listen [::]:2095;
             listen 8080;
             listen [::]:8080;
             listen 8880;
             listen [::]:8880;
             listen 443 ssl http2;
             listen [::]:443 ssl http2;
             listen 2053 ssl ssl http2;
             listen [::]:2053 ssl http2;
             listen 2083 ssl ssl http2;
             listen [::]:2083 ssl http2;
             listen 2087 ssl ssl http2;
             listen [::]:2087 ssl http2;
             listen 2096 ssl ssl http2;
             listen [::]:2096 ssl http2;
             listen 8443 ssl ssl http2;
             listen [::]:8443 ssl http2;
             server_name *.$domain;
             ssl_certificate /usr/local/etc/xray/fullchain.crt;
             ssl_certificate_key /usr/local/etc/xray/private.key;
        }
EOF

sed -i '$ ilocation /vmess {' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:10001;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation /vless {' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:10002;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation /trojan {' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:10003;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation /shadowsocks {' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:10004;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation /shadowsocks2022 {' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:10005;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation /socks5 {' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:10006;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /vmess-grpc {' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:20001;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /vless-grpc {' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:20002;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /trojan-grpc {' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:20003;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /shadowsocks-grpc {' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:20004;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /shadowsocks2022-grpc {' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:20005;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /socks5-grpc {' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:20006;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

systemctl restart nginx
systemctl restart xray

# Blokir TORRENT
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# Enable BBR
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sed -i '/fs.file-max/d' /etc/sysctl.conf
sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
# forward ipv4
net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

cd /usr/bin
## Menu
wget -O menu "https://raw.githubusercontent.com/maetnahabas/Xray/main/menu/menu.sh"
wget -O vmess "https://raw.githubusercontent.com/maetnahabas/Xray/main/menu/vmess.sh"
wget -O vless "https://raw.githubusercontent.com/maetnahabas/Xray/main/menu/vless.sh"
wget -O trojan "https://raw.githubusercontent.com/maetnahabas/Xray/main/menu/trojan.sh"
wget -O shadowsocks "https://raw.githubusercontent.com/maetnahabas/Xray/main/menu/shadowsocks.sh"
wget -O shadowsocks2022 "https://raw.githubusercontent.com/maetnahabas/Xray/main/menu/shadowsocks2022.sh"
wget -O socks "https://raw.githubusercontent.com/maetnahabas/Xray/main/menu/socks.sh"
wget -O allxray "https://raw.githubusercontent.com/maetnahabas/Xray/main/menu/allxray.sh"
wget -O bbr "https://raw.githubusercontent.com/maetnahabas/Xray/main/menu/bbr.sh"
wget -O reality "https://raw.githubusercontent.com/maetnahabas/Xray/main/menu/reality.sh"
## Vmess
wget -O add-vmess "https://raw.githubusercontent.com/maetnahabas/Xray/main/vmess/add-vmess.sh"
wget -O del-vmess "https://raw.githubusercontent.com/maetnahabas/Xray/main/vmess/del-vmess.sh"
wget -O extend-vmess "https://raw.githubusercontent.com/maetnahabas/Xray/main/vmess/extend-vmess.sh"
wget -O trialvmess "https://raw.githubusercontent.com/maetnahabas/Xray/main/vmess/trialvmess.sh"
wget -O cek-vmess "https://raw.githubusercontent.com/maetnahabas/Xray/main/vmess/cek-vmess.sh"
## Vless
wget -O add-vless "https://raw.githubusercontent.com/maetnahabas/Xray/main/vless/add-vless.sh"
wget -O del-vless "https://raw.githubusercontent.com/maetnahabas/Xray/main/vless/del-vless.sh"
wget -O extend-vless "https://raw.githubusercontent.com/maetnahabas/Xray/main/vless/extend-vless.sh"
wget -O trialvless "https://raw.githubusercontent.com/maetnahabas/Xray/main/vless/trialvless.sh"
wget -O cek-vless "https://raw.githubusercontent.com/maetnahabas/Xray/main/vless/cek-vless.sh"
## Trojan
wget -O add-trojan "https://raw.githubusercontent.com/maetnahabas/Xray/main/trojan/add-trojan.sh"
wget -O del-trojan "https://raw.githubusercontent.com/maetnahabas/Xray/main/trojan/del-trojan.sh"
wget -O extend-trojan "https://raw.githubusercontent.com/maetnahabas/Xray/main/trojan/extend-trojan.sh"
wget -O trialtrojan "https://raw.githubusercontent.com/maetnahabas/Xray/main/trojan/trialtrojan.sh"
wget -O cek-trojan "https://raw.githubusercontent.com/maetnahabas/Xray/main/trojan/cek-trojan.sh"
## Shadowsocks
wget -O add-ss "https://raw.githubusercontent.com/maetnahabas/Xray/main/shadowsocks/add-ss.sh"
wget -O del-ss "https://raw.githubusercontent.com/maetnahabas/Xray/main/shadowsocks/del-ss.sh"
wget -O extend-ss "https://raw.githubusercontent.com/maetnahabas/Xray/main/shadowsocks/extend-ss.sh"
wget -O trialss "https://raw.githubusercontent.com/maetnahabas/Xray/main/shadowsocks/trialss.sh"
wget -O cek-ss "https://raw.githubusercontent.com/maetnahabas/Xray/main/shadowsocks/cek-ss.sh"
## Shadowsocks 2022
wget -O add-ss2022 "https://raw.githubusercontent.com/maetnahabas/Xray/main/shadowsocks2022/add-ss2022.sh"
wget -O del-ss2022 "https://raw.githubusercontent.com/maetnahabas/Xray/main/shadowsocks2022/del-ss2022.sh"
wget -O extend-ss2022 "https://raw.githubusercontent.com/maetnahabas/Xray/main/shadowsocks2022/extend-2022.sh"
wget -O trialss2022 "https://raw.githubusercontent.com/maetnahabas/Xray/main/shadowsocks2022/trialss2022.sh"
wget -O cek-ss2022 "https://raw.githubusercontent.com/maetnahabas/Xray/main/shadowsocks2022/cek-ss2022.sh"
## Socks5
wget -O add-socks "https://raw.githubusercontent.com/maetnahabas/Xray/main/socks/add-socks.sh"
wget -O del-socks "https://raw.githubusercontent.com/maetnahabas/Xray/main/socks/del-socks.sh"
wget -O extend-socks "https://raw.githubusercontent.com/maetnahabas/Xray/main/socks/extend-socks.sh"
wget -O trialsocks "https://raw.githubusercontent.com/maetnahabas/Xray/main/socks/trialsocks.sh"
wget -O cek-socks "https://raw.githubusercontent.com/maetnahabas/Xray/main/socks/cek-socks.sh"
## Log
wget -O log-create "https://raw.githubusercontent.com/maetnahabas/Xray/main/log/log-create.sh"
wget -O log-vmess "https://raw.githubusercontent.com/maetnahabas/Xray/main/log/log-vmess.sh"
wget -O log-vless "https://raw.githubusercontent.com/maetnahabas/Xray/main/log/log-vless.sh"
wget -O log-trojan "https://raw.githubusercontent.com/maetnahabas/Xray/main/log/log-trojan.sh"
wget -O log-ss "https://raw.githubusercontent.com/maetnahabas/Xray/main/log/log-ss.sh"
wget -O log-ss2022 "https://raw.githubusercontent.com/maetnahabas/Xray/main/log/log-ss2022.sh"
wget -O log-socks "https://raw.githubusercontent.com/maetnahabas/Xray/main/log/log-socks.sh"
## Other
wget -O xp "https://raw.githubusercontent.com/maetnahabas/Xray/main/other/xp.sh"
wget -O dns "https://raw.githubusercontent.com/maetnahabas/Xray/main/other/dns.sh"
wget -O certxray "https://raw.githubusercontent.com/maetnahabas/Xray/main/other/certxray.sh"
wget -O xraymod "https://raw.githubusercontent.com/maetnahabas/Xray/main/other/xraymod.sh"
wget -O xrayofficial "https://raw.githubusercontent.com/maetnahabas/Xray/main/other/xrayofficial.sh"
wget -O about "https://raw.githubusercontent.com/maetnahabas/Xray/main/other/about.sh"
wget -O restart "https://raw.githubusercontent.com/maetnahabas/Xray/main/other/restart.sh"
wget -O kernel-updt "https://raw.githubusercontent.com/maetnahabas/Xray/main/other/kernel-updt.sh"
wget -O backup "https://raw.githubusercontent.com/maetnahabas/Xray/main/other/backup.sh"
wget -O restore "https://raw.githubusercontent.com/maetnahabas/Xray/main/other/restore.sh"
## allxray
wget -O add-xray "https://raw.githubusercontent.com/maetnahabas/Xray/main/allxray/add-xray.sh"
wget -O cek-xray "https://raw.githubusercontent.com/maetnahabas/Xray/main/allxray/cek-xray.sh"
wget -O del-xray "https://raw.githubusercontent.com/maetnahabas/Xray/main/allxray/del-xray.sh"
wget -O extend-xray "https://raw.githubusercontent.com/maetnahabas/Xray/main/allxray/extend-xray.sh"
wget -O trial-xray "https://raw.githubusercontent.com/maetnahabas/Xray/main/allxray/trialxray.sh"
## APN
wget -O apn "https://raw.githubusercontent.com/maetnahabas/Xray/main/apn/apn.sh"
wget -O digi "https://raw.githubusercontent.com/maetnahabas/Xray/main/apn/digi.sh"
wget -O celcom "https://raw.githubusercontent.com/maetnahabas/Xray/main/apn/celcom.sh"
wget -O maxis "https://raw.githubusercontent.com/maetnahabas/Xray/main/apn/maxis.sh"
## ADD On
wget -O ins-helium "https://raw.githubusercontent.com/maetnahabas/Xray/main/addon/ins-helium.sh"
wget -O helium "https://raw.githubusercontent.com/maetnahabas/Xray/main/addon/helium.sh"
wget -O dnss "https://raw.githubusercontent.com/maetnahabas/Xray/main/addon/dns.sh"
wget -O nf "https://raw.githubusercontent.com/maetnahabas/Xray/main/addon/media.sh"
wget -O clear-log "https://raw.githubusercontent.com/maetnahabas/Xray/main/addon/clear-log.sh"
## Chmod Vmess
chmod +x add-vmess
chmod +x del-vmess
chmod +x extend-vmess
chmod +x trialvmess
chmod +x cek-vmess
## Chmod Vless
chmod +x add-vless
chmod +x del-vless
chmod +x extend-vless
chmod +x trialvless
chmod +x cek-vless
## Chmod Trojan
chmod +x add-trojan
chmod +x del-trojan
chmod +x extend-trojan
chmod +x trialtrojan
chmod +x cek-trojan
## Chmod Shadowsocks
chmod +x add-ss
chmod +x del-ss
chmod +x extend-ss
chmod +x trialss
chmod +x cek-ss
## Chmod Shadowsocks 2022
chmod +x add-ss2022
chmod +x del-ss2022
chmod +x extend-ss2022
chmod +x trialss2022
chmod +x cek-ss2022
## Chmod Socks5
chmod +x add-socks
chmod +x del-socks
chmod +x extend-socks
chmod +x trialsocks
chmod +x cek-socks
## Chmod Log
chmod +x log-create
chmod +x log-vmess
chmod +x log-vless
chmod +x log-trojan
chmod +x log-ss
chmod +x log-ss2022
chmod +x log-socks
## Chmod Menu
chmod +x menu
chmod +x vmess
chmod +x vless
chmod +x trojan
chmod +x shadowsocks
chmod +x shadowsocks2022
chmod +x socks
chmod +x allxray
chmod +x bbr
## Chmod Other
chmod +x xp
chmod +x dns
chmod +x certxray
chmod +x xraymod
chmod +x xrayofficial
chmod +x about
chmod +x restart
chmod +x kernel-updt
chmod +x backup
chmod +x restore
## chmod allxray
chmod +x add-xray
chmod +x cek-xray
chmod +x del-xray
chmod +x extend-xray
chmod +x trial-xray
## chmod apn
chmod +x apn
chmod +x digi
chmod +x celcom
chmod +x maxis
## chmod addon
chmod +x ins-helium
chmod +x helium
chmod +x dnss
chmod +x nf
chmod +x clear-log
## Chmod Reality
chmod +x add-reality
chmod +x del-reality
chmod +x extend-reality
chmod +x trialreality
chmod +x cek-reality
cd
echo "0 0 * * * root xp" >> /etc/crontab
systemctl restart cron

cat > /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
menu
END
chmod 644 /root/.profile

clear
echo ""
echo ""
echo -e "${BB}—————————————————————————————————————————————————————————${NC}"
echo -e "               ${WB}V2Ray++ Maetnahabas${NC}"
echo -e "${BB}—————————————————————————————————————————————————————————${NC}"
echo -e "  ${WB}»»» Protocol Service «««  |  »»» Network Protocol «««${NC}  "
echo -e "${BB}—————————————————————————————————————————————————————————${NC}"
echo -e "  ${YB}- Vless${NC}                   ${WB}|${NC}  ${YB}- Websocket (CDN) non TLS${NC}"
echo -e "  ${YB}- Vmess${NC}                   ${WB}|${NC}  ${YB}- Websocket (CDN) TLS${NC}"
echo -e "  ${YB}- Trojan${NC}                  ${WB}|${NC}  ${YB}- gRPC (CDN) TLS${NC}"
echo -e "  ${YB}- Socks5${NC}                  ${WB}|${NC}"
echo -e "  ${YB}- Shadowsocks${NC}             ${WB}|${NC}"
echo -e "  ${YB}- Shadowsocks 2022${NC}        ${WB}|${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "               ${WB}»»» Network Port Service «««${NC}             "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "  ${YB}- HTTPS : 443, 2053, 2083, 2087, 2096, 8443${NC}"
echo -e "  ${YB}- HTTP  : 80, 8080, 8880, 2052, 2082, 2086, 2095${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo ""
rm -f xray
secs_to_human "$(($(date +%s) - ${start}))"
echo -e "${YB}[ WARNING ] reboot now ? (Y/N)${NC} "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
