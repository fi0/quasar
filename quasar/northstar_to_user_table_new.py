from datetime import datetime as dt
import json
import os
import sys
import time

from .northstar_scraper import NorthstarScraper
from .sa_database import Database
from .utils import Duration

"""DS Northstar to Quasar User ETL script.

This ETL scripts scrapes the DoSomething Thor Northstar User API and ETL's the
output to our MySQL Quasar data warehouse.

The script takes an optional argument for what Northstar page result to start
on. This is mostly used to backfill from a certain page, or from the dawn
of time. Otherwise, pagination is stored in an small status tracking table
that gets updated on ingestion loop.

"""

db = Database()
scraper = NorthstarScraper(os.environ.get('NS_URI'))


def _save_user(user):
    record = {
        'id': user['id'],
        'first_name': user['first_name'],
        'last_name': user['last_name'],
        'last_initial': user['last_initial'],
        'photo': user['photo'],
        'email': user['email'],
        'mobile': user['mobile'],
        'facebook_id': user['facebook_id'],
        'interest': user['interests'],
        'birthdate': user['birthdate'],
        'addr_street1': user['addr_street1'],
        'addr_street2': user['addr_street2'],
        'addr_city': user['addr_city'],
        'addr_state': user['addr_state'],
        'addr_zip': user['addr_zip'],
        'addr_source': user['addr_source'],
        'source': user['source'],
        'source_detail': user['source_detail'],
        'slack_id': user['slack_id'],
        'sms_status': user['sms_status'],
        'sms_paused': user['sms_paused'],
        'voter_registration_status': user['voter_registration_status'],
        'language': user['language'],
        'country': user['country'],
        'drupal_id': user['drupal_id'],
        'role': user['role'],
        'last_accessed_at': user['last_accessed_at'],
        'last_authenticated at': user['last_authenticated_at'],
        'last_messaged_at': user['last_messaged_at'],
        'updated_at': user['updated_at'],
        'created_at': user['created_at']
    }
    db.query_str(''.join(("INSERT INTO northstar.users (id, "
                          "first_name, last_name, last_initial, "
                          "photo, email, mobile, facebook_id, "
                          "interests, birthdate, addr_street1, "
                          "addr_street2, addr_city, addr_state, "
                          "addr_zip, addr_source, source, "
                          "source_detail, slack_id, sms_status, "
                          "sms_paused, voter_registration_status, "
                          "language, country, "
                          "drupal_id, role, last_accessed_at, "
                          "last_authenticated_at, "
                          "last_messaged_at, "
                          "updated_at, created_at) "
                          "VALUES (:id,:first_name,:last_name,:last_initial,"
                          ":photo,:email,:mobile,:facebook_id,:interests,"
                          ":birthdate,:addr_street1,:addr_street2,"
                          ":addr_city,:addr_state,:addr_zip,:addr_source,"
                          ":source,:source_detail,:slack_id,"
                          ":sms_status,:sms_paused,"
                          ":voter_registration_status,:language,:country,"
                          ":drupal_id,:role,:last_accessed_at,"
                          ":last_authenticated_at,:last_messaged_at,"
                          ":updated_at,:created_at) "
                          "ON CONFLICT (id, created_at, updated_at) "
                          "DO NOTHING")), record)


def _interval(hours_ago):
    # Return list of ISO8601 formatted timestamps
    # from hours_ago in format (hours_ago, hours_ago-1).
    def _format(hr):
        # Get ISO8601 formatted time from 'hr' hours ago.
        _time = int(time.time()) - (int(hr) * 3600)
        formatted = dt.fromtimestamp(_time).isoformat()
        return formatted

    start = _format(hours_ago)
    end = _format(hours_ago - 1)
    return (start, end)


def _process_page(results):
    users = results
    for user in users['data']:
        save_user(user)


def backfill(hours_ago):
    duration = Duration()
    # Get list of 1 hour chunks for total backfill hours_ago.
    intervals = [_interval(hour) for hour in
                 range(int(hours_ago) + 1) if hour > 0]
    # Backfill from most recent going backwards.
    intervals.reverse()

    for start, end in intervals:
        params = {'after[updated_at]': str(start),
                  'before[updated_at]': str(end),
                  'pagination': 'cursor'}

        # Set page param and next page to true assuming at least
        # one page of results exist.
        i = 1
        params['page'] = i
        path = '/v2/users'
        next = True
        while next is True:
            response = scraper.get(path, params).json()
            _process_page(response)
            if response['meta']['cursor']['next'] is None:
                next = False
            else:
                i += 1
                params['page'] = i

    db.disconnect()
    duration.duration()


if __name__ == "__main__":
    backfill()
