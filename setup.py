from setuptools import setup, find_packages
from pipenv.project import Project
from pipenv.utils import convert_deps_to_pip

pfile = Project(chdir=False).parsed_pipfile
requirements = convert_deps_to_pip(pfile['packages'], r=False)

setup(
    name="quasar",
    version="2019.11.01.0",
    packages=find_packages(),
    install_requires=requirements,
    entry_points={
        'console_scripts': [
            'bertly_refresh = quasar.bertly:refresh',
            'campaign_info_recreate = quasar.campaign_info:create',
            'campaign_info_refresh = quasar.campaign_info:refresh',
            'campaign_activity_create = quasar.campaign_activity:create',
            'campaign_activity_refresh = quasar.campaign_activity:refresh',
            'cio_consume = quasar.cio_consumer:main',
            'cio_import = quasar.cio_import_scratch_records:cio_import',
            'cio_bounced_backfill = quasar.cio_bounced_backfill:main',
            'cio_sent_backfill = quasar.cio_sent_backfill:main',
            'etl_monitoring = quasar.etl_monitoring:run_monitoring',
            'gambit_messages_create = quasar.gambit:create_gambit_messages',
            'gambit_messages_refresh = quasar.gambit:refresh_gambit_messages',
            'gdpr = quasar.gdpr_comply:gdpr_from_file',
            'mel_create = quasar.mel:create',
            'mel_create_for_dbt_validation = quasar.mel:create_for_dbt_validation',
            'mel_refresh = quasar.mel:refresh',
            'northstar_backfill = quasar.northstar_to_user_table:backfill',
            'northstar_full_backfill = quasar.northstar_to_user_table_full_backfill:backfill',
            'post_actions_create = quasar.create_post_actions:main',
            'rogue_ghost_killer = quasar.ghost_killer:main',
            'users_create = quasar.users:create',
            'users_refresh = quasar.users:refresh',
            'user_activity_create = quasar.user_activity:create',
            'user_activity_create_for_dbt_validation = quasar.user_activity:create_for_dbt_validation',
            'user_activity_refresh = quasar.user_activity:refresh'
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
