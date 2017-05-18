#!/bin/bash

echo "${green}********************${col_reset}"
echo "${green}* set up webserver *${col_reset}"
echo "${green}********************${col_reset}"


{
	echo "(I) ${green}Install lighttpd${col_reset}"
	apt install --assume-yes lighttpd
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
	sed -i "s/fdef:17a0:fff1:300::1/$ip_addr/g" /etc/lighttpd/lighttpd.conf
	sed -i "s/SERVERNAME/$(hostname)/g" /etc/lighttpd/lighttpd.conf
}

if ! id www-data >/dev/null 2>&1; then
	echo "(I) ${green}Create user/group www-data for lighttpd.${col_reset}"
	useradd --system --no-create-home --user-group --shell /bin/false www-data
fi

{
	echo "(I) ${green}Populate /var/www${col_reset}"
	mkdir -p /var/www/
	cp -r var/www/* /var/www/
}

{
	#echo "(I) ${green}Add ffmap-d3${col_reset}"
	#apt install --assume-yes make git
	#git clone https://github.com/freifunk-bielefeld/ffmap-d3.git
	#cd ffmap-d3
	#sed -i "s/ffbi-/ffulm-/g" config.js
	#sed -i "s/gotham.freifunk.net/www.freifunk-$community_id.de/g" config.js
	#sed -i "s/gotham/$community_id/g" config.js
	#sed -i "s/Gotham/$community_name/g" config.js
	#sed -i "s/fdef:17a0:ffb1:300::/$ff_prefix/g" config.js
	#make
	#cp -r www/* /var/www/
	#cd ..
	#rm -rf ffmap-d3


	# remove build remains
	rm -rf meshviewer
	echo "(I) ${green}Add meshviewer${col_reset}"
	mkdir -p /var/www/meshviewer/
	apt install --assume-yes git npm nodejs-legacy ruby-sass
	git clone https://github.com/freifunk-bielefeld/meshviewer.git
	cd meshviewer
	npm install
	npm install grunt-cli
	node_modules/.bin/grunt
	# copy config to build
	cp ../etc/meshviewer/config.json build/
	# copy build to webroot
	cp -r build/* /var/www/meshviewer/
	cd ..
	# destroy build
	rm -rf meshviewer

	echo "(I) ${green}substitute hostname in JSON info file${col_reset}"
	sed -i "s/SERVERNAME/$(hostname)/g" /var/www/cgi-bin/data

	chown -R www-data:www-data /var/www
}

{
	# remove remains
	rm -rf /opt/letsencrypt/
	apt install --assume-yes certbot
	#git clone https://github.com/freifunk-bielefeld/ffmap-d3.git
	# get letsencrypt client
	echo "(I) ${green}Populate /opt/letsencrypt/${col_reset}"
	git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt/
	# copy cert renewal script
	cp -r opt/letsencrypt/* /opt/letsencrypt/
	mkdir -p /var/log/letsencrypt/
	touch /var/log/letsencrypt/renew.log

	# call once to get initial cert
	echo "(I) ${green}Get Letsencrypt Certificate... This can take some time!${col_reset}"
	/opt/letsencrypt/check_update_ssl.sh

	# add letsencrypt certificate renewal script to crontab
	if [ -z "$(cat /etc/crontab | grep '/opt/letsencrypt/check_update_ssl.sh')" ]; then
		echo "(I) ${green}Add certificate check entry to /etc/crontab${col_reset}"
		echo '0 3 16 * * root /opt/letsencrypt/check_update_ssl.sh > /dev/null' >> /etc/crontab
	fi
}

exit 0




