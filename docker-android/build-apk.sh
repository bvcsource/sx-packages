#!/bin/bash -x

CNAME=pkg-android
DEST=`pwd`/../docker-android
REPONAME=sxdrive-android.git
GITREPO=$DEST/$REPONAME

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
		git clone git+ssh://ro@git.dev.skylable.com/home/git/$REPONAME $GITREPO
	if [ $? -ne 0 ]; then
		exit 1
	fi
fi

echo Updating image in 3 secs
sleep 3
docker build --rm -t $CNAME .
#docker tag $CNAME $CNAME
#docker push $CNAME

echo Building apk in 3 secs
sleep 3
docker run -t -i --rm -v $GITREPO:/root/$REPONAME -v /root/.sx:/root/.sx $CNAME /usr/bin/build.sh

