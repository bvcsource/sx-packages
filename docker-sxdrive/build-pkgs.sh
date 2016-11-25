#!/bin/bash

DOCKREPO=registry.sxps.vpn.skylable.com
SXAUTH=$HOME/.sx
DEST=`pwd`/../
TEMPFILE=$(mktemp)

if [ -z "$1" ]; then
        echo "Syntax: $0 version"
        exit 1
fi

SRCVERSION=$1

if ! [ -r "$SXAUTH/indian.skylable.com/auth/default" ]; then
   echo No sx auth key found in $SXAUTH . You need to sxinit sx://indian.skylable.com with an account that can upload to vol-packages
   exit
fi

DOCKOPTS="-v $SXAUTH:/root/.sx -v $DEST/docker-sxdrive/sxdrive.git:/root/sxdrive.git -t -i --rm -e SRCVERSION=$SRCVERSION"

rm -f screenlog.?

./update-images.sh
if [ $? -ne 0 ]; then
	echo You MUST update the images first.
	exit 1
fi

set -x
# RPMs
for i in centos7 fedora23; do
	CNAME=pkg-${i}_sxdrive
	echo screen -t $i -L docker run -u makerpm $DOCKOPTS $DOCKREPO/$CNAME /usr/bin/build.sh >>$TEMPFILE
	echo split >>$TEMPFILE
	echo focus >>$TEMPFILE
done
# DEBs
for i in jessie trusty; do
	CNAME=pkg-${i}_sxdrive
	echo screen -t $i -L docker run $DOCKOPTS $DOCKREPO/$CNAME /usr/bin/build.sh >>$TEMPFILE
	echo split >>$TEMPFILE
	echo focus >>$TEMPFILE
done
unset x

head -n -2 $TEMPFILE >${TEMPFILE}.tmp
mv ${TEMPFILE}.tmp $TEMPFILE
screen -L -c $TEMPFILE
rm -f $TEMPFILE

