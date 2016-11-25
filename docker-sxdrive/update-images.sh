#!/bin/bash

GITREPO=sxdrive.git

if [ -d "$GITREPO" ]; then
	echo "Update $GITREPO repo? (Y/n) "
	read UPDATEYN
else
	UPDATEYN=Y
fi

if [ "$UPDATEYN" == "Y" ]; then
	echo Update $GITREPO repo in 3 secs...
	sleep 3
	rm -rf $GITREPO && \
		git clone git+ssh://ro@git.dev.skylable.com/home/git/$GITREPO $GITREPO
	if [ $? -ne 0 ]; then
		exit 1
	fi
fi

for i in jessie trusty fedora21 centos7;do
	pushd $i
	rm -rf $GITREPO && \
		cp -a ../$GITREPO $GITREPO && \
		docker build --no-cache --rm -t registry.sxps.vpn.skylable.com/pkg-${i}_sxdrive . && \
		rm -rf $GITREPO 
	if [ $? -ne 0 ]; then
		exit 1
	fi
	popd
done
