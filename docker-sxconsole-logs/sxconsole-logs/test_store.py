from datetime import date

import mock

from store import build_output_path, build_sx_path, build_filename


def test_build_output_path():
    expected = 'sx://example/sxmonitor/access_logs/2016-05-09.node01.csv'
    with mock.patch('socket.gethostname', return_value='node01'):
        result = build_output_path('sx://example', date(2016, 5, 9))
    assert result == expected


def test_build_sx_path():
    assert build_sx_path('@cluster', 'vol') == '@cluster/vol'
    assert build_sx_path('sx://cluster', 'vol', 'dir', 'file.txt') == \
        'sx://cluster/vol/dir/file.txt'
    assert build_sx_path('sx://user@example.com', 'vol', 'file.txt') == \
        'sx://user@example.com/vol/file.txt'


def test_build_filename():
    with mock.patch('socket.gethostname', return_value='node01'):
        assert build_filename(date(2016, 5, 6)) == '2016-05-06.node01.csv'
