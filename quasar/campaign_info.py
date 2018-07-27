import json
import logging
import os
import sys

from .database import Database
from .ds_oauth_scraper import DSOAuthScraper

logging.getLogger().setLevel(logging.INFO)
scraper = DSOAuthScraper(os.getenv('PHOENIX_URI'))
db = Database()

def refresh_campaign_ids():
    db.query("REFRESH MATERIALIZED VIEW phoenix.campaign_ids")
    logging.info('Phoenix campaigns have been refreshed from rogue.signups.')


def update_campaign_info():
    refresh_campaign_ids()
    ids = db.query('SELECT * FROM phoenix.campaign_ids')
    try:
        for id in ids:
            path = os.getenv('PHOENIX_CAMPAIGN_API_PATH') + id[0]
            result = scraper.get(path)
            if result.status_code == 200:
                info = result.json()
                logging.info('Scraped campaign {}.'.format((id[0])))
            else:
                logging.error(''.join(('{} status code returned for campaign '
                                      '{}.'.format(result.status_code, id[0]))))
    except:
        logging.info('Something went wrong!')
        logging.info('Exiting on campaign {}.'.format((id[0])))
        sys.exit(1)


def main():
    update_campaign_info()
    db.disconnect()


if __name__ == "__main__":
    main()
