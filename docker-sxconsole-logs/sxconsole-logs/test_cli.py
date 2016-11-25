import pytest

from cli import parser
from watch import DEFAULT_UPLOAD_INTERVAL, DEFAULT_ACCESS_LOG_PATH


class TestParser:
    def test_fail(self):
        with pytest.raises(SystemExit):
            parser.parse_args([])
        with pytest.raises(SystemExit):
            parser.parse_args(['foo'])

    def test_defaults(self):
        options = parser.parse_args(['--sx-url=url'])

        assert options.access_log_path == DEFAULT_ACCESS_LOG_PATH
        assert options.upload_interval == DEFAULT_UPLOAD_INTERVAL

    def test_attrs(self):
        options = parser.parse_args([
            '--sx-url=url',
            '--access-log-path=path',
            '--upload-interval=60',
        ])

        assert options.sx_url == 'url'
        assert options.access_log_path == 'path'
        assert options.upload_interval == 60
