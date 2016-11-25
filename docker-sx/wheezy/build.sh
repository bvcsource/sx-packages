#!/bin/bash
#
# Requirements: have an SX git source repository at ../sx, and an
# LibreS3 git source repository at ../libres3

export HOME="/home/build"
dist=wheezy

set -x
set -e

cd $HOME

whoami
unset http_proxy
unset https_proxy

if [ -z "$VERSION" ]; then
	VERSION=0.5
fi
if [ -z "$IS_RELEASE" ]; then
	IS_RELEASE=no
fi

echo "TOP directory is: $HOME"

echo "Exporting git sources for $package"
cp -a /root/sx.git/. $HOME/sx/.

RELEASEBASE="0.1.`date +%Y%m%d`git"
COMMITVER=$(cd $HOME/sx && git rev-parse --short HEAD)

if test "$IS_RELEASE" = "yes"; then
    RELEASE=1
    # this is a counter, i.e. if things got changed in the package only
    # since same release
else
    RELEASE="$RELEASEBASE$COMMITVER"
fi

SOURCES=$HOME/sx

SOURCE="sx_$VERSION-$RELEASE.orig.tar.gz"
(cd $SOURCES && \
    git archive --format=tgz HEAD --prefix=sx-$VERSION/ -o $SOURCES/$SOURCE)

FULLVER=$VERSION-$RELEASE-1~$dist
echo "Building source package for $package-$FULLVER"

cd $SOURCES/
sed -i -re "s/$package \([^)]+\) /$package ($FULLVER) /" debian/changelog
debuild -b -j5 -us -uc -i


/usr/bin/dpkg -i $HOME/*sx*_${FULLVER}*.deb
sxcp -D --config-dir=/root/.sx $HOME/*sx*_${FULLVER}*.deb sx://indian.skylable.com/vol-packages/experimental-sx/debian/

