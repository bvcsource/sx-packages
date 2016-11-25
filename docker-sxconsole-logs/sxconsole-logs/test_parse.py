from dateutil.parser import parse as dateutil_parse

from parse import parse_line, Operation


# Default params for `make_line`
DEFAULT_PARAMS = {
    'ip': '188.40.135.2',
    'datetime': '01/May/2016:06:26:22 +0200',
    'method': 'PUT',
    'volume': 'sxmonitor',
    'path': '/nagios-test-file',
    'resp_code': 200,
    'user_agent': 'python-requests/2.9.1',
    'token': '0DPiKuNIrrVmD8IUCuw1hQxNqZcAmqwgGTOKuBIjm0FOT4IwFnJAKQAA',
}


def make_line(**kwargs):
    tpl = '[0.052] {ip} - - [{datetime}] ' \
        ' "{method} /{volume}{path} HTTP/1.1" ' \
        '{resp_code} 194 "-" "{user_agent}" "SKY {token}"'
    for key, value in DEFAULT_PARAMS.items():
        if key not in kwargs:
            kwargs[key] = value
    return tpl.format(**kwargs)


class TestParseLine():

    def test_overall(self):
        line = make_line()
        entry = parse_line(line)
        assert entry['ip'] == DEFAULT_PARAMS['ip']
        datetime = DEFAULT_PARAMS['datetime']
        datetime = dateutil_parse(datetime.replace(':', ' ', 1))
        assert entry['datetime'] == datetime
        assert entry['operation'] == Operation.UPLOAD
        assert entry['volume'] == 'sxmonitor'
        assert entry['path'] == '/nagios-test-file'
        assert entry['user'] == DEFAULT_PARAMS['token']
        assert entry['user_agent'] == DEFAULT_PARAMS['user_agent']
        assert len(entry) == 7, "Tests all entry keys"

    def test_fail(self):
        assert parse_line('') is None
        assert parse_line('garbage') is None
        line = make_line(resp_code=404)
        assert parse_line(line) is None

    def test_ignored(self):
        lines = [
            make_line(volume='?clusterMeta'),
            make_line(volume='.status'),
            make_line(path='/.upload'),
            make_line(path='?o=mod'),
            make_line(path='/?o=mod'),
            make_line(method='WHATEVER'),
            make_line(method='PUT', path=''),
            make_line(token='CLUSTER/ALLNODE/ROOT/USER<token>'),
        ]
        for i, line in enumerate(lines):
            assert parse_line(line) is None, i

    def test_list(self):
        line = make_line(method='GET', path='')
        entry = parse_line(line)
        assert entry['operation'] == Operation.LIST

    def test_query(self):
        line = make_line(method='GET', path='?recursive')
        entry = parse_line(line)
        assert entry is not None

    def test_query_ignored(self):
        line = make_line(method='GET', path='file?rev=foo&fileMeta')
        entry = parse_line(line)
        assert entry is None

    def test_download(self):
        line = make_line(method='GET')
        entry = parse_line(line)
        assert entry['operation'] == Operation.DOWNLOAD

    def test_delete(self):
        line = make_line(method='DELETE')
        entry = parse_line(line)
        assert entry['operation'] == Operation.DELETE
