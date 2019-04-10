import os

from .sql_utils import run_sql_file

data = {
    'northstar_users': os.getenv('NORTHSTAR_USERS'),
    'cio_email_event': os.getenv('CIO_EMAIL_EVENT')
}

def main():
    run_sql_file('./data/sql/derived-tables/mel.sql', data)


if __name__ == '__main__':
    main()
