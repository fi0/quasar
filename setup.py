from setuptools import setup, find_packages


setup(
    name="quasar",
    version="0.1.0",
    packages=find_packages(),
    entry_points={
        'console_scripts': [
            'campaign_activity_backfill_diff = quasar.campaign_activity:backfill_since',
            'campaign_activity_full_backfill = quasar.campaign_activity:full_backfill',
            'campaign_info_table_refresh = quasar.phoenix_to_campaign_info_table:main',
            'daily_phoenix_db_user_snapshot = quasar.daily_phoenix_db_snapshot:main',
            'import_UID_to_mobile_user_lookup_table = quasar.import_uid_by_phone_number:main',
            'legacy_mobile_campaign_table_update = quasar.mobile_commons:convert_campaign_lookup_to_id',
            'list_tracking = quasar.jc_list_tracking:main',
            'mobile_campaign_lookup_table_update = quasar.mobile_commons:scrape_campaigns',
            'mobile_subscriptions = quasar.jc_subscribers:main',
            'mobile_user_table_update = quasar.mobile_commons:backfill_user_profiles',
            'northstar_to_quasar_import = quasar.northstar_to_user_table:main', #fix mysql
            'quasar_blink_queue_consumer = quasar.customerio:main',
            'refresh_quasar_user_log_table_from_phoenix = quasar.update_phoenix_user_log:main',
            'regenerate_mobile_master_lookup_lite_table = quasar.create_mobile_master_lookup_lite:main',
            'update_demographics = quasar.jc_run_update:main',
            'update_mobile = quasar.jc_update_mobile:main',
            'us_phone_number_cleanup = quasar.us_phone_number_cleanup:main'
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
