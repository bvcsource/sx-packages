#!/bin/bash

dist=fc20
BASEDIR=/home/makerpm

sudo cp -a /root/sxdrive.git $BASEDIR/sxdrive.git
sudo chown -R makerpm $BASEDIR/sxdrive.git
sudo ln -s /usr/lib64/qt5/bin/lrelease /usr/bin/lrelease

sed -i "s/SRCVERSION/$SRCVERSION/g" $BASEDIR/sxdrive.spec

cd $BASEDIR/sxdrive.git && \
	git archive --format=tar HEAD --prefix=sxdrive-$SRCVERSION/ -o $BASEDIR/rpmbuild/SOURCES/sxdrive-$SRCVERSION.tar && \
	cd $BASEDIR && \
	rpmbuild -bb sxdrive.spec
if [ $? -ne 0 ]; then
	echo Build failed
	exit 1
fi

cd $BASEDIR/rpmbuild/RPMS/x86_64/ && \
	for i in sxdrive*.rpm; do
                RPMNAME=$i
		sudo sxcp --config-dir=/root/.sx $i sx://indian.skylable.com/vol-packages/experimental-sxdrive/fedora/23/$RPMNAME
	done


