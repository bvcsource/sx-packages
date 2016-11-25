from time import sleep

from throttle import throttle


def test_wrapping():
    def do_nothing():
        """Does literally nothing."""
    throttled = throttle(0.1)(do_nothing)

    assert throttled.__name__ == do_nothing.__name__
    assert throttled.__doc__ == do_nothing.__doc__


def test_throttle():
    items = []

    def append(item):
        items.append(item)
        return len(items)
    throttled = throttle(0.1)(append)

    result = append(1)
    assert items == [1]

    result = throttled(2)
    assert items == [1, 2], "Doesn't throttle the first call."

    result = throttled(3)
    assert items == [1, 2], "Performs throttling"
    assert result is None, "No memoization (for now)."

    sleep(0.1)
    result = throttled(4)
    assert items == [1, 2, 4], "Throttles for the given threshold"
