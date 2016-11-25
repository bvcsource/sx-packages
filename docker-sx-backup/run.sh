#!/bin/sh
docker run --rm \
    -v /root/.sx:/root/.sx \
    sx-backup
