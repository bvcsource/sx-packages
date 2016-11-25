#!/bin/bash

set -x 
set -e

if [ -z "$DIST" ] || [ -z "$PKG" ] || [ -z "$REPOHOST" ]; then
        echo Syntax: $0 distro pkg
        exit 1
fi


cat >/etc/yum.repos.d/skylable.repo <<EOF
[skylable]
name=Skylable
baseurl=http://$REPOHOST/$DIST/\$releasever/\$basearch/
gpgcheck=1
gpgkey=file:///root/install/GPG-KEY-skylable.asc
EOF

yum clean all && \
   yum -y install $PKG && \
   (rpm -qa $PKG | grep $VER )
