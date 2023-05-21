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
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "               ${WB}----- [ reality Menu ] -----${NC}               "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e ""
echo -e " ${MB}[1]${NC} ${YB}Create Account reality${NC} "
echo -e " ${MB}[2]${NC} ${YB}Trial Account reality${NC} "
echo -e " ${MB}[3]${NC} ${YB}Extend Account reality${NC} "
echo -e " ${MB}[4]${NC} ${YB}Delete Account reality${NC} "
echo -e " ${MB}[5]${NC} ${YB}Check User Login${NC} "
echo -e " ${MB}[6]${NC} ${YB}Check User Config${NC} "
echo -e ""
echo -e " ${MB}[0]${NC} ${YB}Back To Menu${NC}"
echo -e ""
echo -e "${BB}———————————————————————————————————————————————————————${NC}"
echo -e ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
1) clear ; add-reality ; exit ;;
2) clear ; trialreality ; exit ;;
3) clear ; extend-reality ; exit ;;
4) clear ; del-reality ; exit ;;
5) clear ; cek-reality ; exit ;;
6) clear ; log-reality ; exit ;;
0) clear ; menu ; exit ;;
x) exit ;;
*) echo -e "choose correct number " ; sleep 1 ; reality ;;
esac
