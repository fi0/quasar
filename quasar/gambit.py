from .sql_utils import run_sql_file, refresh_materialized_view
from .utils import log


def create_gambit_raw_json():
    log("Creating Gambit Conversations and Messages raw json tables.")
    run_sql_file('./data/sql/derived-tables/gambit_raw_json.sql')


def create_gambit_conversations():
    log("Creating Gambit Conversations derived tables.")
    run_sql_file('./data/sql/derived-tables/gambit_conversations.sql')


def refresh_gambit_conversations():
    log("Refreshing gambit.conversations_json derived table.")
    refresh_materialized_view("gambit.conversations_json")
    log("Refreshing gambit.conversations_flattened derived table.")
    refresh_materialized_view("gambit.conversations_flattened")


def create_gambit_messages():
    log("Creating Gambit Conversations derived tables, pre-req for Messages.")
    run_sql_file('./data/sql/derived-tables/gambit_conversations.sql')
    log("Creating Gambit Messages derived tables.")
    run_sql_file('./data/sql/derived-tables/gambit_messages.sql')


def refresh_gambit_messages():
    log("Refreshing gambit.messages_json derived table.")
    refresh_materialized_view("gambit.messages_json")
    log("Refreshing gambit.messages_flattened derived table.")
    refresh_materialized_view("gambit.messages_flattened")


def create_gambit_full():
    # Only need messages since runs conversations as pre-req.
    recreate_gambit_messages()


def refresh_gambit_full():
    refresh_gambit_conversations()
    refresh_gambit_messages()