#!/bin/bash

echo "${green}************************${col_reset}"
echo "${green}* set up map functions *${col_reset}"
echo "${green}************************${col_reset}"

# nur fuer map noetig
apt install --show-progress --assume-yes python3 python3-jsonschema


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



