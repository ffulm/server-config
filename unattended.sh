#!/bin/bash

echo "${green}******************************${col_reset}"
echo "${green}* set up unattended upgrades *${col_reset}"
echo "${green}******************************${col_reset}"


{
	echo "(I) ${green}Install unattended updates packages${col_reset}"
	apt install --assume-yes unattended-upgrades apticron

	echo "(I) ${green}Install config${col_reset}"
	cp -r etc/apt/* /etc/apt/apt.conf.d/
}

exit 0
