#!/bin/bash -x

unset https_proxy

set -e

SOURCE=sx://indian.skylable.com/vol-packages/
DESTREPO="sx://indian.skylable.com/$REPO_ROOT/debian/"

echo ###################
echo Updating volume to SX $SX_VER LibreS3 $LIBRES3_VER SXDrive $SXDRIVE_VER
echo ###################

JESSIE_COMPATIBLE="jessie"
TRUSTY_COMPATIBLE="trusty xenial"
WHEEZY_COMPATIBLE="wheezy $JESSIE_COMPATIBLE $TRUSTY_COMPATIBLE"
ROOT=debian

cd $HOME
rm -rf $ROOT/db $ROOT/dists $ROOT/pool

# set PGP key id
if [ -z "$KEY_ID" ]; then
	echo Please specify the PGP key id with -e KEY_ID=0x5377E192B7BC1D2E
	exit 1
fi
sed -i "s/SignWith: .*$/SignWith: $KEY_ID/" debian/conf/distributions


prepare_package() {
    package=$1
    VERSION=$2
    #reprepro -Vb $ROOT includedsc $dist $DSC
    sxcp -q -r $SOURCE/experimental-$package/debian/*${package}*_$VERSION-*wheezy*deb .
    sxcp -q -r $SOURCE/experimental-$package/debian/*${package}*_$VERSION-*jessie*deb . || true
    # delete spurious git packages which have been just downloaded
    rm -f *${package}*git*.deb || true
    ls
    for dist in $WHEEZY_COMPATIBLE; do
        reprepro -Vb $ROOT includedeb $dist *${package}*_$VERSION-*wheezy*deb
    done
    for dist in $JESSIE_COMPATIBLE; do
        reprepro -Vb $ROOT includedeb $dist *${package}*_$VERSION-*jessie*deb || true
    done

    sxcp -q -r $SOURCE/experimental-$package/ubuntu/*${package}*_$VERSION-*yakkety*deb . || true
    sxcp -q -r $SOURCE/experimental-$package/ubuntu/*${package}*_$VERSION-*precise*deb .
    # delete spurious git packages which have been just downloaded
    rm -f *${package}*git*.deb || true
    # old, not compatible with wheezy
    reprepro -Vb $ROOT includedeb precise *${package}*_$VERSION-*precise*deb
    reprepro -Vb $ROOT includedeb yakkety *${package}*_$VERSION-*yakkety*deb ||
    reprepro -Vb $ROOT includedeb yakkety *${package}*_$VERSION-*wheezy*deb
}
prepare_package sx $SX_VER
prepare_package libres3 $LIBRES3_VER

# sxdrive uses different naming
for SXDRIVE in sxdrive sxscout; do
	dist=jessie
	sxcp -q -r $SOURCE/experimental-${SXDRIVE}/*/${SXDRIVE}_${SXDRIVE_VER}-*${dist}*.deb .
	rm -f $SXDRIVE*git*.deb || true
	for destdist in $JESSIE_COMPATIBLE; do
		reprepro -Vb $ROOT includedeb $destdist ${SXDRIVE}_${SXDRIVE_VER}-*${dist}*.deb
	done
	dist=trusty
	sxcp -q -r $SOURCE/experimental-${SXDRIVE}/*/${SXDRIVE}_${SXDRIVE_VER}-*${dist}*.deb .
	rm -f $SXDRIVE*git*.deb || true
	for destdist in $TRUSTY_COMPATIBLE yakkety; do
		    reprepro -Vb $ROOT includedeb $destdist ${SXDRIVE}_${SXDRIVE_VER}-*${dist}*.deb
	done
done
dist=

# UPLOAD
echo Syncing repository to $DESTREPO in 5 secs, CTRL+C to abort
sleep 5

sxrm --mass -r $DESTREPO || true
sxcp -q -r $ROOT/dists $ROOT/pool $DESTREPO

