from setuptools import setup, find_packages

with open('requirements.txt') as f:
    requirements = f.read().splitlines()

setup(
    name="quasar",
    version="0.7.0",
    packages=find_packages(),
    install_requires=requirements,
    entry_points={
        'console_scripts': [
            'campaign_info_table_refresh = quasar.phoenix_to_campaign_info_table:main',
            'campaign_info_recreate_pg = quasar.ashes_to_campaign_info:create',
            'campaign_info_refresh_pg = quasar.ashes_to_campaign_info:main',
            'cio_import = quasar.cio_queue_process:main',
            'cio_import_pg = quasar.cio_consumer_pg:main',
            'etl_monitoring = quasar.etl_monitoring:run_monitoring',
            'get_competitions = quasar.gladiator_import:get_competitions',
            'legacy_cio_backfill = quasar.cio_legacy_backfill:legacy_cio_backfill',
            'member_event_log = quasar.member_event_log:mel',
            'mel_create_pg = quasar.mel:create',
            'mel_refresh_pg = quasar.mel:main',
            'northstar_to_quasar_import_backfill = quasar.northstar_to_user_table:backfill_since',
            'northstar_to_quasar_diff_pg = quasar.northstar_to_user_table_pg:backfill_since',
            'quasar_blink_queue_consumer = quasar.customerio:main',
            'phoenix_next_cleanup = quasar.phoenix_next_queue_cleanup:main',
            'puck_refresh = quasar.puck_events.py:main',
            'rogue_consume = quasar.rogue_consumer:main',
            'rogue_consume_pg = quasar.rogue_consumer_pg:main',
            'runscope_cleanup = quasar.cio_runscope_queue_cleanup:main',
            'reportbacks_asterisk = quasar.reportback_asterisk:run_load_reportbacks'
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
