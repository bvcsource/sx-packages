#!/bin/sh
#

export HOME="/home/build"
dist=precise

cd $HOME

whoami
unset http_proxy

if [ -z "$VERSION" -o -z "$IS_RELEASE" -o -z "$PRODUCT" ]; then
    echo "Required environment variables are not set"
    exit 1
fi

set -x
set -e

echo "TOP directory is: $HOME"
mkdir $HOME/$PRODUCT
cp -a $HOME/${PRODUCT}.git/. $HOME/$PRODUCT/.
cp -a $HOME/debian $HOME/$PRODUCT/

RELEASEBASE="0.1.`date +%Y%m%d`git"
COMMITVER=$(cd $HOME/$PRODUCT && git rev-parse --short HEAD)

if test "$IS_RELEASE" = "yes"; then
    RELEASE=1
    # this is a counter, i.e. if things got changed in the package only
    # since same release
else
    RELEASE="$RELEASEBASE$COMMITVER"
fi

SOURCES=$HOME/$PRODUCT

SOURCE="${PRODUCT}_$VERSION-$RELEASE.orig.tar.gz"
(cd $SOURCES && \
    git archive --format=tgz HEAD --prefix=$PRODUCT-$VERSION/ -o $SOURCES/$SOURCE)

FULLVER=$VERSION-$RELEASE-1~$dist
echo "Building source package for $package-$FULLVER"

cd $SOURCES/
sed -i -re "s/$package \([^)]+\) /$package ($FULLVER) /" debian/changelog
debuild -b -j5 -us -uc -i

sxcp $HOME/${PRODUCT}_${FULLVER}*.deb \
    sx://indian.skylable.com/vol-packages/experimental-${PRODUCT}/ubuntu/


