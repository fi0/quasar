from .sql_utils import run_sql_file, refresh_materialized_view
from .utils import log


def create_gambit_messages():
    # Gambit conversations is a necessary precursor to exist
    # before messages can be created.
    log("Creating Gambit Messages derived tables.")
    run_sql_file('./data/sql/derived-tables/gambit_messages_ft.sql')


def refresh_gambit_messages():
    log("Refreshing gambit.messages_flattened_ft derived table.")
    refresh_materialized_view("ft_gambit_conversations_api.messages_flattened_ft")
    log("Refreshing public.gambit_messages_inbound_ft derived table.")
    refresh_materialized_view("public.gambit_messages_inbound_ft")
    log("Refreshing public.gambit_messages_outbound_ft derived table.")
    refresh_materialized_view("public.gambit_messages_outbound_ft")


def refresh_gambit_full():
    refresh_gambit_messages()
