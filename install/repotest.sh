#!/bin/bash

trap "echo ERROR $LINENO $code" ERR

set -x 
set -e

if [ -z $3 ]; then
    echo Syntax: $0 SX_VER LIBRES3_VER SXDRIVE_VER 
    echo E.g.: $0 1.0 1.0 0.4.0 
    exit 1
fi

SX_VER=$1
LIBRES3_VER=$2
SXDRIVE_VER=$3


REPOHOST=vol-repo.s3.indian.skylable.com:8008
#REPOHOST=cdn.skylable.com

echo Starting test of repository $REPOHOST in 3 secs...
sleep 3

# debian 32 bit
docker run -e REPOHOST=$REPOHOST -e PKG=sx -e VER=$SX_VER -e DIST=jessie -v `pwd`/:/root/install 32bit/debian:jessie /root/install/install-deb.sh

# debian
for i in wheezy jessie;do
	docker run -e REPOHOST=$REPOHOST -e PKG=sx -e VER=$SX_VER -e DIST=$i -v `pwd`/:/root/install debian:$i /root/install/install-deb.sh
	docker run -e REPOHOST=$REPOHOST -e PKG=libres3 -e VER=$LIBRES3_VER -e DIST=$i -v `pwd`/:/root/install debian:$i /root/install/install-deb.sh
done

docker run -e REPOHOST=$REPOHOST -e PKG=sxdrive -e VER=$SXDRIVE_VER -e DIST=jessie -v `pwd`/:/root/install debian:jessie /root/install/install-deb.sh

# ubuntu
for i in precise trusty vivid; do
	docker run -e REPOHOST=$REPOHOST -e PKG=sx -e VER=$SX_VER -e DIST=$i -v `pwd`/:/root/install ubuntu:$i /root/install/install-deb.sh
	docker run -e REPOHOST=$REPOHOST -e PKG=libres3 -e VER=$LIBRES3_VER -e DIST=$i -v `pwd`/:/root/install ubuntu:$i /root/install/install-deb.sh
done

docker run -e REPOHOST=$REPOHOST -e PKG=sxdrive -e VER=$SXDRIVE_VER -e DIST=trusty -v `pwd`/:/root/install ubuntu:trusty /root/install/install-deb.sh

# centos
docker run -e REPOHOST=$REPOHOST -e PKG=skylable-sx -e VER=$SX_VER -e DIST=centos -v `pwd`/:/root/install centos:centos5 /root/install/install-rpm.sh

for i in centos6 centos7; do
	docker run -e REPOHOST=$REPOHOST -e PKG=skylable-sx -e VER=$SX_VER -e DIST=centos -v `pwd`/:/root/install centos:$i /root/install/install-rpm.sh
	docker run -e REPOHOST=$REPOHOST -e PKG=libres3 -e VER=$LIBRES3_VER -e DIST=centos -v `pwd`/:/root/install centos:$i /root/install/install-rpm.sh
done

docker run -e REPOHOST=$REPOHOST -e PKG=sxdrive -e VER=$SXDRIVE_VER -e DIST=centos -v `pwd`/:/root/install centos:centos7 /root/install/install-rpm-epel.sh

# fedora
for i in 21; do
	docker run -e REPOHOST=$REPOHOST -e PKG=skylable-sx -e VER=$SX_VER -e DIST=fedora -v `pwd`/:/root/install fedora:$i /root/install/install-rpm.sh
	docker run -e REPOHOST=$REPOHOST -e PKG=libres3 -e VER=$LIBRES3_VER -e DIST=fedora -v `pwd`/:/root/install fedora:$i /root/install/install-rpm.sh
	docker run -e REPOHOST=$REPOHOST -e PKG=sxdrive -e VER=$SXDRIVE_VER -e DIST=fedora -v `pwd`/:/root/install fedora:$i /root/install/install-rpm.sh
done
# FIXME: add fedora22 packages for sx
docker run -e REPOHOST=$REPOHOST -e PKG=libres3 -e VER=$LIBRES3_VER -e DIST=fedora -v `pwd`/:/root/install fedora:22 /root/install/install-rpm.sh
docker run -e REPOHOST=$REPOHOST -e PKG=sxdrive -e VER=$SXDRIVE_VER -e DIST=fedora -v `pwd`/:/root/install fedora:22 /root/install/install-rpm.sh

