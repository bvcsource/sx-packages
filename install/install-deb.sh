#!/bin/bash

set -x
set -e

if [ -z "$DIST" ] || [ -z "$PKG" ] || [ -z "$REPOHOST" ]; then
	echo Syntax: $0 distro pkg
	exit 1
fi

apt-key add /root/install/GPG-KEY-skylable.asc 

echo "deb http://$REPOHOST/debian $DIST main" >>/etc/apt/sources.list
sed -i 's/archive.ubuntu.com/pl.archive.ubuntu.com/' /etc/apt/sources.list

apt-get update && \
    apt-get install -y $PKG && \
    (apt-cache show $PKG | grep ^Version | grep $VER) 

