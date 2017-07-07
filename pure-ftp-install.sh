#!/bin/bash
clear
echo "Welcome to Pure-FTP Auto Installer Script"
echo ""
echo "Developed by HHsungur"
echo ""

if [ "$(whoami)" != "root" ]; then
	echo "This script must be run as root"
	exit
fi

if [ -e /etc/debian_version ]; then

	if [ -e /etc/pure-ftpd ]; then
	
		while :
		do
			echo "Pure-FTP is already installed."
			echo ""
			echo "1) Add a new user"
			echo "2) Change a user password"
			echo "3) Delete a user"
			echo "4) Remove Pure-FTP and configurations"
			echo "5) Exit"
			case $option in
				1)
					read -p "Enter a Username: " -e ADDUSERNAME
					read -p "Enter $ADDUSERNAME's password: " -e ADDPASSWORD
					read -p "Enter $ADDUSERNAME's directory: " -e -i /home/$ADDUSERNAME ADDUSERDIR
					echo ""
					echo "The User is creating now... Please wait."
					echo ""
					echo -e "$ADDPASSWORD\\n$ADDPASSWORD" | pure-pw useradd $ADDUSERNAME -u www-data -d $ADDUSERDIR
					pure-pw mkdb
					if [ -e /etc/init.d/pure-ftpd ]; then
						/etc/init.d/pure-ftpd restart
					else
						echo "Pure-FTP is not working properly. Please remove and Re-install it."
						exit
					fi
					exit
					;;
				2)
					read -p "Enter the username: " -e CHNUSERNAME
					read -p "Enter password: " -e CHNPASSWORD
					echo -e "$CHNPASSWORD\\n$CHNPASSWORD" | pure-pw passwd $CHNUSERNAME -m
					pure-pw mkdb
					exit
					;;
				3)
					read -p "Enter the username: " -e DELUSERNAME
					read -p "Are you sure? [y/n]: " -e -i n TTT
					if [ "$TTT" = "y" ]; then
						pure-pw userdel $DELUSERNAME -m
						pure-pw mkdb
					else
					echo "Closing now.."
					exit
					fi
					exit
					;;
				4)
					read -p "Are you sure? [y/n]: " -e -i n TTTT
					if [ "$TTTT" = "y" ]; then
						apt-get remove --purge --yes pure-ftpd
						apt-get --yes autoremove
						if [ -e /etc/pure-ftpd ]; then
							rm -rf /etc/pur-ftpd
						fi
					else
						echo "Closing now.."
						exit
					fi
					exit
					;;
				5)
					exit
					;;
			esac
		done
	else
		read -p "Pure-FTP is not installed. Do you want to install? [y/n]: " -e -i y TT
		if [ "$TT" = "y" ]; then
			apt-get --yes update
			apt-get --yes install pure-ftpd
			IP=$(curl ip.mtak.nl -4)
			cd /etc/pure-ftpd
			touch ForcePassiveIP
			touch PassivePortRange
			chmod 
			echo -e "$IP" | tee -a /etc/pure-ftpd/ForcePassiveIP
			echo -e "10110 10210" | tee -a /etc/pure-ftpd/PassivePortRange
			perl -pi -e "s/1000/1/g" /etc/pure-ftpd/MinUID
			perl -pi -e "s/yes/no/g" /etc/pure-ftpd/PAMAuthentication
			ln -s /etc/pure-ftpd/conf/PureDB /etc/pure-ftpd/auth/50pure
		else
			echo "Closing now.."
			exit
		fi
		echo "Pure-FTP is installed. Please Re-open this script for create user."
		exit
	fi
else
	echo "This script must be run on Debian or Ubuntu."
	exit
fi 