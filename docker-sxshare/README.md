## SX Share

sxshare dockerized

## Generate SSL cert and key

```bash
openssl genrsa -out ca.key 2048 
openssl req -new -key ca.key -out ca.csr
openssl x509 -req -days 3650 -in ca.csr -signkey ca.key -out ca.crt
cp ca.crt /data/sxshare/sxshare.crt
cp ca.key /data/sxshare/sxshare.key
```

## Start your container

By default nginx+gunicorn listen on port 443. Use the -p option to map it to a port on the Docker host.

```bash
docker run -v /data/sxshare:/data -v /data/sxshare/logs:/srv/logs \
        -p :8600:443 \
        --name=sxshare \
        --restart=always -d \
        sxshare
```

## Settings

If you have started sxshare for the first time, you need to configure it.
It will create an example config file in /data/sxshare/conf_defaults.yaml.
Edit it and then run:

```bash
sxshare restart
```

## Upgrades

```bash
docker build -t sxshare .
docker stop sxshare
docker rm sxshare
```

then restart.
