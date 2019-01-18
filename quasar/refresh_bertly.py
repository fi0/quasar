import os

from .database import Database
from .refresh_dms import refresh_dms


def main():
    refresh_dms(os.environ.get('BERTLY_ARN'), 'Bertly')
    db = Database()
    print('Refreshing Bertly Clicks materialized view.')
    db.query('REFRESH MATERIALIZED VIEW CONCURRENTLY public.bertly_clicks')
    db.disconnect()


if __name__ == "__main__":
    main()
