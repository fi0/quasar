from setuptools import setup, find_packages
from pipenv.project import Project
from pipenv.utils import convert_deps_to_pip

pfile = Project(chdir=False).parsed_pipfile
requirements = convert_deps_to_pip(pfile['packages'], r=False)

setup(
    name="quasar",
    version="2020.11.3.0",
    packages=find_packages(),
    install_requires=requirements,
    entry_points={
        'console_scripts': [
            'bertly_refresh = quasar.bertly:refresh',
            'cio_consume = quasar.cio_consumer:main',
            'etl_monitoring = quasar.etl_monitoring:run_monitoring',
            'gdpr = quasar.gdpr_comply:main',
            'prod_to_qa = quasar.prod_to_qa:main',
            'contentful_metadata = quasar.contentful_metadata:main',
            'start_export_task = quasar.aws_s3:start_export_task',
            'check_backup_status = quasar.aws_s3:check_backup_status'
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
