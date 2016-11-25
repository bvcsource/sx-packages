#!/bin/bash
set -e

if [ -d sxmonitor/ ]; then
	pushd sxmonitor/
	git pull
	popd
else
	git clone git+ssh://ro@git.dev.skylable.com/home/git/sxmonitor sxmonitor/
fi

docker build -t sxmonitor .

