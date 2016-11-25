### docker-sxconsole-logs

This image runs a script, which listens to updates in sxhttpd-access.log file
and uploads parsed access logs into the sxmonitor volume.


# Requirements

To use this image, you first need to:
 - Prepare `sxmonitor` volume
 - Prepare sx url or sx alias for user which will upload the access logs

To run the container:
 - Mount sxserver logs directory under `/data/logs`
 - Mount the .sx directory under `/data/sx`
 - Pass the sx url or alias through the `SX_URL` environment variable

# Custom configuration

Optionally, you can override these variables:

```
ENV ACCESS_LOG_PATH=/data/logs/sxhttpd-access.log
ENV UPLOAD_INTERVAL=300
```


# Example usage

```
docker run \
    -v /opt/sx/var/log/sxserver:/data/logs \
    -v /home/filip/.sx:/data/sx \
    -e "SX_URL=@testcl" \
    -d \
    --name=sxconsole-logs \
    sxconsole-logs
```
