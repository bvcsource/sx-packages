'''
Copyright (c) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
License: see LICENSE.md for more details.
'''

import re
from urllib import unquote
from urlparse import parse_qs

from dateutil.parser import parse as dateutil_parse

from enum import Enum


class Operation(Enum):
    LIST = "List"
    DOWNLOAD = "Download"
    UPLOAD = "Upload"
    DELETE = "Delete"


ENTRY_RE = re.compile(
    '''^
    .*?  # garbage
    \s+
        (?P<ip>[0-9.]+)
    \s+
        .*?  # garbage
    \s+
        \[(?P<datetime>\d{2}\/\w+\/\d+:\d{2}:\d{2}:\d{2}\s+[+-]\d+)\]
    \s+
        "
        (?P<method>[A-Z]+)
        \s+
        \/
        (?P<volume>[^"/]+?)
        (\/(?P<path>[^"]*?))?
        (\?(?P<query>[^"]*))?
        \s+
        .*?  # garbage
        "
    \s+
        200  # Accept only HTTP 200 codes
    \s+
        .*?  # garbage
    \s+
        "(?P<user_agent>[^"]*?)"
    \s+
        "SKY\s+(?P<auth>[^"]+)"
    .*''', re.VERBOSE)


def parse_line(line):
    """Convert access log entry into a LogEntry object."""
    match = ENTRY_RE.match(line)
    if match is None:
        return
    data = match.groupdict()

    try:
        entry = parse_captured_groups(data)
    except IgnoredEntry:
        entry = None
    return entry


def parse_captured_groups(data):
    entry = {
        'user_agent': data['user_agent'],
        'ip': data['ip'],
    }

    # path
    path = data['path'] or ''
    query = data['query']
    entry['path'] = parse_path(path, query)

    entry['volume'] = parse_volume(data['volume'])
    entry['user'] = parse_token(data['auth'])
    entry['operation'] = parse_operation(data['method'], entry['path'])
    entry['datetime'] = parse_datetime(data['datetime'])
    return entry


def parse_volume(volume):
    if volume.startswith(('.', '?')):
        raise IgnoredEntry()  # Low-level stuff
    return volume


def parse_token(token):
    if token.startswith('CLUSTER/'):
        raise IgnoredEntry()  # Action invoked by cluster, not a user
    return token


def parse_path(path, query):
    path = '/' + unquote(path)

    if path.startswith('/.'):
        raise IgnoredEntry()  # Low-level stuff

    if query is not None:
        query = parse_qs(query, keep_blank_values=True)
        passing_keys = {'filter', 'recursive', 'rev'}
        if query and not passing_keys.issuperset(query):
            raise IgnoredEntry()  # Low-level stuff

    return path


def parse_operation(method, path):
    at_root = (path == '/')
    if method == 'GET':
        if at_root:
            operation = Operation.LIST
        else:
            operation = Operation.DOWNLOAD
    elif method == 'PUT':
        if at_root:
            raise IgnoredEntry()  # Create volume - skipped
        operation = Operation.UPLOAD
    elif method == 'DELETE':
        operation = Operation.DELETE
    else:
        raise IgnoredEntry()
    return operation


def parse_datetime(datetime):
    datetime = datetime.replace(':', ' ', 1)  # Fix invalid 'year:hour'
    datetime = dateutil_parse(datetime)
    return datetime


class IgnoredEntry(Exception):
    pass
