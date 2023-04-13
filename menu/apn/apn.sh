#!/bin/bash
clear
m="\033[0;1;36m"
y="\033[0;1;37m"
yy="\033[0;1;32m"
yl="\033[0;1;33m"
wh="\033[0m"
echo -e "$y                          APN Menu $wh"
echo -e "$y-------------------------------------------------------------$wh"
echo -e "$yy 1$y. Digi"
echo -e "$yy 2$y. Celcom"
echo -e "$yy 3$y. Maxis"
echo -e "$yy 4$y. Umobile"
echo -e "$yy 5$y. Yes4g"
echo -e "$yy 6$y. Menu"
echo -e "$yy 7$y. Exit"
echo -e "$y-------------------------------------------------------------$wh"
read -p "Select From Options [ 1 - 6 ] : " menu
echo -e ""
case $menu in
1)
digi
;;
2)
celcom
;;
3)
maxis
;;
4)
umobile
;;
5)
yes4g
;;
6)
menu
;;
7)
exit
;;
*)
clear
menu
;;
esac
