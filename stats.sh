#!/bin/bash

echo "${green}*********************${col_reset}"
echo "${green}* set up statistics *${col_reset}"
echo "${green}*********************${col_reset}"

case "$munin_type" in
  "client")
	echo "(I) ${green} Setup statistic client (munin)${col_reset}"
	# get munin node package
	apt install --assume-yes munin-node
	cp -f etc/munin/munin-node.conf /etc/munin/
	# substitute hostname in munin-node.conf
	sed -i "s/host_name\ vpnX/host_name\ $ff_servername/g" /etc/munin/munin-node.conf
	# restart client
	/etc/init.d/munin-node restart
	;;

  "server") 
	echo "(I) ${green} Setup statistic server (munin)${col_reset}"
	# get munin package
	apt --assume-yes install munin

	cp -f etc/munin/munin.conf /etc/munin/

	# create webroot even if no webserver installed
        mkdir -p /var/www/munin/
	chown www-data.www-data /var/www/munin/
	# link to it
	ln -s /var/cache/munin/www/ /var/www/munin

	/etc/init.d/munin restart
	;;
   *)
	echo "(E) ${red} Provide \"client\" or \"server\" in setup.sh${col_reset}"
	exit 1
	;;
esac

# DEACTIVATED
#{
	# get vnstat backend
	#echo "(I) ${green} Setup statistic client (vnstat)${col_reset}"
	#apt install --assume-yes php5-cgi vnstat 
	# remove remains of vnstat frontend
	#rm -rf /var/www/vnstat/
	# get vnstat frontend anew
	#git clone https://github.com/bjd/vnstat-php-frontend /var/www/vnstat/
	#chown www-data.www-data /var/www/vnstat/
	# copy config
	#cp -f etc/vnstat.conf /etc/
	#cp -f etc/vnstat/config.php /var/www/vnstat/
	# add vnstat interface for main NIC
	#vnstat -u -i eth0
	# grant access for vnstat
	#chown vnstat.vnstat /var/lib/vnstat/eth0
#}


exit 0
