from .sql_utils import run_sql_file_raw


def create():
    run_sql_file_raw('./data/sql/derived-tables/snowplow_events.sql')


def refresh():
    run_sql_file_raw('./data/sql/derived-tables/snowplow_events_refresh.sql')


if __name__ == "__create__":
    create()

if __name__ == "__refresh__":
    refresh()
