#!/bin/sh
set -o nounset
CUSTOMER=cliente
APPLIANCE=${CUSTOMER}.ioffice.me
LOCAL=sx://admin@${APPLIANCE}
REMOTE=sx://backup-${CUSTOMER}@sx.ioffice.me/backup-${CUSTOMER}

if [ -r $HOME/.sx/sx.ioffice.me/auth/backup-${APPLIANCE} ]; then 
        echo Please run:
        echo sxinit sx://backup-${APPLIANCE}@sx.ioffice.me
        exit 1
fi

# Ought to work when volume names contain spaces
TODAY="$(date +%F)"
echo "Starting backup $(date)"
sxls "$LOCAL" -l | awk '$5=="-" { print }' | grep -Eo sx://.* | while read URI; do basename "$URI"; done | xargs -I{} --max-procs 0 \
        sxcp -q -r "$LOCAL/{}" "$REMOTE/$TODAY/{}" --ignore-errors
echo "Backup done $(date)"
