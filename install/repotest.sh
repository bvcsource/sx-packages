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


REPOHOST=vol-repo.s3.indian.skylable.com/testing
#REPOHOST=cdn.skylable.com

echo Starting test of repository $REPOHOST in 3 secs...
sleep 3

# debian 32 bit
docker run --rm -e REPOHOST=$REPOHOST -e PKG=sx -e VER=$SX_VER -e DIST=jessie -v `pwd`/:/root/install 32bit/debian:jessie /root/install/install-deb.sh

# debian
for i in wheezy jessie;do
	docker run --rm -e REPOHOST=$REPOHOST -e PKG=sx -e VER=$SX_VER -e DIST=$i -v `pwd`/:/root/install debian:$i /root/install/install-deb.sh
	docker run --rm -e REPOHOST=$REPOHOST -e PKG=libres3 -e VER=$LIBRES3_VER -e DIST=$i -v `pwd`/:/root/install debian:$i /root/install/install-deb.sh
done

docker run --rm -e REPOHOST=$REPOHOST -e PKG=sxdrive -e VER=$SXDRIVE_VER -e DIST=jessie -v `pwd`/:/root/install debian:jessie /root/install/install-deb.sh
docker run --rm -e REPOHOST=$REPOHOST -e PKG=sxscout -e VER=$SXDRIVE_VER -e DIST=jessie -v `pwd`/:/root/install debian:jessie /root/install/install-deb.sh

# ubuntu
for i in precise trusty xenial yakkety; do
	docker run --rm -e REPOHOST=$REPOHOST -e PKG=sx -e VER=$SX_VER -e DIST=$i -v `pwd`/:/root/install ubuntu:$i /root/install/install-deb.sh
	docker run --rm -e REPOHOST=$REPOHOST -e PKG=libres3 -e VER=$LIBRES3_VER -e DIST=$i -v `pwd`/:/root/install ubuntu:$i /root/install/install-deb.sh
	if [ "$i" != "precise" ]; then
		docker run --rm -e REPOHOST=$REPOHOST -e PKG=sxdrive -e VER=$SXDRIVE_VER -e DIST=$i -v `pwd`/:/root/install ubuntu:$i /root/install/install-deb.sh
		docker run --rm -e REPOHOST=$REPOHOST -e PKG=sxscout -e VER=$SXDRIVE_VER -e DIST=$i -v `pwd`/:/root/install ubuntu:$i /root/install/install-deb.sh
	fi
done

# centos
for i in centos6 centos7; do
	docker run --rm -e REPOHOST=$REPOHOST -e PKG=skylable-sx -e VER=$SX_VER -e DIST=centos -v `pwd`/:/root/install centos:$i /root/install/install-rpm.sh
	docker run --rm -e REPOHOST=$REPOHOST -e PKG=libres3 -e VER=$LIBRES3_VER -e DIST=centos -v `pwd`/:/root/install centos:$i /root/install/install-rpm-epel.sh
done

docker run --rm -e REPOHOST=$REPOHOST -e PKG=sxdrive -e VER=$SXDRIVE_VER -e DIST=centos -v `pwd`/:/root/install centos:centos7 /root/install/install-rpm-epel.sh
docker run --rm -e REPOHOST=$REPOHOST -e PKG=sxscout -e VER=$SXDRIVE_VER -e DIST=centos -v `pwd`/:/root/install centos:centos7 /root/install/install-rpm-epel.sh

# fedora
for i in 23 24; do
	docker run --rm -e REPOHOST=$REPOHOST -e PKG=skylable-sx -e VER=$SX_VER -e DIST=fedora -v `pwd`/:/root/install fedora:$i /root/install/install-rpm.sh
done
for i in 24; do
	docker run --rm -e REPOHOST=$REPOHOST -e PKG=libres3 -e VER=$LIBRES3_VER -e DIST=fedora -v `pwd`/:/root/install fedora:$i /root/install/install-rpm.sh
done
for i in 23 24; do
	docker run --rm -e REPOHOST=$REPOHOST -e PKG=sxdrive -e VER=$SXDRIVE_VER -e DIST=fedora -v `pwd`/:/root/install fedora:$i /root/install/install-rpm.sh
	docker run --rm -e REPOHOST=$REPOHOST -e PKG=sxscout -e VER=$SXDRIVE_VER -e DIST=fedora -v `pwd`/:/root/install fedora:$i /root/install/install-rpm.sh
done
