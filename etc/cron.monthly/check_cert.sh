#!/bin/sh
service lighttpd stop

if [ ! -d /etc/letsencrypt/live/ ]; then
  if ! certbot certonly -n -q -m info@freifunk-ulm.de --agree-tos --keep --standalone -d $(hostname) > /var/log/letsencrypt/getcert.log 2>&1 ; then
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

cat /etc/letsencrypt/live/$(hostname)/privkey.pem /etc/letsencrypt/live/$(hostname)/cert.pem > /etc/letsencrypt/live/$(hostname)/ssl.pem

service lighttpd start
