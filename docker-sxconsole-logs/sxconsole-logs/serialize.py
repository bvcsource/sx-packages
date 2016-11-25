from csv import DictWriter
from io import BytesIO
from itertools import imap


CSV_FIELDS = (
    'datetime', 'volume', 'path', 'operation', 'user', 'ip', 'user_agent')


def entries_to_csv(entries):
    output = BytesIO()
    csv = DictWriter(output, CSV_FIELDS)
    rows = imap(serialize_entry, entries)
    csv.writerows(rows)
    output.seek(0)
    return output.read()


def serialize_entry(entry):
    serialized = entry.copy()
    serialized.update({
        'datetime': entry['datetime'].isoformat(' '),
        'operation': entry['operation'].name.lower(),
    })
    return serialized
