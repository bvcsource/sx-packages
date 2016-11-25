#!/bin/sh
set -e
set -o nounset
SRC=vol-repo
DEST=cdn.skylable.com
#DEST=beta/cdn-test
for DIR in centos check debian fedora sxdrive sxscout; do
	FROM="sx://indian.skylable.com/$SRC/$DIR/"
	TO="sx://indian.skylable.com/$DEST/tmp/$DIR/"
	echo "sxcp $FROM -> $TO"
	sxcp -r "sx://indian.skylable.com/$SRC/$DIR/" "sx://indian.skylable.com/$DEST/tmp/$DIR/"
done
echo "sxmv $DEST/tmp/ -> $DEST/"
sxmv -r "sx://indian.skylable.com/$DEST/tmp/" "sx://indian.skylable.com/$DEST/"
