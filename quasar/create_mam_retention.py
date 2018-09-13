from .sql_utils import run_sql_file


def main():
    run_sql_file('./data/sql/derived-tables/mam_retention.sql')


if __name__ == '__main__':
    main()
