import os
import socket
from subprocess import Popen, PIPE

from serialize import entries_to_csv

STORAGE_VOLUME = 'sxmonitor'
STORAGE_DIR = 'access_logs'


def upload_all_results(results, sx_url):
    print 'Uploading collected results...',
    for date in sorted(results):
        remaining_results = upload_results(results[date], date, sx_url)
        if remaining_results:
            results[date] = remaining_results
        else:
            results.pop(date)
    print 'Done'


def upload_results(results, date, sx_url):
    """Serializes results and appends them to existing result file.

    If anything fails, results are returned back to the caller. Otherwise, an
    empty list is returned.
    """
    try:
        output_path = build_output_path(sx_url, date)
        serialized_results = merge_results(output_path, results)
        upload_file(output_path, serialized_results)
        remaining = []
    except Exception as e:
        print 'Failed to upload results:'
        print '{}: {}'.format(type(e).__name__, e)
        remaining = results
    return remaining


def merge_results(output_path, results):
    """Serialize results and append them to existing results, if any."""
    previous_results = fetch_file(output_path)
    serialized = previous_results + entries_to_csv(results)
    return serialized


def build_output_path(sx_url, date):
    filename = build_filename(date)
    path = build_sx_path(sx_url, STORAGE_VOLUME, STORAGE_DIR, filename)
    return path


def build_sx_path(sx_url, *parts):
    return os.path.join(sx_url, *parts)


def build_filename(date):
    hostname = socket.gethostname()
    return '{}.{}.csv'.format(date.strftime('%Y-%m-%d'), hostname)


def fetch_file(sx_path):
    args = ['sxcat', sx_path]
    p = Popen(args, stdout=PIPE, stderr=PIPE)
    contents, error = p.communicate()
    if p.returncode != 0:
        if 'not found' in error.lower():
            contents = ''
        else:
            msg = 'sxcat failed:\n{}\ninput: {}'.format(error, args)
            raise RuntimeError(msg)
    return contents


def upload_file(sx_path, contents):
    args = ['sxcp', '-', sx_path]
    p = Popen(args, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    output, error = p.communicate(contents)
    if p.returncode != 0:
        msg = 'sxcp failed:\n{}\ninput: {}'.format(error, args)
        raise RuntimeError(msg)
