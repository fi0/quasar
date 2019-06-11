import os
from .refresh_dms import refresh_dms
from .sql_utils import run_sql_file_raw, refresh_materialized_view


def create():
    run_sql_file_raw('./data/sql/derived-tables/bertly.sql')


def refresh():
    refresh_dms(os.environ.get('BERTLY_ARN'), 'Bertly')
    refresh_materialized_view('public.bertly_clicks')


if __name__ == '__create__':
    create()

if __name__ == '__refresh':
    refresh()
