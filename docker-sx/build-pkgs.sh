#!/bin/bash

if [ "$#" -ne 3 ]; then
	echo Syntax: $0 VERSION IS_RELEASE GIT_TAG
	echo E.g.: $0 1.0 yes master
	exit 1
fi

VERSION=$1
IS_RELEASE=$2
GIT_TAG=$3
DOCKREPO=registry.sxps.vpn.skylable.com
SXAUTH=$HOME/.sx
DEST=$HOME/packages
TEMPFILE=$(mktemp)
GITREPO=$DEST/docker-sx/sx.git

if ! [ -r "$SXAUTH/indian.skylable.com/auth/default" ]; then
   echo No sx auth key found in $SXAUTH . You need to sxinit sx://indian.skylable.com with an account that can upload to vol-packages
   exit
fi

# update repo
if [ -d "$GITREPO" ]; then
        echo "Update $GITREPO repo? (Y/n) "
	read UPDATEYN
else
        UPDATEYN=Y
fi

if [ "$UPDATEYN" == "Y" ]; then
        echo Update repo in 3 secs...
        sleep 3
        rm -rf $GITREPO && \
                git clone http://git.skylable.com/sx $GITREPO
        if [ $? -ne 0 ]; then
                exit 1
        fi
fi
pushd $GITREPO && \
git checkout $GIT_TAG && \
popd
if [ $? -ne 0 ]; then
        exit 1
fi

DOCKOPTS="-v $SXAUTH:/root/.sx -v $GITREPO:/root/sx.git -t -i --rm -e IS_RELEASE=$IS_RELEASE -e VERSION=$VERSION"

#./update-images.sh
rm -f screenlog.?

# RPMs
FIRST="y"
for i in centos5 centos6 centos7 fedora21; do
	echo screen -t $i -L docker run -u makerpm $DOCKOPTS $DOCKREPO/pkg-${i}_sx /usr/bin/build.sh >>$TEMPFILE
	echo split >>$TEMPFILE
	echo focus >>$TEMPFILE
done
# DEBs
for i in wheezy jessie-32 precise; do
	echo screen -t $i -L docker run $DOCKOPTS $DOCKREPO/pkg-${i}_sx /usr/bin/build.sh >>$TEMPFILE
	echo split >>$TEMPFILE
	echo focus >>$TEMPFILE
done

head -n -2 $TEMPFILE >${TEMPFILE}.tmp
mv ${TEMPFILE}.tmp $TEMPFILE
echo Starting the build in 3 secs. CTRL+C to interrupt
cat $TEMPFILE
sleep 3
screen -L -c $TEMPFILE
rm -f $TEMPFILE

