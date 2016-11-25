import subprocess
from collections import defaultdict

from parse import parse_line
from throttle import Throttle
from store import upload_all_results


DEFAULT_ACCESS_LOG_PATH = '/var/log/sxserver/sxhttpd-access.log'
DEFAULT_UPLOAD_INTERVAL = 5 * 60


def main(sx_url, access_log_path=DEFAULT_ACCESS_LOG_PATH,
         upload_interval=DEFAULT_UPLOAD_INTERVAL):
    results = defaultdict(list)  # { date: entries }
    maybe_upload_results = Throttle(upload_all_results, upload_interval)
    for data in listen_and_parse(access_log_path):
        key = data['datetime'].date()
        results[key].append(data)
        maybe_upload_results(results, sx_url)


def listen_and_parse(access_log_path):
    tail = open_tail(access_log_path)
    while True:
        line = tail.readline()
        assert line
        data = parse_line(line)
        if data:
            yield data


def open_tail(path):
    tail = subprocess.Popen(['tail', '-F', '-n', '0', path],
                            stdout=subprocess.PIPE)
    return tail.stdout
