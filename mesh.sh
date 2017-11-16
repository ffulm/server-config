#!/bin/bash

sha256check() {
	local file="$1" hash="$2"
	if [ "$(sha256sum $file | cut -b 1-64)" != "$hash" ]; then
		echo "(E) ${red}Hash mismatch: $file${col_reset}"
		exit 1
	fi
}

echo "${green}***************************${col_reset}"
echo "${green}* set up meshing software *${col_reset}"
echo "${green}***************************${col_reset}"

{
	echo "(I) ${green}Install batman-adv, batctl and alfred ($batman_version).${col_reset}"
	apt install --assume-yes wget build-essential linux-headers-$(uname -r) pkg-config libnl-3-dev libjson-c-dev git libcap-dev pkg-config libnl-genl-3-dev

	#install batman-adv
	wget -N --no-check-certificate http://downloads.open-mesh.org/batman/releases/batman-adv-$batman_version/batman-adv-$batman_version.tar.gz
	sha256check "batman-adv-$batman_version.tar.gz" "830edd297ff11b91623e9612172db3e2b2c1524e2f9b2ca1cb243e2e3f0ba4d4"
	tar -xzf batman-adv-$batman_version.tar.gz
	cd batman-adv-$batman_version/
	make
	make install
	cd ..
	rm -rf batman-adv-$batman_version*

	#install batctl
	wget -N --no-check-certificate http://downloads.open-mesh.org/batman/releases/batman-adv-$batman_version/batctl-$batman_version.tar.gz
	sha256check "batctl-$batman_version.tar.gz" "29c7f075023e02ed9a9299008ec73cfdb4e1b04991d27e4f396131b4059b88a8"
	tar -xzf batctl-$batman_version.tar.gz
	cd batctl-$batman_version/
	make
	make install
	cd ..
	rm -rf batctl-$batman_version*

	#install alfred
	wget -N --no-check-certificate http://downloads.open-mesh.org/batman/stable/sources/alfred/alfred-$batman_version.tar.gz
	sha256check "alfred-$batman_version.tar.gz" "c2963523ba86746476db9bbd820b7956761b362d5daa392d9ed471786eaf0208"
	tar -xzf alfred-$batman_version.tar.gz
	cd alfred-$batman_version/
	make CONFIG_ALFRED_GPSD=n CONFIG_ALFRED_VIS=n
	make CONFIG_ALFRED_GPSD=n CONFIG_ALFRED_VIS=n install
	cd ..
	rm -rf alfred-$batman_version*
}

{
	# set capablilities for alfred binary (create sockets and use elevated privs)
	# got reset by installation of new alfred binary above
	setcap cap_net_admin,cap_net_raw+ep `which alfred`

	# create alfred group
	addgroup --system alfred

	echo "(I) ${green}Create user alfred for alfred daemon.${col_reset}"
	adduser --system --home /var/run/alfred --shell /bin/false --ingroup alfred --disabled-password alfred
}

{
	echo "(I) ${green}Install fastd prerequisites${col_reset}"

	apt install --assume-yes git cmake-curses-gui libnacl-dev flex bison libcap-dev pkg-config zip libjson-c-dev

	echo "(I) ${green}Build and install libsodium${col_reset}"

	#install libsodium
	wget -N --no-check-certificate -O libsodium-1.0.14.tar.gz http://github.com/jedisct1/libsodium/releases/download/1.0.14/libsodium-1.0.14.tar.gz
	sha256check "libsodium-1.0.14.tar.gz" "3cfc84d097fdc891b40d291f2ac2c3f99f71a87e36b20cc755c6fa0e97a77ee7"
	tar -xvzf libsodium-1.0.14.tar.gz
	cd libsodium-1.0.14
	./configure
	make
	make install
	cd ..
	rm -rf libsodium-1.0.14*
	ldconfig

	echo "(I) ${green}Build and install libuecc${col_reset}"

	#install libuecc
	wget -N --no-check-certificate https://projects.universe-factory.net/attachments/download/85 -O libuecc-7.tar.xz
	sha256check "libuecc-7.tar.xz" "b94aef08eab5359d0facaa7ead2ce81b193eef0c61379d9835213ebc0a46257a"
	tar xf libuecc-7.tar.xz
	mkdir libuecc_build
	cd libuecc_build
	cmake ../libuecc-7
	make
	make install
	cd ..
	rm -rf libuecc_build libuecc-7*
	ldconfig

	echo "(I) ${green}Build and install fastd${col_reset}"

	#install fastd
	wget -N --no-check-certificate https://projects.universe-factory.net/attachments/download/86 -O fastd-18.tar.xz
	sha256check "fastd-18.tar.xz" "714ff09d7bd75f79783f744f6f8c5af2fe456c8cf876feaa704c205a73e043c9"
	tar xf fastd-18.tar.xz
	mkdir fastd_build
	cd fastd_build
	cmake ../fastd-18
	make
	make install
	cd ..
	rm -rf fastd_build fastd-18*
}

{
	echo "(I) ${green}Configure fastd${col_reset}"
	cp -r etc/fastd /etc/

	if [ -z "$fastd_secret" ]; then
		echo "(I) ${green}Create fastd public/private key pair. This may take a while...${col_reset}"
		fastd_secret=$(fastd --generate-key --machine-readable)
	fi
	echo "secret \"$fastd_secret\";" >> /etc/fastd/fastd.conf
	fastd_key=$(echo "secret \"$fastd_secret\";" | fastd --config - --show-key --machine-readable)
	echo "#key \"$fastd_key\";" >> /etc/fastd/fastd.conf

	sed -i "s/eth0/$wan_iface/g" /etc/fastd/fastd.conf
}

if ! id nobody >/dev/null 2>&1; then
	echo "(I) ${green}Create user nobody for fastd.${col_reset}"
	useradd --system --no-create-home --shell /bin/false nobody
fi


exit 0

