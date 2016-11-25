#!/bin/sh
# Docker doesn't support symlink, so copy all files https://github.com/docker/docker/pull/8420

PKG=skylable-sx
INIT=sxserver

# centos5 won't be updated by these rules, too old and would require too many
# conditionals. if needed manually update it.
# centos6, 7 and fedora21 is kept close to official fedora21/22/rawhide packages
# except centos uses initscripts and no selinux due to docker
for i in centos6 centos7 fedora21; do
    mkdir -p $i/packages/rpmbuild/SPECS $i/packages/rpmbuild/SOURCES/
    cp skylable-sx.spec $i/packages/rpmbuild/SPECS/
    cp skylable-sx.spec $i/
    sed -i -e "s/@VER@/0.0/" -e "s/@RELEASE@/1/" $i/$PKG.spec
    if [ $i != "fedora21" ]; then
        cp fedora21/packages/rpmbuild/SOURCES/* $i/packages/rpmbuild/SOURCES/
    fi
done

PKG=sx
for i in wheezy jessie-32 precise; do
    mkdir -p $i/packages/deb/$PKG/
    if [ $i != "wheezy" ]; then
        cp -a wheezy/packages/deb/* $i/packages/deb/
    fi
done
