#!/bin/bash

unset https_proxy

set -e

SOURCE=sx://indian.skylable.com/vol-packages/
DESTREPO="sx://indian.skylable.com/$REPO_ROOT/debian/"

echo ###################
echo Updating vol-repo to SX $SX_VER LibreS3 $LIBRES3_VER SXDrive $SXDRIVE_VER
echo ###################

JESSIE_COMPATIBLE="jessie sid"
TRUSTY_COMPATIBLE="trusty utopic vivid"
WHEEZY_COMPATIBLE="wheezy $JESSIE_COMPATIBLE $TRUSTY_COMPATIBLE"
ROOT=debian

cd $HOME
rm -rf $ROOT/db $ROOT/dists $ROOT/pool

prepare_package() {
    package=$1
    VERSION=$2
    #reprepro -Vb $ROOT includedsc $dist $DSC
    sxcp -q -r $SOURCE/experimental-$package/debian/*${package}*_$VERSION-*wheezy*deb .
    sxcp -q -r $SOURCE/experimental-$package/debian/*${package}*_$VERSION-*jessie*deb . || true
    # delete spurious git packages which have been just downloaded
    rm -f *${package}*git*wheezy*.deb || true
    for dist in $WHEEZY_COMPATIBLE; do
        reprepro -Vb $ROOT includedeb $dist *${package}*_$VERSION-*wheezy*deb
    done
    for dist in $JESSIE_COMPATIBLE; do
        reprepro -Vb $ROOT includedeb $dist *${package}*_$VERSION-*jessie*deb || true
    done

    sxcp -q -r $SOURCE/experimental-$package/ubuntu/*${package}*_$VERSION-*precise*deb .
    rm -f *${package}*git*precise*.deb || true
    # old, not compatible with wheezy
    reprepro -Vb $ROOT includedeb precise *${package}*_$VERSION-*precise*deb
}
prepare_package sx $SX_VER
prepare_package libres3 $LIBRES3_VER

# sxdrive uses different naming
dist=jessie
sxcp -q -r $SOURCE/experimental-sxdrive/*/sxdrive_${SXDRIVE_VER}-*${dist}*.deb .
rm -f sxdrive*git*.deb || true
for destdist in $JESSIE_COMPATIBLE; do
	reprepro -Vb $ROOT includedeb $destdist sxdrive_${SXDRIVE_VER}-*${dist}*.deb
done
dist=trusty
sxcp -q -r $SOURCE/experimental-sxdrive/*/sxdrive_${SXDRIVE_VER}-*${dist}*.deb .
rm -f sxdrive*git*.deb || true
for destdist in $TRUSTY_COMPATIBLE; do
	    reprepro -Vb $ROOT includedeb $destdist sxdrive_${SXDRIVE_VER}-*${dist}*.deb
done
dist=

# UPLOAD
echo Syncing repository to vol-repo in 5 secs, CTRL+C to abort
sleep 5

sxrm -r $DESTREPO || true
sxcp -q -r $ROOT/dists $ROOT/pool $DESTREPO

