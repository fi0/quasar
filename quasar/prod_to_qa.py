import os

from .sa_database import Database
from sh import pg_dump, psql

db = Database()

# Setup pg_dump vars.
qa_pg_opts = {
    'username': os.getenv('PG_USER'),
    'host': os.getenv('PG_HOST'),
    'database': os.getenv('PG_DUMP_DATABASE')
}


prod_pg_opts = {
    'username': os.getenv('PG_PROD_USER'),
    'host': os.getenv('PG_PROD_HOST'),
    'database': os.getenv('PG_PROD_DATABASE')
}


def main():
    schemas = os.getenv('DUMP_SCHEMAS')

    for schema in schemas.split(" "):
        psql(pg_dump(
            '-h', prod_pg_opts['host'],
            '-U', prod_pg_opts['username'],
            '-d', prod_pg_opts['database'],
            '--schema', schema,
            '-O', '-v', '--clean', _piped=True),
            '-h', qa_pg_opts['host'],
            '-U', qa_pg_opts['username'],
            '-d', qa_pg_opts['database']
        )
