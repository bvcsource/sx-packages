#!/bin/bash

GITREPO=sxdrive.git

if [ -d "$GITREPO" ]; then
	echo "Update $GITREPO repo? (Y/n) "
	read UPDATEREPO
else
	UPDATEREPO=Y
fi

if [ "$UPDATEREPO" == "Y" ]; then
	echo Update $GITREPO repo in 3 secs...
	sleep 3
	rm -rf $GITREPO && \
		git clone git+ssh://edwin@git.dev.skylable.com/home/git/$GITREPO $GITREPO
	if [ $? -ne 0 ]; then
		exit 1
	fi
fi

echo "Update docker images? (Y/n) "
read UPDATEIMG
if [ "$UPDATEIMG" != "Y" ]; then
	exit
fi

for i in jessie trusty fedora23 centos7;do
	pushd $i
	rm -rf $GITREPO && \
		cp -a ../$GITREPO $GITREPO && \
		set -x 
		docker build --no-cache --rm -t registry.sxps.vpn.skylable.com/pkg-${i}_sxdrive . && \
		unset x
		rm -rf $GITREPO 
	if [ $? -ne 0 ]; then
		exit 1
	fi
	popd
done
