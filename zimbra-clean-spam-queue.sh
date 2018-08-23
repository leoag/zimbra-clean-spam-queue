#!/bin/bash
## Author: Leonardo A. Gallego
## Usage: zimbra-clean-spam-queue.sh [options]
##
## Options:
##	-m	--maxlogins	Maximum logins allowed for the period (or minimum threshold for filter). 
##	-s	--status	Account status to set, can be one of: closed, blocked, maintenance
##	-y	--yes		Force yes as answer to set status and clear queue for the user account

## variables:
zimbra_log="/var/log/zimbra.log"
domain=dominio.com

zmprov=/opt/zimbra/bin/zmprov
postqueue=/opt/zimbra/postfix/sbin/postqueue
postsuper=/opt/zimbra/postfix/sbin/postsuper

date=$(date '+%Y-%m-%d-%H%M%S')

maxlogins=50
accountstatus=closed
#accountstatus=maintenance
#accountstatus=blocked

## TODO:
# Agregar comando para bloquear cuenta (bloquear, mantenimiento, cerrar)
# Extender para listar logs comprimidos
# VALIDACIONES!!

echo ""
echo "This script works by scanning the logs for excesive user logins"
echo "This behavior is usually associated with an account that was compromised"
echo "and it's being used to send spam or other unauthorized email"
echo ""
echo "The script requieres a minimum number of logins to set as the threshold"
echo "Then it will check every login in the last log file and output every user"
echo "who exceeded this number, asking if you want to block the account"
echo "and clear the mail queue for the user account"
echo ""
echo "Press any key to continue"
read
clear
echo ""
echo "Minimum logins per user to filter (the user had at least this number):"
read maxlogins
echo ""

## hacemos array:
declare -a listarlogins

## armar arreglo y ordenar descendiente salida, primer registro mayor logins
listarlogins=($(sed -n 's/.*sasl_username=//p' /var/log/zimbra.log | sort | uniq -c | sort -rn))

for key in ${!listarlogins[@]} ; do
	if (( key % 2 )) && [ ${listarlogins[${key}]} -gt ${maxlogins} ] ; then
		# array: ${key}
		echo ""
		echo "User: ${listarlogins[${key}]}"
		echo "Logins: ${listarlogins[${key}-1]}"
		echo ""
		echo "Do you wish to block de account and clean the queue"
		echo "for the user ${listarlogins[${key}]} ? (y / n)"
		read clean
		if [ $clean == "y" ] || [ $clean == "yes" ]; then
			echo ""
			echo "Blocking account and deleting queue for user ${listarlogins[${key}]}"
			## comando zimbraAccountStatus
			#sudo -Hu zimbra zmprov zimbraAccountStatus ${accountstatus}
			echo ""
			## comando postqueue y postsuper
			#sudo -Hu zimbra ${postqueue} -p | awk '/${listarlogins[${key}]}/ {print $1}' | sudo ${postsuper} -d - 
			## comando demo con log
			sudo -Hu zimbra ${postqueue} -p | awk '/${listarlogins[${key}]}/ {print $1}' > /tmp/postqueue-${listarlogins[${key}]}.log
			echo "Blocked and cleaned"
			echo ""
		fi
	fi
	echo "DONE *********************************"
done
