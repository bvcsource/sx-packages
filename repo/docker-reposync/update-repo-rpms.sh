#!/bin/bash -x
#
unset https_proxy

set -e
set -x

SOURCE=sx://indian.skylable.com/vol-packages/
DESTREPO="sx://indian.skylable.com/$REPO_ROOT/"

DISTS="fedora centos"
rm -rf $DISTS

download_packages() {
    package=$1
    version=$2
    if [ $package == "skylable-sx" ]; then
        SUBDIR=experimental-sx
    else
        SUBDIR=experimental-$package
    fi
    for dist_new in $DISTS; do
        if [ "$dist_new" = "centos" ]; then
            dist="rhel"
        else
            dist="$dist_new"
        fi
        # delete spurious git packages before they are downloaded
	# e.g.: sx://indian.skylable.com/vol-packages//experimental-sx/fedora/20/*git*
	sxrm --mass -r $SOURCE/$SUBDIR/$dist/*/*git* || true
        sxcp -q -r $SOURCE/$SUBDIR/$dist/ $dist_new
	(cd $dist_new; find . -name ${package}*.rpm -type f | grep -v "\-${version}\-" | xargs -r rm)
	ls -R $dist_new/
    done
}

download_packages skylable-sx $SX_VER
download_packages libres3 $LIBRES3_VER
download_packages sxdrive $SXDRIVE_VER
download_packages sxscout $SXDRIVE_VER

for dist_new in $DISTS; do
    for i in $dist_new/*; do
        echo $i
	# does the dir contain rpm files?
	if [ "$(ls -A $i/*.rpm)" ]; then
	    OPTS=
            (cd $i && mkdir -p x86_64 && mv *.rpm x86_64/ && cd x86_64 && setsid -w rpm --addsign *.rpm </dev/null && createrepo $OPTS . && rm -f repodata/repomd.xml.asc && gpg2 --detach-sign --armor -u dev-team@skylable.com repodata/repomd.xml; ls -Rl)
	fi
    done
    if test "$dist_new" = "centos"; then
	rm "$dist_new/5" -rf
    fi
    if test "$dist_new" = "fedora"; then
	rm "$dist_new/21" "$dist_new/22" -rf
	for ver in 24 25; do 
		i=$dist_new/$ver
		mkdir -p $i
		(cd $i && mkdir -p x86_64 && cd x86_64 && cp ../../23/x86_64/*.rpm . && createrepo . && rm -f repodata/repomd.xml.asc && gpg2 --detach-sign --armor -u dev-team@skylable.com repodata/repomd.xml; ls -Rl)
	done
    fi
done

echo Syncing repository to $DESTREPO in 5 secs, CTRL+C to abort
sleep 5
for dist in $DISTS; do
    sxrm --mass -r $DESTREPO/$dist || true
done
sxcp -q -r $DISTS $DESTREPO

