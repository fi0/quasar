from setuptools import setup, find_packages

with open('requirements.txt') as f:
    requirements = f.read().splitlines()

setup(
    name="quasar",
    version="0.1.4",
    packages=find_packages(),
    install_requires=requirements,
    entry_points={
        'console_scripts': [
            'campaign_activity_backfill_diff = quasar.campaign_activity:backfill_since',
            'campaign_activity_full_backfill = quasar.campaign_activity:full_backfill',
            'campaign_info_table_refresh = quasar.phoenix_to_campaign_info_table:main',
            'cio_import = quasar.cio_queue_process:main',
            'etl_monitoring = quasar.etl_monitoring:run_monitoring',
            'get_competitions = quasar.gladiator_import:get_competitions',
            'import_UID_to_mobile_user_lookup_table = quasar.import_uid_by_phone_number:main',
            'legacy_cio_backfill = quasar.cio_legacy_backfill:legacy_cio_backfill',
            'member_event_log = quasar.member_event_log:mel',
            'import_moco_profiles = quasar.moco_xml_to_quasar:main_import_profiles',
            'legacy_mobile_campaign_table_update = quasar.mobile_commons:convert_campaign_lookup_to_id',
            'mobile_campaign_lookup_table_update = quasar.mobile_commons:scrape_campaigns',
            'mobile_subscriptions = quasar.jc_subscribers:main',
            'mobile_user_table_update = quasar.mobile_commons:backfill_user_profiles',
            'northstar_to_quasar_import = quasar.northstar_to_user_table:full_backfill',
            'northstar_to_quasar_import_backfill = quasar.northstar_to_user_table:backfill_since',
            'quasar_blink_queue_consumer = quasar.customerio:main',
            'phoenix_next_cleanup = quasar.phoenix_next_queue_cleanup:main',
            'regenerate_mobile_master_lookup_lite_table = quasar.create_mobile_master_lookup_lite:main',
            'rogue_generic_pub = quasar.rogue_queue_test:pub_generic',
            'rogue_test_pub = quasar.rogue_queue_test:pub_rogue',
            'rogue_test_route = quasar.rogue_queue_test:test_consume',
            'rogue_test_consume = quasar.rogue_queue_test:rogue_consume',
            'runscope_cleanup = quasar.cio_runscope_queue_cleanup:main',
            'reportbacks_asterisk = quasar.reportback_asterisk:run_load_reportbacks',
            'scrape_moco_profiles = quasar.moco_scraper:start_profile_scrape',
            'scrape_moco_messages = quasar.moco_scraper:start_message_scrape'
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
