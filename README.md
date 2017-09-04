Freifunk-Ulm Server
===============

Scripte und Konfigurationsdateien zum schnellen Einrichten eines Servers für Freifunk-Ulm.
Vorausgesetzt wird eine Debian 9 Installation (Stretch).
Um einen Server einzurichten, reicht es, das Script "setup.sh" als Benutzer 'root' auszuführen:

```
apt-get install git
git clone https://github.com/ffulm/server-config.git
cd server-config
./setup.sh
```

Nach erfolgreichem Einrichten wird das Script "/opt/freifunk/update.sh" alle 5 Minuten
von crond aufgerufen. Dadurch wird die Karte regelmäßig aktualisiert und nach
einem Neustart notwendige Programme neu gestartet.

### Server
Für die Serverfunktion werden folgende Programme installiert und automatisch konfiguriert:

 * Routingprotokoll: [batman-adv](http://www.open-mesh.org/projects/batman-adv/wiki)
 * FF-VPN: [fastd](https://projects.universe-factory.net/projects/fastd/wiki)
 * Webserver: lighttpd
 * Karte: [ffmap](https://github.com/ffnord/ffmap-d3)

### Gateway
Wird die Variable "setup_gateway" im Setup-Script auf "1" gesetzt, wird der Server zusätzlich
als Gateway eingerichtet. Das Script erwartet dann eine ZIP-Datei mit den Accountdaten
von mullvad.net oder AirVPN im gleichen Verzeichnis. Zum Testen eignet sich ein anonymer Testaccount
für drei Stunden.

Für die Gatewayfunktion werden folgende Programme installiert und automatisch konfiguriert:

 * NAT64: [tayga](http://www.litech.org/tayga/)
 * DNS64: bind
 * IPv6 Router Advertisment: radvd
 * Auslands-VPN: OpenVPN

### IPv4
Durch die Reaktivierung von IPv4 im Freifunk Netz werden weitere Dienste benötigt:
 * DHCP (isc-dhcp-server)

Alle Serverbetreiber müssen sich absprechen, was den Bereich der verteilten DHCP Adressen angeht, damit es zu keinen Adresskonflikten kommt. Bisher wurden folgende Bereiche vergeben:

 * vpn1: 10.33.64.1 range 10.33.64.2 10.33.67.255
 * vpn2: 10.33.68.1 range 10.33.68.2 10.33.71.255
 * vpn3: 10.33.72.1 range 10.33.72.2 10.33.75.255
 * vpn4: 10.33.76.1 range 10.33.76.2 10.33.79.255
 * vpn5: 10.33.80.1 range 10.33.80.2 10.33.83.255
 * vpn6: 10.33.84.1 range 10.33.84.2 10.33.87.255

 * vpn10: 10.33.10.1 range 10.33.10.2 10.33.13.255
 * vpn11: 10.33.14.1 range 10.33.14.2 10.33.17.255
 * vpn12: 10.33.18.1 range 10.33.18.2 10.33.21.255
 
Innerhalb des Freifunknetzes gibt es die DNS Zone ".ffulm". D.h. es können auch Namen wie "meinserver.ffulm" aufgelöst werden. Masterserver dafür ist zur Zeit vpn5.
Falls weitere Server hinzugefügt werden, müssen die Zonendateien auf dem Master (db.10.33, db.ffulm, named.conf.local) manuell angepasst werden. Hierzu bitte auf der Mailingliste melden.

### alfred
Des Weiteren sollte mindestens ein Server mit dem Schalter "-m" als alfred master betrieben werden. Zur Zeit ist dies map10.
https://github.com/ffulm/server-config/blob/master/freifunk/update.sh#L121

### Netz
Freifunk Ulm nutzt folgende Netze:
 * ipv4: ```10.33.0.0/16```
 * ipv6: ```fdef:17a0:fff1::/48```
 
Durchsatz und Statistiken
-----
Es wird munin auf den Gateways verwendet. Wenn dies nicht gewünscht wird, muss die Variable "setup_stats" auf "0" gesetzt werden. Die Software für munin clients wird automatisch eingerichtet, der master server für munin ist z.Z. map10.


ICVPN
-----
Folgende Adressen wurden im [Transfernetz des ICVPN] (https://github.com/freifunk/icvpn-meta/blob/master/ulm) für die Ulmer community reserviert:

vpn5
 * ipv4: ```10.207.0.105```
 * ipv6: ```fec0::a:cf:0:96```

vpn10
 * ipv4: ```10.207.0.151```
 * ipv6: ```fec0::a:cf:0:97```

Doku zu ICVPN bei FF Bielefeld: (veraltet)
https://wiki.freifunk-bielefeld.de/doku.php?id=ic-vpn

Tinc aus Debian jessie ist (angeblich) nicht stabil genug.
Tinc 1.11 pre selbst bauen:
https://gist.github.com/mweinelt/efff4fb7eba1ee41ef2d

ICVPN im Freifunk wiki:
https://wiki.freifunk.net/IC-VPN

DNS im Freifunk wiki:
https://wiki.freifunk.net/DNS

