#!/bin/bash
. ./common.sh
PKG=libres3
rm -rf */packages
for i in centos6 centos7 fedora24; do
        mkdir $i/packages
        # for yum-builddep
        sed -e "s/@VER@/0.0/" -e "s/@RELEASE@/1/" rules/rpmbuild/SPECS/$PKG.spec >tmp
        cmp tmp $i/$PKG.spec || cp tmp $i/$PKG.spec
done
for i in wheezy precise; do
        cp -a rules/debian $i/
done
(for i in centos6 centos7 fedora24 wheezy precise;do
	echo docker build --rm -t \
                    registry.sxps.vpn.skylable.com/pkg-${i}_${PKG} $i
    done) | multirun
multirun_wait

rm -rf */$PKG.spec wheezy/debian precise/debian
