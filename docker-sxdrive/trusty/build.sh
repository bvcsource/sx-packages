#!/bin/bash

dist=trusty

cp -a /root/sxdrive.git /usr/local/src/sxdrive

cd /usr/local/src/sxdrive && \
	git checkout debian && \
        sed -i -re "s/sxdrive \(([^)]+)\) /sxdrive (${SRCVERSION}-1~$dist) /" debian/changelog && \
        git config --global user.name 'root' && \
        git config --global user.email 'root@example.com' && \
        git commit -a -m 'update version' && \
	git-buildpackage -us -uc --git-export-dir=/root/

sxcp --config-dir=/root/.sx /root/sxdrive*.deb sx://indian.skylable.com/vol-packages/experimental-sxdrive/ubuntu/


