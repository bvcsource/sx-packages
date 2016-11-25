#!/bin/bash

set -e

DOCKREPO=registry.sxps.vpn.skylable.com
CNAME=docker-reposync
SXAUTH=$HOME/.sx

if [ -z $5 ]; then
    echo Syntax: $0 SX_VER LIBRES3_VER SXDRIVE_VER SXWEB_VER REPO_ROOT
    echo "Do not use micro version for SX_VER and LIBRES3_VER, just major.minor!"
    echo E.g.: $0 1.0 1.0 0.4.0 0.3.0 /vol-repo/testing
    echo Current values:
    for i in sxver s3ver; do
         echo $i:
         if ! [ -x /usr/bin/host ]; then
             echo Run: yum install bind-utils
         else
             host -t txt dummy.$i.skylable.com|cut -d ':' -f 1
         fi
    done
    echo SXDrive:
    wget -q -O- http://cdn.skylable.com/check/sxdrive-version;echo
    echo SXWeb:
    wget -q -O- http://cdn.skylable.com/check/sxweb-version;echo
    exit 1
fi

if [ -z "$KEY_ID" ]; then
    KEY_ID=0x5377E192B7BC1D2E
fi
if [ "$KEY_ID" = "beta" ]; then
    KEY_ID=0x1074997432EA9FA2
fi

SX_VER=$1
LIBRES3_VER=$2
SXDRIVE_VER=$3
SXWEB_VER=$4
REPO_ROOT=$5

if ! [ -r "$SXAUTH/indian.skylable.com/auth/default" ]; then
   echo No sx auth key found in $SXAUTH . You need to sxinit sx://indian.skylable.com with an account that can upload to vol-packages
   exit
fi

# start gpg-agent to sign packages
killall gpg-agent || true
eval $(gpg-agent --daemon --use-standard-socket)
export GPG_AGENT_INFO
GPG_TTY=$(tty)
export GPG_TTY
gpg2 --default-key $KEY_ID --sign - </dev/null >/dev/null

DOCKOPTS="--rm -v $SXAUTH:/root/.sx -v $HOME/.gnupg:$HOME/.gnupg -t -i --rm -e KEY_ID=$KEY_ID -e GPG_AGENT_INFO=$GPG_AGENT_INFO -e SX_VER=$SX_VER -e LIBRES3_VER=$LIBRES3_VER -e SXDRIVE_VER=$SXDRIVE_VER -e REPO_ROOT=$REPO_ROOT"

set -x
pushd docker-reposync

docker build --rm -t registry.sxps.vpn.skylable.com/$CNAME . 

# FIXME: check exitcodes!
docker run $DOCKOPTS $DOCKREPO/$CNAME /usr/bin/update-repo-debs.sh | tee $CNAME.log
docker run $DOCKOPTS $DOCKREPO/$CNAME /usr/bin/update-repo-rpms.sh | tee -a $CNAME.log

popd

echo -n "$SXDRIVE_VER"  | sxcp - sx://indian.skylable.com/$REPO_ROOT/check/sxdrive-version
echo -n "$SXDRIVE_VER"  | sxcp - sx://indian.skylable.com/$REPO_ROOT/check/sxscout-version
echo -n "$SXWEB_VER"  | sxcp - sx://indian.skylable.com/$REPO_ROOT/check/sxweb-version
echo -n "$SX_VER"  | sxcp - sx://indian.skylable.com/$REPO_ROOT/check/sx-version

for SXDRIVE in sxdrive sxscout; do
	for i in msi dmg; do
		sxcp sx://indian.skylable.com/vol-packages/$SXDRIVE/$SXDRIVE-${SXDRIVE_VER}.$i sx://indian.skylable.com/vol-packages/$SXDRIVE/$SXDRIVE-latest.$i
		sxcp sx://indian.skylable.com/vol-packages/$SXDRIVE/$SXDRIVE-${SXDRIVE_VER}.$i sx://indian.skylable.com/$REPO_ROOT/$SXDRIVE/$SXDRIVE-${SXDRIVE_VER}.$i
		sxcp sx://indian.skylable.com/vol-packages/$SXDRIVE/$SXDRIVE-${SXDRIVE_VER}.$i sx://indian.skylable.com/$REPO_ROOT/$SXDRIVE/$SXDRIVE-latest.$i
	done
done

unset x


