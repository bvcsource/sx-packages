#!/bin/bash
#

set -x
set -e

export HOME="/home/build"

cd $HOME

whoami
unset http_proxy

if [ -z "$VERSION" -o -z "$IS_RELEASE" -o -z "$PRODUCT" ]; then
    echo "Required environment variables are not set"
    exit 1
fi

echo "TOP directory is: $HOME"
mkdir -p /home/build/packages
cp -a /home/build/rpmbuild /home/build/packages/

RELEASEBASE="0.1.`date +%Y%m%d`git"
COMMITVER=$(cd $HOME/${PRODUCT}.git && git rev-parse --short HEAD)

if test "$IS_RELEASE" = "yes"; then
    RELEASE=1
    # this is a counter, i.e. if things got changed in the package only
    # since same release
else
    RELEASE="$RELEASEBASE$COMMITVER"
fi

SOURCES=$HOME/packages/rpmbuild/SOURCES

SOURCE="$PRODUCT-$VERSION-$RELEASE.tar"
(cd $HOME/${PRODUCT}.git && \
    git archive --format=tar HEAD --prefix=${PRODUCT}-${VERSION}/ -o $SOURCES/$SOURCE)
# TODO: srpm

echo "Building source package for $SOURCE"
sed -e "s/@VER@/$VERSION/" -e "s/@RELEASE@/$RELEASE/" \
    $HOME/packages/rpmbuild/SPECS/${PRODUCT}.spec >${PRODUCT}.spec

rpmbuild -bb ${PRODUCT}.spec

sxcp $HOME/packages/rpmbuild/RPMS/*/*.rpm \
    sx://indian.skylable.com/vol-packages/experimental-${PRODUCT}/fedora/24/

