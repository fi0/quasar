from .sql_utils import run_sql_file_raw, refresh_materialized_view


def create():
    run_sql_file_raw('./data/sql/derived-tables/mel.sql')

def create_for_dbt_validation():
    run_sql_file_raw('../data/sql/derived-tables/mel_dbt_validation.sql')

def refresh():
    refresh_materialized_view('public.member_event_log')


if __name__ == "__create__":
    create()

if __name__ == "__refresh__":
    refresh()
