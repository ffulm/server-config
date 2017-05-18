#!/bin/bash

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


# TODO
# Install tinc
#{
#}

exit 0
