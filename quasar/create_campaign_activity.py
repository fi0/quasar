import os

from .sql_utils import run_sql_file

data = {
    'ft_rogue_signups': os.getenv('FT_ROGUE_SIGNUPS'),
    'ft_rogue_posts': os.getenv('FT_ROGUE_POSTS'),
    'ft_rogue_turbovote': os.getenv('FT_ROGUE_TURBOVOTE'),
    'ft_rogue_rtv': os.getenv('FT_ROGUE_RTV'),
    'ft_rogue_actions': os.getenv('FT_ROGUE_ACTIONS')
}


def main():
    run_sql_file('./data/sql/derived-tables/campaign_activity.sql', data)


if __name__ == '__main__':
    main()
