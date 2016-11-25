# sxconsole-logs

This program listens to updates in sx node's access log file and uploads parsed
access logs into the sxmonitor volume.

`cli.py` needs to keep running constantly to watch the access logs. You can use
a tool like `supervisor` to manage it.


## Getting started

To use this script, you need to:
 - Prepare a `sxmonitor` volume
 - Run `pip install -r requirements.txt`. If you don not have pip, install
   `python-pip` package first.
 - Run `sxinit` for the sx user which will upload processed access logs.
 - Finally, run `./cli.py`, passing the sx url through `--sx-url` option.
   You can use either `sx://user@cluster.example.com` or `@sx-alias` format for
   the sx url.


## Custom configuration

There are two optional settings:
 - `--access-log-path` allows to change the path of log file to listen to.
 - `--upload-interval` is the number of seconds between access log uploads.


## Example usage

```
./cli.py \
    --sx-url=@sxconsole-logs \
    --access-log-path=/path/to/sxhttpd-access.log \
    --upload-interval=42
```
