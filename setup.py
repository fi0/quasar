from setuptools import setup, find_packages

with open('requirements.txt') as f:
    requirements = f.read().splitlines()

setup(
    name="quasar",
    version="1.8.0",
    packages=find_packages(),
    install_requires=requirements,
    entry_points={
        'console_scripts': [
            'bertly_refresh = quasar.refresh_bertly:main',
            'bertly_create = quasar.recreate_bertly:main',
            'campaign_info = quasar.campaign_info:main',
            'campaign_info_recreate = quasar.ashes_to_campaign_info:create',
            'campaign_info_refresh = quasar.ashes_to_campaign_info:main',
            'campaign_activity_create = quasar.recreate_campaign_activity:main',
            'campaign_activity_refresh = quasar.refresh_campaign_activity:main',
            'cio_import = quasar.cio_consumer:main',
            'etl_monitoring = quasar.etl_monitoring:run_monitoring',
            'gambit_conversations_create = quasar.gambit_conversations:recreate_gambit_conversations',
            'gambit_conversations_refresh = quasar.gambit_conversations:refresh_gambit_conversations',
            'gambit_messages_create = quasar.gambit_conversations:recreate_gambit_messages',
            'gambit_messages_refresh = quasar.gambit_conversations:refresh_gambit_messages',
            'gambit_messages_create = quasar.gambit_conversations:recreate_gambit_full',
            'gambit_messages_refresh = quasar.gambit_conversations:refresh_gambit_full',
            'gtm_retention_create = quasar.recreate_gtm_retention:main',
            'gtm_retention_refresh = quasar.refresh_gtm_retention:main',
            'mam_retention_create = quasar.recreate_mam_retention:main',
            'mam_retention_refresh = quasar.refresh_mam_retention:main',
            'mel_create = quasar.recreate_mel:main',
            'mel_refresh = quasar.mel:main',
            'message_route = quasar.route_queue_process:main',
            'northstar_to_quasar_diff = quasar.northstar_to_user_table:backfill_since',
            'northstar_to_quasar_diff_json = quasar.northstar_to_user_table:backfill_since_json',
            'puck_refresh = quasar.puck_events:main',
            'rogue_consume = quasar.rogue_consumer:main',
            'rogue_ghost_killer = quasar.ghost_killer:main',
            'users_create = quasar.recreate_derived_users:main',
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
