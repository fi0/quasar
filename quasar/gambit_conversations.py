from .run_sql_file import run_sql_file
from .utils import refresh_materialized_view


def recreate_gambit_conversations():
    run_sql_file('./data/sql/derived-tables/gambit_conversations.sql')


def refresh_gambit_conversations():
    refresh_materialized_view("gambit_conversations.conversations_json")
    refresh_materialized_view("gambit_conversations.conversations")


def recreate_gambit_messages():
    run_sql_file('./data/sql/derived-tables/gambit_mesages.sql')


def refresh_gambit_messages():
    refresh_materialized_view("gambit_conversations.messages_json")
    refresh_materialized_view("gambit_conversations.messages")


def recreate_gambit_full():
    recreate_gambit_conversations()
    recreate_gambit_messages()


def refresh_gambit_full():
    refresh_gambit_conversations()
    refresh_gambit_messages()


if __name__ == '__main__':
    main()
