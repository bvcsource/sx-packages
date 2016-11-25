#!/bin/bash -x

echo 'Update docker images? (Y/N)'
read ANSWER
if [ "$ANSWER" = "Y" ]; then
	pushd /root/packages/docker-sxshare/
	cd sxshare
	git pull
	cd ../sx-translations
	git pull
	cd ..

	docker build -t sxshare . || exit 1
	popd
fi

echo Restart sxshare
docker stop sxshare
docker rm sxshare

set -e
docker run -v /data/sxshare:/data -v /data/sxshare/logs:/srv/logs \
        -p :8600:443 \
        --name=sxshare \
        --restart=always -d \
        sxshare

docker ps
