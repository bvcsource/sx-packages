#!/bin/bash
. ./common.sh

if [ "$#" -ne 3 ]; then
	echo Syntax: $0 VERSION IS_RELEASE GIT_TAG
	echo E.g.: $0 0.5 yes beta5
	exit 1
fi

PKG=libres3
VERSION=$1
IS_RELEASE=$2
GIT_TAG=$3
DOCKREPO=registry.sxps.vpn.skylable.com
SXAUTH=$HOME/.sx
TEMPFILE=$(mktemp)
DEST=$HOME/packages
GITREPO=$DEST/docker-${PKG}/${PKG}.git

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
                git clone http://git.skylable.com/${PKG} $GITREPO
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

mkdir -p tmp-sx
cp -a $SXAUTH ./tmp-sx/
chown 2000 -R ./tmp-sx
DOCKOPTS="-v $PWD/tmp-sx/.sx:/home/build/.sx:ro -v $GITREPO:/home/build/${PKG}.git:ro -t -i --rm -e IS_RELEASE=$IS_RELEASE -e VERSION=$VERSION -e PRODUCT=$PKG"
DOCKOPTS_DEB="-v $PWD/rules/debian:/home/build/debian:ro"
DOCKOPTS_RPM="-v $PWD/rules/rpmbuild/:/home/build/rpmbuild/:ro"

(
for i in centos6 centos7 fedora21; do
	echo docker run $DOCKOPTS $DOCKOPTS_RPM $DOCKREPO/pkg-${i}_${PKG} /usr/bin/build.sh
done
for i in wheezy precise; do
	echo docker run $DOCKOPTS $DOCKOPTS_DEB $DOCKREPO/pkg-${i}_${PKG} /usr/bin/build.sh
done
) | multirun
multirun_wait
rm -rf ./tmp-sx
