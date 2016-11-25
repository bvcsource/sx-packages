#!/bin/bash

SXWEB_CONFIG_DIR="/var/www/sxweb/application/configs/"

if [ -f "/data/sxweb/skylable.ini" ]; then
    cp -f /data/sxweb/skylable.ini "$SXWEB_CONFIG_DIR"/skylable.ini
    rm -f /var/www/sxweb/public/install.php
fi

if [ -d "/data/sxweb/whitelabel" ]; then
    cp -a /data/sxweb/whitelabel/. /var/www/sxweb/.
fi

if [ -n "$SXWEB_DB_PORT_3306_TCP_ADDR" ] && [ ! -f "$SXWEB_CONFIG_DIR"/skylable.ini ]; then
	echo Setting db parameters in SXWeb installer...
	cat >"$SXWEB_CONFIG_DIR"/skylable_docker.ini <<EOF
[production] 
cluster = "sx://cluster.example.com"
cluster_ssl = true
;cluster_port = 443
;cluster_ip = 192.168.0.1
; url = "https://sxweb.example.com"
local = APPLICATION_PATH "/../"
sx_local = APPLICATION_PATH "/../data/sx" 
downloads = 5
downloads_ip = 30
downloads_time_window = 20
downloads_time_window_ip = 20
max_upload_filesize = 50000000
shared_file_expire_time = 604800
remember_me_cookie_seconds = 1296000
cookie_domain = ".example.com"
elastic_hosts[] = "localhost"
tech_support_url = "http://skylable.zendesk.com"
password_recovery = false
default_language = "en"
db.adapter = "pdo_mysql"
db.params.host = "$SXWEB_DB_PORT_3306_TCP_ADDR"
; db.params.port = 3306
db.params.username = "$SXWEB_DB_ENV_MYSQL_USER"
db.params.password = "$SXWEB_DB_ENV_MYSQL_PASSWORD"
db.params.dbname = "$SXWEB_DB_ENV_MYSQL_DATABASE"
db.params.charset = "utf8"

; Email
mail.transport.type = "smtp"
mail.transport.name = "example.com"
mail.transport.host = "localhost"
;mail.transport.ssl = ""
;mail.transport.port = 25
;mail.transport.auth = login
;mail.transport.username = "myUsername"
;mail.transport.password = "myPassword"
mail.transport.register = true 

mail.defaultFrom.email = "noreply@example.com"
mail.defaultFrom.name = "SXWeb"
;mail.defaultReplyTo.email = Jane@example.com
;mail.defaultReplyTo.name = "Jane Doe"

[development : production]
EOF
	chown nginx "$SXWEB_CONFIG_DIR"/skylable_docker.ini
	chmod 640 "$SXWEB_CONFIG_DIR"/skylable_docker.ini
fi

if [ -r "$SXWEB_CONFIG_DIR"/skylable_docker.ini ]; then
    echo Setting up DB...
    mysql -u $SXWEB_DB_ENV_MYSQL_USER -p$SXWEB_DB_ENV_MYSQL_PASSWORD -h $SXWEB_DB_PORT_3306_TCP_ADDR $SXWEB_DB_ENV_MYSQL_DATABASE </var/www/sxweb/sql/sxweb.sql
    echo Now connect with your browser to this container and finish the setup. 
fi

if [ -r "$SXWEB_CONFIG_DIR"/skylable.ini ]; then
    echo Updating skylable.ini with DB parameters
    sed -i "s/^db.params.host = \".*\"$/db.params.host = \"$SXWEB_DB_PORT_3306_TCP_ADDR\"/" "$SXWEB_CONFIG_DIR"/skylable.ini
    sed -i "s/^db.params.username = \".*\"$/db.params.username = \"$SXWEB_DB_ENV_MYSQL_USER\"/" "$SXWEB_CONFIG_DIR"/skylable.ini
    sed -i "s/^db.params.password = \".*\"$/db.params.password = \"$SXWEB_DB_ENV_MYSQL_PASSWORD\"/" "$SXWEB_CONFIG_DIR"/skylable.ini
    sed -i "s/^db.params.dbname = \".*\"$/db.params.dbname = \"$SXWEB_DB_ENV_MYSQL_DATABASE\"/" "$SXWEB_CONFIG_DIR"/skylable.ini
fi

mkdir -p /etc/nginx/ssl
mkdir -p /srv/logs/supervisor

if [ -r "/data/sxweb/sxcert.pem" ] || [ -r "/data/sxweb/sxkey.pem" ]; then
    chown root.root /data/sxweb/sxkey.pem; chmod 600 /data/sxweb/sxkey.pem
    cp /data/sxweb/sxcert.pem /etc/nginx/ssl/sxcert.pem
    cp /data/sxweb/sxkey.pem /etc/nginx/ssl/sxkey.pem
else
    echo WARNING: Could not find SSL certs in /data/sxweb/sxcert.pem /data/sxweb/sxkey.pem
    echo Please use:
    echo "docker run -v /data/sxweb:/data/sxweb -p 8443:443 --restart=always -d --name sxweb_frontend --link sxweb_db:sxweb_db skylable/sxweb"
    echo .
    echo Creating self signed certs... THIS IS UNSAFE
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
        -subj "/C=UK/ST=London/L=London/O=Dis/CN=localhost" \
        -keyout /etc/nginx/ssl/sxkey.pem -out /etc/nginx/ssl/sxcert.pem
    openssl req -new -newkey rsa:4096 -key /etc/nginx/ssl/sxkey.pem \
        -out sxcert.csr \
        -subj "/C=UK/ST=London/L=London/O=Dis/CN=localhost"
fi


echo Starting supervisord
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
