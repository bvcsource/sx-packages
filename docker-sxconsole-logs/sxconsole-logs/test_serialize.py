from csv import DictReader
from parse import parse_line
from serialize import CSV_FIELDS, serialize_entry, entries_to_csv
from test_parse import make_line


class TestEntriesToCsv:

    def test_overall(self):
        entries = [
            parse_line(make_line(method='PUT')),
            parse_line(make_line(method='GET')),
        ]
        output = entries_to_csv(entries)
        csv = DictReader(output.splitlines(), CSV_FIELDS)
        assert list(csv) == [serialize_entry(e) for e in entries]


def test_serialize_entry():
    entry = parse_line(make_line())
    serialized = serialize_entry(entry)
    assert isinstance(serialized['datetime'], str)
    assert isinstance(serialized['operation'], str)
    assert set(serialized.keys()) == set(CSV_FIELDS)
