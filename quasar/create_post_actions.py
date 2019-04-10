import os

from .sql_utils import run_sql_file

data = {'ft_rogue_actions': os.getenv('FT_ROGUE_ACTIONS')}


def main():
    run_sql_file('./data/sql/derived-tables/post_actions.sql', data)


if __name__ == '__main__':
    main()
