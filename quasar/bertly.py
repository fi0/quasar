import os
from .refresh_dms import refresh_dms


def refresh():
    refresh_dms(os.environ.get('BERTLY_ARN'), 'Bertly')


if __name__ == '__refresh':
    refresh()
