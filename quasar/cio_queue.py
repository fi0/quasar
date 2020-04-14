import json
import os
import pydash
import sys

from .sa_database import Database
from .queue import QuasarQueue
from .utils import log, logerr


class CioQueue(QuasarQueue):

    def __init__(self):
        self.amqp_uri = os.environ.get('AMQP_URI')
        self.blink_queue = os.environ.get('BLINK_QUEUE')
        self.blink_exchange = os.environ.get('BLINK_EXCHANGE')
        super().__init__(self.amqp_uri, self.blink_queue,
                         self.blink_exchange)
        self.db = Database()

    # Save customer sub/unsub data and dates.
    def _add_sub_event(self, data):
        record = {
            'customer_id': data['data']['customer_id'],
            'event_id': data['event_id'],
            'timestamp': data['timestamp'],
            'event_type': data['event_type']
        }
        query = ''.join(("INSERT INTO cio.customer_event_scratch "
                         "(customer_id, event_id, timestamp, "
                         "event_type) VALUES (:customer_id,"
                         ":event_id,to_timestamp(:timestamp),:event_type)"))
        self.db.query_str(query, record)
        log(''.join(("Added customer event from "
                     "C.IO event id {}.")).format(data['event_id']))

    # Save email event data and dates, e.g. email_click.
    def _add_email_event(self, data):
        record = {
            'customer_id': data['data']['customer_id'],
            'email_address': data['data']['email_address'],
            'event_id': data['event_id'],
            'timestamp': data['timestamp'],
            'event_type': data['event_type']
        }
        query = ''.join(("INSERT INTO cio.email_event_scratch "
                         "(customer_id, email_address, event_id, timestamp, "
                         "event_type) VALUES (:customer_id,:email_address,"
                         ":event_id,to_timestamp(:timestamp),:event_type)"))
        self.db.query_str(query, record)
        log(''.join(("Added email event from "
                     "C.IO event id {}.")).format(data['event_id']))

    # Save email sent event.
    def _add_email_sent_event(self, data):
        record = {
            'customer_id': data['data']['customer_id'],
            'email_address': data['data']['email_address'],
            'subject': data['data']['subject'],
            'event_id': data['event_id'],
            'timestamp': data['timestamp']
        }
        query = ''.join(("INSERT INTO cio.email_sent_scratch "
                         "(customer_id, email_address, "
                         "subject, event_id, timestamp) VALUES "
                         "(:customer_id,:email_address,"
                         ":subject,:event_id,to_timestamp(:timestamp))"))
        self.db.query_str(query, record)
        log(''.join(("Added email event from "
                     "C.IO event id {}.")).format(data['event_id']))

    # Save email event data and dates, e.g. email_click.
    def _add_email_click_event(self, data):
        record = {
            'customer_id': data['data']['customer_id'],
            'email_address': data['data']['email_address'],
            'subject': data['data']['subject'],
            'href': data['data']['href'],
            'link_id': data['data']['link_id'],
            'event_id': data['event_id'],
            'timestamp': data['timestamp'],
            'event_type': data['event_type']
        }
        query = ''.join(("INSERT INTO cio.email_event_scratch "
                         "(customer_id, email_address, subject, href, "
                         "link_id, event_id, timestamp, event_type) VALUES "
                         "(:customer_id,:email_address,"
                         ":subject,:href,:link_id,"
                         ":event_id,to_timestamp(:timestamp),"
                         ":event_type)"))
        self.db.query_str(query, record)
        log(''.join(("Added email event from "
                     "C.IO event id {}.")).format(data['event_id']))

        # Save email bounced event.
    def _add_email_bounced_event(self, data):
        record = {
            'customer_id': data['data']['customer_id'],
            'email_address': data['data']['email_address'],
            'subject': data['data']['subject'],
            'event_id': data['event_id'],
            'timestamp': data['timestamp']
        }
        query = ''.join(("INSERT INTO cio.email_bounced_scratch "
                         "(customer_id, email_address, "
                         "subject, event_id, timestamp) VALUES "
                         "(:customer_id,:email_address,:subject,:event_id,"
                         "to_timestamp(:timestamp))"))
        self.db.query_str(query, record)
        log(''.join(("Added email bounced event from "
                     "C.IO event id {}.")).format(data['event_id']))

    def process_message(self, message_data):
        data = message_data['data']
        event_type = pydash.get(data, 'event_type')
        # Set for checking email event types.
        email_event = {
            'email_bounced',
            'email_converted',
            'email_opened',
            'email_unsubscribed'
        }
        try:
            if (event_type == 'customer_subscribed' or
                    event_type == 'customer_unsubscribed'):
                self._add_sub_event(data)
            elif event_type == 'email_clicked':
                self._add_email_click_event(data)
            elif event_type == 'email_sent':
                self._add_email_sent_event(data)
            elif event_type == 'email_bounced':
                self._add_email_bounced_event(data)
            elif event_type in email_event:
                self._add_email_event(data)
            else:
                pass
        except KeyError as e:
            logerr("C.IO message missing {}".format(e))
        except:
            logerr("Something went wrong with C.IO consumer!")
            sys.exit(1)
