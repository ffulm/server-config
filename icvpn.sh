#!/bin/bash

echo "${green}************************${col_reset}"
echo "${green}* set up InterCity VPN *${col_reset}"
echo "${green}************************${col_reset}"


# ICVPN DNS updates
{
	echo "(I) ${green}icvpn dns: Install git and python yaml package${col_reset}"
	apt install --assume-yes git sudo python-yaml
	echo "(I) ${green}icvpn dns: Clone icvpn-meta${col_reset}"
	rm -rf /var/lib/icvpn-meta
	git clone https://github.com/freifunk/icvpn-meta /var/lib/icvpn-meta
	echo "(I) ${green}icvpn dns: Clone icvpn-scripts${col_reset}"
	rm -rf /opt/icvpn-scripts
	git clone https://github.com/freifunk/icvpn-scripts /opt/icvpn-scripts

	echo "(I) ${green}icvpn dns: Copy cron daily file${col_reset}"
	\cp -f etc/cron.daily/icvpn-dns-update /etc/cron.daily/
}

# tinc tunnel
{
	echo "(I) ${green}icvpn tinc: Install tinc package${col_reset}"
	apt install --assume-yes git tinc
	# tinc1a.1pre necessary?
	# build according to https://gist.github.com/mweinelt/efff4fb7eba1ee41ef2d

	# save key pair before cleaning up, but only if it's a pair
	if [ -f /etc/tinc/icvpn/rsa_key.priv -a -f /etc/tinc/icvpn/hosts/$icvpn_hostname ]; then
		echo "(I) ${green}icvpn tinc: save private key${col_reset}"
		\cp -f /etc/tinc/icvpn/rsa_key.priv /root/
		echo "(I) ${green}icvpn tinc: save public key${col_reset}"
		\cp -f /etc/tinc/icvpn/hosts/$icvpn_hostname /root/
	fi
	
	# clean up
	rm -rf /etc/tinc/icvpn
	echo "(I) ${green}icvpn tinc: Clone repo of other peers ${col_reset}"
	git clone https://github.com/freifunk/icvpn /tmp/icvpn
	\mv -f /tmp/icvpn /etc/tinc/

	# restore key pair, but only if it's a pair
	if [ -f /root/rsa_key.priv -a -f /root/$icvpn_hostname ]; then
		echo "(I) ${green}icvpn tinc: restore private key${col_reset}"
		\mv -f /root/rsa_key.priv /etc/tinc/icvpn/
		echo "(I) ${green}icvpn tinc: restore public key${col_reset}"
		\mv -f /root/$icvpn_hostname /etc/tinc/icvpn/hosts/
	fi

	if [ -z "$(cat /etc/tinc/nets.boot | grep 'icvpn')" ]; then
		echo "(I) ${green}icvpn tinc: Add icvpn startup entry to /etc/tinc/nets.boot${col_reset}"
		echo "icvpn" >> nets.boot
	fi

	echo "(I) ${green}icvpn tinc: copy tinc config${col_reset}"
	\cp -f etc/tinc/icvpn/tinc.conf /etc/tinc/icvpn/
	echo "(I) ${green}icvpn tinc: set icvpn hostname${col_reset}"
	sed -i "s/ICVPN_HOST/$icvpn_hostname/g" /etc/tinc/icvpn/tinc.conf

	# backslash is for unaliased version of cp (no user interaction)
	echo "(I) ${green}icvpn tinc: Copy cron hourly file${col_reset}"
	\cp -f etc/cron.hourly/icvpn-update /etc/cron.hourly/

	# copy git merge hook
	echo "(I) ${green}icvpn tinc: Copy git merge hook${col_reset}"
	\cp -f /etc/tinc/icvpn/scripts/post-merge /etc/tinc/icvpn/.git/hooks/
	# run once
	echo "(I) ${green}icvpn tinc: Run git merge hook once${col_reset}"
	cd /etc/tinc/icvpn/
	.git/hooks/post-merge
	# go back to script dir
	cd -

	# copy tinc-up-down
	echo "(I) ${green}icvpn tinc: Copy up/down scripts${col_reset}"
	\cp -f etc/tinc/icvpn/tinc-up /etc/tinc/icvpn/
	\cp -f etc/tinc/icvpn/tinc-down /etc/tinc/icvpn/

	# modify icvpn addresses
	echo "(I) ${green}icvpn tinc: Set interface addresses for icvpn${col_reset}"
	sed -i "s/ICVPN_IPV4_ADDR/$icvpn_ipv4_addr/g" /etc/tinc/icvpn/tinc-up
	sed -i "s/ICVPN_IPV6_ADDR/$icvpn_ipv6_addr/g" /etc/tinc/icvpn/tinc-up
	sed -i "s/ICVPN_IPV4_ADDR/$icvpn_ipv4_addr/g" /etc/tinc/icvpn/tinc-down
	sed -i "s/ICVPN_IPV6_ADDR/$icvpn_ipv6_addr/g" /etc/tinc/icvpn/tinc-down

	# create RSA keypair if none available
	if [ ! -f /etc/tinc/icvpn/rsa_key.priv -o ! -f /etc/tinc/icvpn/hosts/$icvpn_hostname ]; then
		echo "(I) ${green}icvpn tinc: Create key pair${col_reset}"
		echo "(I) ${green}---- PRESS ENTER (2x)------${col_reset}"
		tincd -n icvpn -K	

		sed -i '1i\Address = '$ff_servername'.freifunk-'$community_id'.de' /etc/tinc/icvpn/hosts/$icvpn_hostname
	fi

	# start tinc
	echo "(I) ${green}icvpn tinc: Start tinc daemon${col_reset}"
	service tinc@icvpn start
	# make persistent
	systemctl enable tinc@icvpn

} # tinc

# bird
{
	echo "(I) ${green}icvpn bird: Install bird/bird6 package${col_reset}"
	apt install --assume-yes git bird

	echo "(I) ${green}icvpn bird: copy bird config${col_reset}"
	\cp -f etc/bird/bird.conf /etc/bird/
	\cp -f etc/bird/bird6.conf /etc/bird/

	# insert bird addresses and AS number
	echo "(I) ${green}icvpn bird: Set interface addresses and AS number${col_reset}"
	sed -i "s/ICVPN_IPV4_ADDR/$icvpn_ipv4_addr/g" /etc/bird/bird.conf
	sed -i "s/MESH_IPV4_ADDR/$mesh_ipv4_addr/g" /etc/bird/bird.conf
	sed -i "s/AS_NUMBER/$as_number/g" /etc/bird/bird.conf

	sed -i "s/ICVPN_IPV4_ADDR/$icvpn_ipv4_addr/g" /etc/bird/bird6.conf
	sed -i "s/MESH_IPV6_ADDR/$mesh_ipv6_addr/g" /etc/bird/bird6.conf
	sed -i "s/AS_NUMBER/$as_number/g" /etc/bird/bird6.conf

	# create icvpn table shortcut if it does not exist yet
	ip route show table icvpn &> /dev/null || echo 200 icvpn >> /etc/iproute2/rt_tables

	# start bird
	echo "(I) ${green}icvpn bird: Start bird/bird6 daemons${col_reset}"
	service bird start
	systemctl enable bird
	service bird6 start
	systemctl enable bird6
} # bird

exit 0
