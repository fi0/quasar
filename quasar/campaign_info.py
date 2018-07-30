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
    # Refresh list of campaign id's to scrape from Rogue signups.
    db.query("REFRESH MATERIALIZED VIEW phoenix.campaign_ids")
    logging.info('Phoenix campaigns have been refreshed from rogue.signups.')


def update_campaign_info():
    refresh_campaign_ids()
    ids = db.query('SELECT * FROM phoenix.campaign_ids')
    # Remove all stale entries to ensure latest good data.
    db.query("TRUNCATE phoenix.campaigns_json")
    # Query each campaign id currently active from Phoenix campaign api.
    try:
        for id in ids:
            path = os.getenv('PHOENIX_CAMPAIGN_API_PATH') + id[0]
            result = scraper.get(path)
            if result.status_code == 200:
                info = result.json()
                logging.info('Scraped campaign {}.'.format((id[0])))
                # Insert raw json per campaign into db.
                db.query_str(''.join(("INSERT INTO phoenix.campaigns_json "
                                      "(campaign_data) VALUES (%s)")),
                             (json.dumps(info),))
                logging.info('Campaign {} added to db.'.format((id[0])))

            else:
                logging.error(''.join(('{} status code returned for campaign '
                                      '{}.'.format(result.status_code,
                                                   id[0]))))
    except:
        logging.info('Something went wrong!')
        logging.info('Exiting on campaign {}.'.format((id[0])))
        sys.exit(1)


def main():
    update_campaign_info()
    db.disconnect()


if __name__ == "__main__":
    main()
