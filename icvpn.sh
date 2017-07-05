#!/bin/bash


icvpn_hostname=ulm10


echo "${green}************************${col_reset}"
echo "${green}* set up InterCity VPN *${col_reset}"
echo "${green}************************${col_reset}"

# ICVPN DNS updates
{
	echo "(I) ${green}icvpn dns: Install git and python yaml package${col_reset}"
	apt install --assume-yes git sudo python-yaml
	echo "(I) ${green}icvpn dns: Copy cron daily file${col_reset}"
	cp -f etc/cron.daily/icvpn-dns-update /etc/cron.daily/
	echo "(I) ${green}icvpn dns: Clone icvpn-meta${col_reset}"
        rm -rf /var/lib/icvpn-meta
	git clone https://github.com/freifunk/icvpn-meta /var/lib/icvpn-meta
	echo "(I) ${green}icvpn dns: Clone icvpn-scripts${col_reset}"
        rm -rf /opt/icvpn-scripts
	git clone https://github.com/freifunk/icvpn-scripts /opt/icvpn-scripts
}


# tinc tunnel
{
	echo "(I) ${green}icvpn tinc: Install tinc package${col_reset}"
	apt install --assume-yes git tinc

	rm -rf /etc/tinc/icvpn
	echo "(I) ${green}icvpn tinc: Clone repo of other peers ${col_reset}"
        git clone https://github.com/freifunk/icvpn /tmp/icvpn
	mv /tmp/icvpn /etc/tinc/

	if [ -z "$(cat /etc/tinc/nets.boot | grep 'icvpn')" ]; then
	        echo "(I) ${green}Add icvpn startup entry to /etc/tinc/nets.boot${col_reset}"
		echo "icvpn" >> nets.boot
	fi

	cp etc/tinc/tinc.conf /etc/tinc/icvpn/
	sed -i "s/ICVPN_HOST/$icvpn_hostname/g" /etc/tinc/icvpn/tinc.conf

}

# and bird/bird6
#


exit 0
