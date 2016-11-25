#!/bin/bash -x

# start SXShare
RUN_AS=sxshare
SUGGEST_CMD="docker run -v /path/to/datadir:/data --name=sxshare --restart=always -d sxshare"

for i in sxshare.key sxshare.crt; do
	if ! [ -r /data/$i ]; then
		echo $i not found. Please use the following syntax and make sure the sxshare user can read the file:
		echo Use: $SUGGEST_CMD
		exit 1
	fi
done

echo Copying SSL certs...
mkdir -p /etc/nginx/ssl
cp /data/sxshare.crt /data/sxshare.key /etc/nginx/ssl/
chmod 600 /etc/nginx/ssl/sxshare.key

echo Updating SXShare config file...
mkdir -p /data/sql
#sed -i "s#BASE_DIR, 'db.sqlite3'#'/data/sql', 'db.sqlite3'#" /srv/sxshare/sxshare/settings.py
#sed -i "s#http://sxshare#https://cirronode#" /srv/sxshare/sxshare/settings.py
sed -i 's/DEBUG = True/DEBUG = False/' sxshare/settings.py

if ! [ -r "/data/conf_defaults.yaml" ]; then
    cp /srv/sxshare/conf_example.yaml /data/conf_defaults.yaml
else
    chmod 600 /data/conf_defaults.yaml
    cp -p /data/conf_defaults.yaml /srv/sxshare/conf.yaml
fi

if grep -i ^Edit-me-first /srv/sxshare/conf.yaml; then
    echo Please edit conf_defaults.yaml
    exit 1
fi

echo Building static assets
webpack -p

echo Starting migrate and collectstatic
python manage.py migrate                  # Apply database migrations
python manage.py compilemessages          # Compile translations
#python manage.py collectstatic --noinput  # Collect static files

# Prepare log files and start outputting logs to stdout
mkdir -p /srv/logs
mkdir -p /srv/logs/supervisor
chown -R sxshare /srv/logs
touch /srv/logs/gunicorn.log
touch /srv/logs/access.log
tail -n 0 -f /srv/logs/*.log &

# fix permissions
if ! getent passwd $RUN_AS > /dev/null 2>&1; then
	adduser $RUN_AS 
fi
chown -R $RUN_AS /srv /data/sql
chmod -R go-rwx /data/sql



echo If you need to add a root admin, run:
echo 'docker exec -t -i  sxshare su sxshare -c "/srv/sxshare/manage.py add_root_admin your-email your-pass"'

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

