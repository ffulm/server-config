#!/bin/bash

echo "${green}********************${col_reset}"
echo "${green}* set up webserver *${col_reset}"
echo "${green}********************${col_reset}"


{
	echo "(I) ${green}Install lighttpd${col_reset}"
	apt install --assume-yes lighttpd php-cgi
	# generate strong DH primes - takes a very long time!
	# run only if pem file is missing
	if [ ! -f /etc/ssl/certs/dhparam.pem ]; then
		echo "(I) ${green} Generating DH primes - be patient!${col_reset}"
		openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096
	fi
}

{
	echo "(I) ${green}Create /etc/lighttpd/lighttpd.conf${col_reset}"
	cp etc/lighttpd/lighttpd.conf /etc/lighttpd/
	sed -i "s/fdef:17a0:fff1:300::1/$mesh_ipv6_addr/g" /etc/lighttpd/lighttpd.conf
	sed -i "s/SERVERNAME/$ff_servername.freifunk-$community_id.de/g" /etc/lighttpd/lighttpd.conf
}

if ! id www-data >/dev/null 2>&1; then
	echo "(I) ${green}Create user/group www-data for lighttpd.${col_reset}"
	useradd --system --no-create-home --user-group --shell /bin/false www-data
fi

{
	echo "(I) ${green}Populate /var/www${col_reset}"
	mkdir -p /var/www/
	cp -r var/www/* /var/www/

	# every router's homepage links to this neighbourhood page
	echo "(I) ${green}substitute hostname in JSON info file${col_reset}"
	sed -i "s/SERVERNAME/$ff_servername/g" /var/www/cgi-bin/data
	# customize simple index.html for server
	sed -i "s/SERVERNAME/$ff_servername/g" /var/www/index.html

	# owner of webfiles should be webserver
	chown -R www-data:www-data /var/www
}


{
	# remove build remains
	rm -rf /opt/letsencrypt/

	# get certbot
	apt install --assume-yes certbot

	# get letsencrypt client
	#echo "(I) ${green}Populate /opt/letsencrypt/${col_reset}"
	#git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt/

	# copy cert renewal script
	# backslash is for unaliased version of cp (no user interaction)
	\cp etc/cron.daily/check_cert.sh /etc/cron.daily/
	
	mkdir -p /var/log/letsencrypt/
	touch /var/log/letsencrypt/renew.log
	touch /var/log/letsencrypt/getcert.log

	# call once to get initial cert
	echo "(I) ${green}Get Letsencrypt Certificate... This can take some time!${col_reset}"
	/etc/cron.daily/check_cert.sh

}

exit 0
