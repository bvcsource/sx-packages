#!/bin/sh
#
# Requirements: have an SX git source repository at ../sx, and an
# LibreS3 git source repository at ../libres3

VERSION=0.4
IS_RELEASE=no

set -x
set -e

DISTS="wheezy precise"

TOPDIR=$(dirname $(readlink -f $0))/../
echo "TOP directory is: $TOPDIR"

# for now
rm -rf mirror/dists/ mirror/pool/ mirror/db

#killall -q gpg-agent || true
#eval $(gpg-agent --daemon)
#export GPG_AGENT_INFO
#GPG_TTY=$(tty)
#export GPG_TTY
#export GPGKEY=0xB4B3C2E8AC11BD41
#export DEBEMAIL="dev-team@skylable.com"
#export DEBFULLNAME="Skylable Dev Team"

echo "Cleaning build dir"

# temporary dir removed before each build: tmp
rm -rf tmp && mkdir tmp && cd tmp
TMPDIR=`pwd`

build_package () {
    packagepath="$1"
    basever="$2"
    dist="$3"
    shift 3
    arches=$*
    package=`basename $packagepath`
    echo "Exporting git sources for $package"
    COMMITVER=$(cd $TOPDIR/$packagepath && git rev-parse --short HEAD)
    if test "$IS_RELEASE" = "yes"; then
        UPSTREAMVERSION="$basever"
    else
        UPSTREAMVERSION="$basever-$COMMITVER"
    fi
    (cd $TOPDIR/$packagepath && git archive --format=tgz HEAD -o $TMPDIR/$package\_$UPSTREAMVERSION.orig.tar.gz)

    cd $TMPDIR
    # must use -1 because we use a - in UPSTREAMVERSION
    FULLVER=$UPSTREAMVERSION-1~$dist
    echo "Building source package for $package-$FULLVER"
    mkdir -p $package && cd $package
    cp -a $TOPDIR/deb/$package/debian .
    sed -i -re "s/$package \([^)]+\) /$package ($FULLVER) /" debian/changelog
    debuild -S -us -uc
#    debuild -S -us -uc
    DSC=../$package\_$FULLVER.dsc
    echo "Including source package $DSC on the mirror"
    #reprepro -Vb $TOPDIR/deb/mirror includedsc $dist $DSC
    for arch in $arches; do
        cd $TMPDIR/$package
        RESULT=$TMPDIR/incoming/$dist/$arch
        mkdir -p $RESULT
        echo "Building $package-$FULLVER on $arch"
        pbuilder-dist $dist $arch build --buildresult $RESULT $DSC 2>&1 | tee ../build.$dist.$arch
        echo "Including binary package of $package-$FULLVER on $arch"
        cd $TOPDIR/deb
        reprepro -Vb mirror includedeb $dist $RESULT/*.deb
    done
}

arches="amd64"
for dist in $DISTS; do
    build_package ../sx $VERSION $dist $arches
done
