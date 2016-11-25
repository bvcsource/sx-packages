#!/bin/bash
set -e

if [ -d sxshare/ ]; then
	pushd sxshare/
	git pull
	popd
else
#	git clone git+ssh://git.dev.skylable.com sxshare/
git clone git+ssh://ro@git.dev.skylable.com/home/git/sxshare sxshare/
fi

docker build -t sxshare .

