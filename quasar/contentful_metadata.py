import os
import contentful
from pprint import pprint
from .sa_database import Database
import jsonpickle
from urllib3.exceptions import ReadTimeoutError

db = Database()


def fetch_contentful_data():
    client = contentful.Client(
        space_id=os.environ.get('CONTENTFUL_SPACE_ID'),
        access_token=os.environ.get('CONTENTFUL_ACCESS_TOKEN'),
        timeout_s=int(os.environ.get('CONTENTFUL_TIMEOUT'))
    )
    entries = client.entries({
        'content_type': 'campaign',
        'select': 'sys.id,fields',
        'limit': os.environ.get('CONTENTFUL_API_LIMIT')  # API Limit: 1000 max
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
    except (ReadTimeoutError) as timeout:
        pprint('The API threw a timeout error: {error}'.format(error=timeout))


def main():
    fetch_contentful_data()
