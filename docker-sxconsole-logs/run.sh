#!/bin/bash -x
set -e

if [ ! -e "$ACCESS_LOG_PATH" ]; then
    echo "You must mount sxhttpd logs directory under `dirname $ACCESS_LOG_PATH`."
    echo "Use 'docker run -v /var/log/sxserver:/data/logs'."
    exit 1
fi
if [ ! -d '/data/sx' ]; then
    echo "You must mount the .sx directory under /data/sx."
    echo "Use 'docker run -v /root/.sx:/data/sx'."
    exit 1
fi
if [ -z "$SX_URL" ]; then
    echo "You must specify SX_URL environment variable. Use 'docker run -e \"SX_URL=...\"'."
    exit 1
fi

# Prepare log files and start outputting logs to stdout
mkdir -p /srv/logs
mkdir -p /srv/logs/supervisor
tail -n 0 -F /srv/logs/supervisor/*.log &

cp -r /data/sx /root/.sx

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
