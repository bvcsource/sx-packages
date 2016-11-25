#!/usr/bin/env python

import argparse

from watch import DEFAULT_UPLOAD_INTERVAL, DEFAULT_ACCESS_LOG_PATH, main


parser = argparse.ArgumentParser(
    description="Parses and uploads sxhttpd access logs to the cluster.")
parser.add_argument(
    '--sx-url',
    required=True,
    help="Url or sx alias of the cluster.")
parser.add_argument(
    '--access-log-path',
    default=DEFAULT_ACCESS_LOG_PATH,
    help="Path to sxhttpd-access.log file.")
parser.add_argument(
    '--upload-interval',
    type=int,
    default=DEFAULT_UPLOAD_INTERVAL,
    help="Interval for log uploads, in seconds.")

if __name__ == '__main__':  # pragma: no cover
    options = parser.parse_args()
    main(
        sx_url=options.sx_url,
        access_log_path=options.access_log_path,
        upload_interval=options.upload_interval)
