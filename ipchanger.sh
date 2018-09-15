#!/bin/bash
# Current version 1.1     by Jacob Ouellette
##### CHANGELOG #####
# v1.1
# - Add colored text;
# - Add ens interface name.
# v1.0 (Official release)
########################################################################################################
# Interface path "/etc/network/interfaces" is default.
INTPATH='/etc/network/interfaces'
########################################################################################################
function Error() {
	case "$1" in
	'1') echo -e "\e[31mERROR: Invalid IP address\e[0m";;
	'2') echo -e "\e[31mERROR: Invalid prefix\e[0m";;
	'3') echo -e "\e[31mERROR: Invalid gateway\e[0m";;
	'4') echo -e "\e[31mERROR: Interface does not exist\e[0m";;
	esac
	exit 1
} # Error code
function VerifyIP() {
	IFS='.' inarr=(${1});
	appender=''
	for i in {0..3}; do
		if [[ $i == 0 || $i == 3 ]]; then
			if [[ ${inarr[i]} -le 0 || ${inarr[i]} -ge 255 ]]; then
				if [[ $2 == 1 ]]; then Error 1; fi
                        	if [[ $2 == 2 ]]; then Error 3; fi
        		fi
		fi # Check first and last digit, can't be 0 or 255
		if [[ $i == 1 || $i == 2 ]]; then
			if [[ ${inarr[i]} -lt 0 || ${inarr[i]} -gt 255 ]]; then
				if [[ $2 == 1 ]]; then Error 1; fi
				if [[ $2 == 2 ]]; then Error 3; fi
			fi
		fi # Allow the 2nd and 3th digit to be 0 or 255
		appender+=${inarr[$i]}.
	done # Check IP validation
}
function AskInfo() {
	read -p "New IP with prefix (/gateway if needed): " nIP
	IFS='/' inarr=(${nIP});
	VerifyIP ${inarr[0]} 1
	IP=${appender::-1} # Remove last character .
	IFS='/' inarr=(${nIP});
	prefix=(${inarr[1]})
	if [[ $prefix -le 0 || $prefix -gt 32 ]]; then Error 2; fi # Check prefix validation
	CalcPrefix $prefix
	IFS='/' inarr=(${nIP});
	if ! [[ ${inarr[2]} == "" ]]; then
		VerifyIP ${inarr[2]} 2
		GW=${appender::-1}
	fi
}
function CalcPrefix() {
	for (( i=1; i<=32; i++ )); do
		if [[ ${#binMask} -lt $1 ]]; then
			binMask+=1
		else
			binMask+=0
		fi

	done # Get binary of prefix
	dotMask=$binMask
	for i in {1..27}; do
		if [[ $i == 8 || $i == 17 || $i == 26 ]]; then
			dotMask="${dotMask:0:i}.${dotMask:i}"
		fi
	done # Add . each 8 bit
	IFS='.' inarr=(${dotMask});
	n1=$((2#${inarr[0]})); n2=$((2#${inarr[1]})); n3=$((2#${inarr[2]})); n4=$((2#${inarr[3]})) # Binary to decimal
	netMask=$n1.$n2.$n3.$n4
}
function WriteChange() {
	if grep -Fq "$UINT" "$INTPATH"; then
		line=`grep -n "iface $UINT" "$INTPATH"`
		IFS=':' inarr=(${line})
		cip=$((${inarr[0]}+1)); cnet=$((${inarr[0]}+2)); cgw=$((${inarr[0]}+3)) # Get line number of ip, netmask and gw
		if [[ `sed -n "${inarr[0]}p" "$INTPATH"` =~ "dhcp" ]]; then
			echo '**Replacing dhcp by static mode**'
			sed -i "${inarr[0]}s/dhcp/static/" "$INTPATH"
		fi
		sed -i "${cip}s/.*/\taddress $IP/" "$INTPATH" # Replace a line by number
		sed -i "${cnet}s/.*/\tnetmask $netMask/" "$INTPATH"
		if ! [[ $3 == "" ]]; then
			if [[ `sed -n "${cgw}p" "$INTPATH"` =~ "gateway" ]]; then sed -i "${cgw}s/.*/\tgateway $GW/" "$INTPATH"
			else sed -i -e "${cnet}s/$/\n\tgateway $GW/" "$INTPATH"; fi
		fi
	else
		echo "auto $UINT" >> "$INTPATH"
		echo "iface $UINT inet static" >> "$INTPATH"
		echo -e "\taddress $IP" >> "$INTPATH"
		echo -e "\tnetmask $netMask" >> "$INTPATH"
		echo "$UINT added to $INTPATH file"
		if ! [[ $3 == "" ]]; then echo -e "\tgateway $GW" >> "$INTPATH"; fi
	fi
}
if [[ $1 =~ '-h' ]]; then
	echo "This script will not work without package ifupdown."
	echo "Simply follow the instruction."
	echo "Networking service will restart if the script execute successfully."
	exit 0
fi # Help
IPS=`ip addr | grep "inet "`
for SINT in $IPS; do
	if [[ "$SINT" =~ "vmnet" || "$SINT" =~ "enp" || "$SINT" =~ "eth" || "$SINT" =~ "ens" ]]; then ALL_INT+=$SINT' '; fi
done # Get all interfaces name
echo $ALL_INT
read -p "Select an interface: " UINT
for SINT in $ALL_INT; do
	if [[ $SINT == $UINT ]]; then
		AskInfo
		WriteChange $IP $netMask $GW
		echo '**Restarting networking service**'
		systemctl restart networking
		exit 0
	fi
done
Error 4
