from .sql_utils import run_sql_file_raw, refresh_materialized_view


def create():
    run_sql_file_raw('./data/sql/derived-tables/gtm_retention.sql')


def refresh():
    refresh_materialized_view('public.gtm_retention')


if __name__ == '__create__':
    create()

if __name__ == '__refresh__':
    refresh()
