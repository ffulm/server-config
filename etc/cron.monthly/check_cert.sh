#!/bin/sh
service lighttpd stop

if [ ! -d /etc/letsencrypt/live/ ]; then
  if ! certbot certonly -n -q -m info@freifunk-ulm.de --agree-tos --keep --standalone -d $(hostname).freifunk-ulm.de > /var/log/letsencrypt/getcert.log 2>&1 ; then
      echo "Could not obtain cert:"
      cat /var/log/letsencrypt/getcert.log
      exit 1
  fi
else
  # test renewal (monthly)
  if ! certbot renew ; then
      echo "Automated renewal failed:"
      cat /var/log/letsencrypt/renew.log
      exit 1
  fi
fi

cat /etc/letsencrypt/live/$(hostname).freifunk-ulm.de/privkey.pem /etc/letsencrypt/live/$(hostname).freifunk-ulm.de/cert.pem > /etc/letsencrypt/live/$(hostname).freifunk-ulm.de/ssl.pem

service lighttpd start
