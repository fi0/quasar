import json
import os
import pydash
import sys

from .database import Database
from .queue import QuasarQueue
from .utils import log, logerr


class CioQueue(QuasarQueue):

    def __init__(self):
        self.amqp_uri = os.environ.get('AMQP_URI')
        self.cio_queue = os.environ.get('CIO_QUEUE')
        self.quasar_exchange = os.environ.get('QUASAR_EXCHANGE')
        super().__init__(self.amqp_uri, self.cio_queue,
                         self.quasar_exchange)
        self.db = Database()

    # Save entire c.io JSON blob to event_log table.
    def _log_event(self, data):
        self.db.query_str(''.join(("INSERT INTO cio.event_log "
                                   "(event) VALUES (%s)")),
                          (json.dumps(data),))
        log(''.join(("Logged data from "
                     "C.IO event id {}.")).format(data['event_id']))

    # Save customer sub data and dates.
    def _add_sub_event(self, data):
        self.db.query_str(''.join(("INSERT INTO cio.customer_event "
                                   "(email_id, customer_id, email_address, "
                                   "event_id, timestamp, "
                                   "event_type) VALUES (%s,%s,%s,%s,"
                                   "to_timestamp(%s),%s) "
                                   "ON CONFLICT (email_id, customer_id, "
                                   "timestamp, event_type) "
                                   "DO NOTHING")),
                          (data['data']['email_id'],
                           data['data']['customer_id'],
                           data['data']['email_address'],
                           data['event_id'], data['timestamp'],
                           data['event_type']))
        return data['event_id']

    # Save customer unsub data and dates.
    def _add_unsub_event(self, data):
        if pydash.get(data, 'template_id'):
            self.db.query_str(''.join(("INSERT INTO cio.customer_event "
                                       "(email_id, customer_id,"
                                       "email_address, template_id, event_id,"
                                       "timestamp, event_type) "
                                       "VALUES (%s,%s,%s,%s,%s,"
                                       "to_timestamp(%s),%s) "
                                       "ON CONFLICT (email_id, customer_id, "
                                       "timestamp, event_type) "
                                       "DO NOTHING")),
                              (data['data']['email_id'],
                               data['data']['customer_id'],
                               data['data']['email_address'],
                               data['data']['template_id'],
                               data['event_id'], data['timestamp'],
                               data['event_type']))
        else:
            self.db.query_str(''.join(("INSERT INTO cio.customer_event "
                                       "(email_id, customer_id,"
                                       "email_address, event_id, "
                                       "timestamp, event_type) "
                                       "VALUES (%s,%s,%s,%s,"
                                       "to_timestamp(%s),%s) "
                                       "ON CONFLICT (email_id, customer_id, "
                                       "timestamp, event_type) "
                                       "DO NOTHING")),
                              (data['data']['email_id'],
                               data['data']['customer_id'],
                               data['data']['email_address'],
                               data['event_id'], data['timestamp'],
                               data['event_type']))
        log(''.join(("Added customer event from "
                     "C.IO event id {}.")).format(data['event_id']))

    # Save email event data and dates, e.g. email_click.
    def _add_email_event(self, data):
        self.db.query_str(''.join(("INSERT INTO cio.email_event "
                                   "(email_id, customer_id, email_address, "
                                   "template_id, event_id, timestamp, "
                                   "event_type) VALUES "
                                   "(%s,%s,%s,%s,%s,to_timestamp(%s),%s) "
                                   "ON CONFLICT (email_id, customer_id, "
                                   "timestamp, event_type) "
                                   "DO NOTHING")),
                          (data['data']['email_id'],
                           data['data']['customer_id'],
                           data['data']['email_address'],
                           data['data']['template_id'],
                           data['event_id'], data['timestamp'],
                           data['event_type']))
        log(''.join(("Added email event from "
                     "C.IO event id {}.")).format(data['event_id']))

    # Save email sent event.
    def _add_email_sent_event(self, data):
        self.db.query_str(''.join(("INSERT INTO cio.email_sent "
                                   "(email_id, customer_id, email_address, "
                                   "template_id, subject, event_id, "
                                   "timestamp) VALUES "
                                   "(%s,%s,%s,%s,%s,%s,to_timestamp(%s)) "
                                   "ON CONFLICT (email_id, customer_id, "
                                   "timestamp) DO NOTHING")),
                          (data['data']['email_id'],
                           data['data']['customer_id'],
                           data['data']['email_address'],
                           data['data']['template_id'],
                           data['data']['subject'],
                           data['event_id'], data['timestamp']))
        log(''.join(("Added email event from "
                     "C.IO event id {}.")).format(data['event_id']))

    # Save email event data and dates, e.g. email_click.
    def _add_email_click_event(self, data):
        self.db.query_str(''.join(("INSERT INTO cio.email_event "
                                   "(email_id, customer_id, email_address, "
                                   "template_id, subject, href, link_id, "
                                   "event_id, timestamp, "
                                   "event_type) VALUES "
                                   "(%s,%s,%s,%s,%s,%s,%s,%s,"
                                   "to_timestamp(%s),%s) "
                                   "ON CONFLICT (email_id, customer_id, "
                                   "timestamp, event_type) "
                                   "DO NOTHING")),
                          (data['data']['email_id'],
                           data['data']['customer_id'],
                           data['data']['email_address'],
                           data['data']['template_id'],
                           data['data']['subject'],
                           data['data']['href'],
                           data['data']['link_id'],
                           data['event_id'], data['timestamp'],
                           data['event_type']))
        log(''.join(("Added email event from "
                     "C.IO event id {}.")).format(data['event_id']))

        # Save email bounced event.
    def _add_email_bounced_event(self, data):
        self.db.query_str(''.join(("INSERT INTO cio.email_bounced "
                                   "(email_id, customer_id, email_address, "
                                   "template_id, event_id, "
                                   "timestamp) VALUES "
                                   "(%s,%s,%s,%s,%s,to_timestamp(%s)) "
                                   "ON CONFLICT (email_id, customer_id, "
                                   "timestamp) DO NOTHING")),
                          (data['data']['email_id'],
                           data['data']['customer_id'],
                           data['data']['email_address'],
                           data['data']['template_id'],
                           data['event_id'], data['timestamp']))
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
        # Always capture atomic c.io event in raw format.
        self._log_event(data)
        try:
            if event_type == 'customer_subscribed':
                self._add_sub_event(data)
            elif event_type == 'customer_unsubscribed':
                self._add_unsub_event(data)
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
