from setuptools import setup, find_packages

with open('requirements.txt') as f:
    requirements = f.read().splitlines()

setup(
    name="quasar",
    version="0.9.4",
    packages=find_packages(),
    install_requires=requirements,
    entry_points={
        'console_scripts': [
            'bertly_refresh = quasar.refresh_bertly:main',
            'campaign_info_recreate = quasar.ashes_to_campaign_info:create',
            'campaign_info_refresh = quasar.ashes_to_campaign_info:main',
            'campaign_activity_refresh = quasar.refresh_campaign_activity:main',
            'cio_import = quasar.cio_consumer_pg:main',
            'etl_monitoring = quasar.etl_monitoring:run_monitoring',
            'mel_create = quasar.mel:create',
            'mel_refresh = quasar.mel:main',
            'message_route = quasar.route_queue_process:main',
            'northstar_to_quasar_diff = quasar.northstar_to_user_table_pg:backfill_since',
            'northstar_to_quasar_diff_json = quasar.northstar_to_user_table_pg:backfill_since_json',
            'puck_refresh = quasar.puck_events:main',
            'rogue_consume = quasar.rogue_consumer_pg:main',
            'rogue_ghost_killer = quasar.ghost_killer:main',
            'reportbacks_asterisk = quasar.reportback_asterisk:run_load_reportbacks',
            'users_refresh = quasar.refresh_derived_users:main'
        ],
    },
    author="",
    author_email="",
    description="",
    license="MIT",
    keywords=[],
    url="",
    classifiers=[
    ],
)
