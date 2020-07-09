import os
import contentful
from pprint import pprint
from .sa_database import Database
import jsonpickle

db = Database()


def fetch_contentful_data():
    client = contentful.Client(
        os.environ.get('CONTENTFUL_SPACE_ID'),
        os.environ.get('CONTENTFUL_ACCESS_TOKEN')
    )
    entries = client.entries({
        'content_type': 'campaign',
        'select': 'sys.id,fields',
        'limit': 1000  # API Limit: 1000 max
    })

    for entry in entries:
        _save_campaign(entry)

    db.disconnect()


def _save_campaign(campaign):
    try:
        record = {
            'contentful_id': campaign.id,
            'fields': jsonpickle.encode(campaign.fields())
        }

        query = ''.join(("INSERT INTO " + os.environ.get('CONTENTFUL_METADATA_RAW') + "( "
                         "contentful_id,fields)"
                         "VALUES (:contentful_id,:fields) "
                         "ON CONFLICT (contentful_id) "
                         "DO UPDATE SET "
                         "fields = :fields"))
        db.query_str(query, record)
    except (TypeError) as te:
        pprint('{contentful_id} ran into a type error: {error}'.format(contentful_id=campaign.id, error=te))
    except (AttributeError) as e:
        pprint('{contentful_id} missing an attribute: {error}'.format(contentful_id=campaign.id, error=e))


def main():
    fetch_contentful_data()
