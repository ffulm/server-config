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
	sha256check "batman-adv-$batman_version.tar.gz" "a12a32d1ec65b94b54ca86e6f31ac1b947bf04449aad0c96dfe936746bd0c585"
	tar -xzf batman-adv-$batman_version.tar.gz
	cd batman-adv-$batman_version/
	make CONFIG_BATMAN_ADV_DEBUGFS=y
	make CONFIG_BATMAN_ADV_DEBUGFS=y install
	cd ..
	rm -rf batman-adv-$batman_version*

	#install batctl
	wget -N --no-check-certificate http://downloads.open-mesh.org/batman/releases/batman-adv-$batman_version/batctl-$batman_version.tar.gz
	sha256check "batctl-$batman_version.tar.gz" "60efe9b148f66aa1b29110493244dc9f1f1d722e6d96969e4d4b2c0ab9278104"
	tar -xzf batctl-$batman_version.tar.gz
	cd batctl-$batman_version/
	make
	make install
	cd ..
	rm -rf batctl-$batman_version*

	#install alfred
	wget -N --no-check-certificate http://downloads.open-mesh.org/batman/stable/sources/alfred/alfred-$batman_version.tar.gz
	sha256check "alfred-$batman_version.tar.gz" "1505bcb235289baaad25a5001a0189e4f16e5c4f023db62a8682c0eb91b162c0"
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
	wget -N --no-check-certificate -O libsodium-1.0.18.tar.gz https://download.libsodium.org/libsodium/releases/libsodium-1.0.18-stable.tar.gz
	sha256check "libsodium-1.0.18.tar.gz" "34a97c73c08e12e53200eda968a03b8076e06112947906e0e614ddae93e74093"
	tar -xvzf libsodium-1.0.18.tar.gz
	cd libsodium-stable
	./configure
	make
	make install
	cd ..
	rm -rf libsodium-*
	ldconfig

	echo "(I) ${green}Build and install libuecc${col_reset}"

	#install libuecc
	wget -N --no-check-certificate https://git.universe-factory.net/libuecc/snapshot/libuecc-7.tar -O libuecc-7.tar
	sha256check "libuecc-7.tar" "0120aee869f56289204255ba81535369816655264dd018c63969bf35b71fd707"
	tar xf libuecc-7.tar
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
	wget -N --no-check-certificate https://git.universe-factory.net/fastd/snapshot/fastd-18.tar -O fastd-18.tar
	sha256check "fastd-18.tar" "dce99ee057f43e3d732a120fb0cb60acb3b86e8231d3dd64ab72fc1254c2491a"
	tar xf fastd-18.tar
	mkdir fastd_build
	cd fastd_build
	# -D is workaround needed till fastd-19
	cmake ../fastd-18 -DWITH_CIPHER_AES128_CTR_NACL=OFF
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

