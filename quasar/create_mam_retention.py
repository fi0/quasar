from .sql_utils import run_sql_file_raw


def main():
    run_sql_file_raw('./data/sql/derived-tables/mam_retention.sql')


if __name__ == '__main__':
    main()
