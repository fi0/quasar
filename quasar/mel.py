import os

from .sql_utils import run_sql_file_raw, refresh_materialized_view


def create():
    run_sql_file_raw('./data/sql/derived-tables/mel.sql')


def refresh():
    refresh_materialized_view('REFRESH MATERIALIZED VIEW CONCURRENTLY public.member_event_log')


if __name__ == "__create__":
    create()

if __name__ == "__refresh__":
    refresh()
