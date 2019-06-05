import os

from .sql_utils import run_sql_file, refresh_materialized_view

data = {
    'ft_rogue_signups': os.getenv('FT_ROGUE_SIGNUPS'),
    'ft_rogue_posts': os.getenv('FT_ROGUE_POSTS'),
    'ft_rogue_turbovote': os.getenv('FT_ROGUE_TURBOVOTE'),
    'ft_rogue_rtv': os.getenv('FT_ROGUE_RTV'),
    'ft_rogue_actions': os.getenv('FT_ROGUE_ACTIONS')
}


def create():
    run_sql_file('./data/sql/derived-tables/campaign_activity.sql', data)

def refresh():
    refresh_materialized_view('public.signups')
    refresh_materialized_view(data['ft_rogue_turbovote'])
    refresh_materialized_view(data['ft_rogue_rtv'])
    refresh_materialized_view('public.posts')
    refresh_materialized_view('public.reportbacks')


if __name__ == '__create__':
    create()

if __name__ == '__refresh__':
    refresh()
