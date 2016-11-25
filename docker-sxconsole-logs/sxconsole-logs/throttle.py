from functools import wraps
from time import time


def throttle(threshold):
    def decorator(func):
        throttled = Throttle(func, threshold)
        return wraps(func)(throttled)
    return decorator


class Throttle(object):

    def __init__(self, func, threshold):
        self.func = func
        self.threshold = threshold
        self.last_run = 0

    def __call__(self, *args, **kwargs):
        now = time()
        if now - self.last_run > self.threshold:
            self.last_run = now
            return self.func(*args, **kwargs)
