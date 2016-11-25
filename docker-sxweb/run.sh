#!/bin/bash

LISTENIP=10.0.204.98
# sxcert.pem and sxkey.pem
SXWEBCERT=/root/nginx/ssl

docker run --privileged -p $LISTENIP:80:80 -p $LISTENIP:443:443 \
	-d \
	--restart=always \
	-v /var/www/sxweb:/var/www/sxweb \
	-v $SXWEBCERT:/etc/nginx/ssl \
	sxweb /usr/bin/init.sh

