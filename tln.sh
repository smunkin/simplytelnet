#!/bin/sh

# check installed packets
if [ -f /usr/bin/dialog ] & [ -f /usr/bin/expect ]; then
	echo "All packets installed!">/dev/null;
else
    echo "Please install dialog and expect!\033[0m"; 
    exit;
fi
# your autorization password to access for telnet client
auth_passw="0123"

# Choose the city, login and password, ip address part
choice=$(dialog --stdout --menu "Choose city:" 10 38 14 \
1 "City1" \
2 "City2" \
3 "City3" \
0 "Exit")
clear
case $choice in
1) entry_login="admin"; entry_password="admin123" ; ip_part="10.10." ;;
2) entry_login="admin"; entry_password="admin456" ; ip_part="10.11." ;;
2) entry_login="admin"; entry_password="admin789" ; ip_part="10.12." ;;
*) exit 0 ;;
esac

clear
passwd=$auth_passw # if autorization not needed, uncomment this string
#passwd=$(dialog --stdout --title "Password" --colors --insecure --passwordbox "Enter password:"  \10 35) # if autorization not needed, comment this string
now_time=$(date '+%c')
while [ 1 ]; do
if [ "$passwd" = "$auth_passw" ]; then
	lastip=$(tail -n 1 lastip.txt)
	input=$(dialog --backtitle "Last IP: $lastip" --stdout --title "Connect to:" --inputbox "Enter IP:"  \10 35 $ip_part)
	# check host
	ping -q -c1 $input> /dev/null
	if [ $? -eq 0 ]; then
		echo "[$now_time]:	" $input "	Host is available, logging.">>tlnlog.log
		# if host available
		clear;
		expect -c "
		spawn telnet  $input;
		expect \"serName:\";
		send \"$entry_login\r\";
		expect \"assWord:\";
		send \"$entry_password\r\";
		expect \"#\";
		interact";
	else
		# if host unavailable
		echo "[$now_time]:	" $input "	Host is unavailable, close connection.">>tlnlog.log
        dialog --colors --title "\ZrInformation:" --cr-wrap --trim --msgbox "\ZbHost $input is unavailable or incorrect ip address!" 10 35;
	fi
	echo $input>>lastip.txt
	echo "[$now_time]:	" $input "	Logout.">>tlnlog.log
else
	echo "[$now_time]:	Autorization failed! with password: \"$passwd\", exit">>tlnlog.log
	tput clear;
	exit;
fi
done
