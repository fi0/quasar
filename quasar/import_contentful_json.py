import os
import contentful
from pprint import pprint
from .sa_database import Database


db = Database()


def fetch_contentful_data():
    client = contentful.Client(
        os.environ.get('CONTENTFUL_SPACE_ID'),
        os.environ.get('CONTENTFUL_ACCESS_TOKEN')
    )
    entries = client.entries({
        'content_type': 'campaign',
        'select': 'sys.id,fields.legacyCampaignId,fields.internalTitle,fields.title',
        'limit': 500  # Only 381 campaigns so this should suffice for the time being (API Limit: 1000 max)
    })

    for entry in entries:
        _save_campaign(entry)


def _save_campaign(campaign):
    try:
        record = {
            'contentful_id': campaign.id,
            'legacy_campaign_id': campaign.legacy_campaign_id,
            'internal_title': campaign.internal_title,
            'title': campaign.title,
        }

        query = ''.join(("INSERT INTO public.contentful_metadata_test ( "
                         "contentful_id,legacy_campaign_id,internal_title, title)"
                         "VALUES (:contentful_id,:legacy_campaign_id,:internal_title,"
                         ":title) "
                         "ON CONFLICT (contentful_id) "
                         "DO UPDATE SET "
                         "legacy_campaign_id = :legacy_campaign_id, internal_title = :internal_title,"
                         "title = :title"))
        db.query_str(query, record)
    except (AttributeError) as e:
        pprint('{contentful_id} missing an attribute: {error}'.format(contentful_id=campaign.id, error=e))


def main():
    fetch_contentful_data()
