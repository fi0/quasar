import json
import os
import pydash
import sys

from .cio_database import Database
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

    # Save customer sub data and dates.
    def _add_customer_event(self, data):
        self.db.insert_customer(data)
        log(''.join(("Added customer event from "
                     "C.IO event id {}.")).format(data['event_id']))

    # Save email event data and dates, e.g. email_click.
    def _add_email_event(self, data):
        self.db.insert_email(data)
        log(''.join(("Added email event from "
                     "C.IO event id {}.")).format(data['event_id']))

    # Save email sent event.
    def _add_email_sent_event(self, data):
        self.db.insert_email_sent(data)
        log(''.join(("Added email sent event from "
                     "C.IO event id {}.")).format(data['event_id']))

    # Save email bounced event.
    def _add_email_bounced_event(self, data):
        self.db.insert_email_bounced(data)
        log(''.join(("Added email bounced event from "
                     "C.IO event id {}.")).format(data['event_id']))

    def process_message(self, message_data):
        data = message_data['data']
        event_type = pydash.get(data, 'event_type')
        print(data)
        # Set for checking email event types.
        email_event = {
            'email_bounced',
            'email_converted',
            'email_opened',
            'email_unsubscribed',
            'email_clicked'
        }
        try:
            if (event_type == 'customer_subscribed' or
                    event_type == 'customer_unsubscribed'):
                self._add_customer_event(data)
            elif event_type in email_event:
                self._add_email_event(data)
            elif event_type == 'email_sent':
                self._add_email_sent_event(data)
            elif event_type == 'email_bounced':
                self._add_email_bounced_event(data)
            else:
                pass
        except KeyError as e:
            logerr("C.IO message missing {}".format(e))
            # Actually log missing data and exit so not dropping data.
            logerr("Message data is:")
            logerr(format(message_data))
            # Record error data to event_log and disconnect cleanly.
            self.db.commit_event(data)
            self.db.disconnect()
            sys.exit(1)
        except:
            logerr("Something went wrong with C.IO consumer!")
            # Record error data to event_log and disconnect cleanly.
            self.db.commit_event(data)
            self.db.disconnect()
            sys.exit(1)
