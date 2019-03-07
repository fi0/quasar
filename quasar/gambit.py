from .sql_utils import run_sql_file, refresh_materialized_view
from .utils import log


def create_gambit_messages():
    # Gambit conversations is a necessary precursor to exist
    # before messages can be created.
    log("Creating Gambit Messages derived tables.")
    run_sql_file('./data/sql/derived-tables/gambit_messages.sql')


def refresh_gambit_messages():
    log("Refreshing ft_gambit_conversations_api.messages_flattened derived table.")
    refresh_materialized_view("CONCURRENTLY ft_gambit_conversations_api.messages_flattened")
    log("Refreshing public.gambit_messages_inbound derived table.")
    refresh_materialized_view("public.gambit_messages_inbound")
    log("Refreshing public.gambit_messages_outbound derived table.")
    refresh_materialized_view("public.gambit_messages_outbound")


def refresh_gambit_full():
    refresh_gambit_messages()
