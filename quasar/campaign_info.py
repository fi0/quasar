import json
import logging
import os
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
            info = scraper.get(path).json()
            logging.info('Scraped ID %s.', (id[0]))
    except:
        logging.info('Ruh ruh, something went wrong!')


def main():
    update_campaign_info()
    db.disconnect()


if __name__ == "__main__":
    main()
