from datetime import datetime as dt
import time
import re
import sys

from .config import config
from .northstarscraper import NorthstarScraper
from .utils import strip_str
from .database import Database

"""DS Northstar to Quasar User ETL script.

This ETL scripts scrapes the DoSomething Thor Northstar User API and ETL's the
output to our MySQL Quasar data warehouse.

The script takes an optional argument for what Northstar page result to start
on. This is mostly used to backfill from a certain page, or from the dawn
of time. Otherwise, pagination is stored in an small status tracking table
that gets updated on ingestion loop.

"""


class NorthstarDB:

    def __init__(self):
        db_opts = {'use_unicode': True, 'charset': 'utf8'}
        self.db = Database(db_opts)

    def teardown(self):
        self.db.disconnect()

    def get_start_page(self):
        querystr = "SELECT * from %s WHERE counter_name = 'last_page_scraped'" % config.ns_counter_table
        last_page = self.db.query(querystr)
        return last_page[0][1]

    def update_start_page(self, page):
        self.db.query("REPLACE INTO %s (counter_name, counter_value) VALUES(\"last_page_scraped\", \"%s\")" % (
            config.ns_counter_table, page))

    def save_user(self, user):
        self.db.query_str("INSERT INTO quasar.users (northstar_id,\
                        northstar_created_at_timestamp,\
                        last_logged_in, last_accessed, drupal_uid,\
                        northstar_id_source_name,\
                        email, facebook_id,\
                        mobile, birthdate,\
                        first_name, last_name,\
                        addr_street1, addr_street2,\
                        addr_city, addr_state,\
                        addr_zip, country, language,\
                        agg_id, cgg_id,\
                        moco_current_status,\
                        moco_source_detail)\
                        VALUES(%s,%s,%s,%s,%s,%s,\
                        %s,%s,%s,%s,%s,\
                        %s,%s,%s,%s,\
                        %s,%s,%s,%s,\
                        NULL,NULL,%s,%s,%s)\
                        ON DUPLICATE KEY UPDATE \
                        northstar_created_at_timestamp = %s,\
                        last_logged_in = %s,\
                        last_accessed = %s, drupal_uid = %s,\
                        northstar_id_source_name = %s,\
                        email = %s, facebook_id = %s,\
                        mobile = %s, birthdate = %s,\
                        first_name = %s, last_name = %s,\
                        addr_street1 = %s, addr_street2 = %s,\
                        addr_city = %s, addr_state = %s,\
                        addr_zip = %s, country = %s, language = %s,\
                        agg_id = NULL, cgg_id = NULL,\
                        moco_current_status = %s,\
                        moco_source_detail = %s",
                          (strip_str(user['id']),
                           strip_str(user['created_at']),
                           strip_str(user['last_authenticated_at']),
                           strip_str(user['last_accessed_at']),
                           strip_str(user['drupal_id']),
                           strip_str(user['source']),
                           strip_str(user['email']),
                           strip_str(user['facebook_id']),
                           strip_str(user['mobile']),
                           strip_str(user['birthdate']),
                           strip_str(user['first_name']),
                           strip_str(user['last_name']),
                           strip_str(user['addr_street1']),
                           strip_str(user['addr_street2']),
                           strip_str(user['addr_city']),
                           strip_str(user['addr_state']),
                           strip_str(user['addr_zip']),
                           strip_str(user['country']),
                           strip_str(user['language']),
                           strip_str(user['sms_status']),
                           strip_str(user['source_detail']),
                           strip_str(user['created_at']),
                           strip_str(user['last_authenticated_at']),
                           strip_str(user['last_accessed_at']),
                           strip_str(user['drupal_id']),
                           strip_str(user['source']),
                           strip_str(user['email']),
                           strip_str(user['facebook_id']),
                           strip_str(user['mobile']),
                           strip_str(user['birthdate']),
                           strip_str(user['first_name']),
                           strip_str(user['last_name']),
                           strip_str(user['addr_street1']),
                           strip_str(user['addr_street2']),
                           strip_str(user['addr_city']),
                           strip_str(user['addr_state']),
                           strip_str(user['addr_zip']),
                           strip_str(user['country']),
                           strip_str(user['language']),
                           strip_str(user['mobilecommons_id']),
                           strip_str(user['mobilecommons_status']),
                           strip_str(user['source_detail'])))


def _interval(hours_ago):
    def _format(hr):
        _time = int(time.time()) - (int(hr) * 3600)
        formatted = dt.fromtimestamp(_time).isoformat()
        return formatted

    start = _format(hours_ago)
    end = _format(hours_ago - 1)
    return (start, end)


def full_backfill():
    _backfill()


def backfill_since():
    _backfill(sys.argv[1])


def _backfill(hours_ago=None):
    start_time = time.time()

    db = NorthstarDB()
    scraper = NorthstarScraper(config.ns_uri)
    save_progress = hours_ago is None

    def _process_page(page_n, page_response):
        res = page_response
        for user in res['data']:
            db.save_user(user)
        if save_progress:
            db.update_start_page(page_n)

    if hours_ago is not None:
        intervals = [_interval(hour) for hour in range(
            int(hours_ago) + 1) if hour > 0]

        for start, end in intervals:
            create_params = {'after[created_at]': str(
                start), 'before[created_at]': str(end)}
            update_params = {'after[updated_at]': str(
                start), 'before[updated_at]': str(end)}
            scraper.process_all_pages(
                '/v1/users', create_params, _process_page)
            scraper.process_all_pages(
                '/v1/users', update_params, _process_page)

    else:
        start_page = db.get_start_page()
        scraper.process_all_pages(
            '/v1/users', {'page': start_page}, _process_page)

    db.teardown()

    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    print('duration: ', duration)


if __name__ == "__main__":
    _backfill()
