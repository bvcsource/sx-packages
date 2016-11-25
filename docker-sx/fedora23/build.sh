#!/bin/sh
#
# Requirements: have an SX git source repository at ../sx, and an
# LibreS3 git source repository at ../libres3

export HOME="/home/makerpm"

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

set -x
set -e

if test `id -u` -eq 0; then
    echo "Must NOT run as root"
    echo "Run $0 as makerpm"
    exit 1
fi

echo "TOP directory is: $HOME"

echo "Exporting git sources for $package"
sudo cp -a /root/sx.git $HOME/sx 
sudo chown -R makerpm.makerpm $HOME/sx

RELEASEBASE="0.1.`date +%Y%m%d`git"
COMMITVER=$(cd /home/makerpm/sx && git rev-parse --short HEAD)

if test "$IS_RELEASE" = "yes"; then
    RELEASE=1
    # this is a counter, i.e. if things got changed in the package only
    # since same release
else
    RELEASE="$RELEASEBASE$COMMITVER"
fi

SOURCES=$HOME/packages/rpmbuild/SOURCES

SOURCE="sx-$VERSION-$RELEASE.tar"
(cd /home/makerpm/sx && \
    git archive --format=tar HEAD --prefix=sx-$VERSION/ -o $SOURCES/$SOURCE)

if test "$IS_RELEASE" = "yes"; then
    # ugly hack to disable extraversion in tarball
    sed -i -re 's/COMMITVER=[0-9a-f]+ /COMMITVER=ormat:%h/' $SOURCES/$SOURCE
fi

# TODO: libres3 srpm

echo "Building source package for $SOURCE"
sed -e "s/@VER@/$VERSION/" -e "s/@RELEASE@/$RELEASE/" $HOME/packages/rpmbuild/SPECS/skylable-sx.spec >skylable-sx.spec

rpmbuild -bb skylable-sx.spec

sudo yum -y --nogpgcheck install $HOME/packages/rpmbuild/RPMS/*/skylable-sx*-$VERSION-*.rpm

sudo -i sxcp -D $HOME/packages/rpmbuild/RPMS/*/*.rpm sx://indian.skylable.com/vol-packages/experimental-sx/fedora/23/

