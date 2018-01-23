import json

from .config import config
from .database import Database
from .queue import QuasarQueue
from .rogue_queue import RogueQueue
from .utils import unixtime_to_isotime as u2i
from .utils import strip_str


db = Database()


class CioQueue(QuasarQueue):

    def __init__(self):
        super(CioQueue, self).__init__(config.AMQP_URI, config.BLINK_QUEUE,
                                       config.BLINK_EXCHANGE)
        self.rogue_queue = RogueQueue()

    def process_message(self, message_data):
        if ('message_source' in message_data['data']['meta'] and
                message_data['data']['meta']['message_source'] == 'rogue'):
            print("Routing message to Rogue queue.")
            self.rogue_queue.pub_message(message_data)
        else:
            print(''.join(("Processing C.IO event id: "
                           "{}.")).format(message_data['data']['event_id']))
            log_event(db, message_data)
            customer_event(db, message_data)
            event_type = message_data['data']['event_type']
            if (event_type == 'customer_subscribed' or
                    event_type == 'customer_unsubscribed'):
                legacy_sub_unsub(db, message_data)


def log_event(db, message_data):
    db.query_str(''.join(("INSERT INTO cio.event_log"
                          "(meta, data) VALUES (%s, %s)")),
                 (json.dumps(message_data['meta']),
                  json.dumps(message_data['data'])))


def customer_event(db, message_data):
    db.query_str("INSERT INTO cio.customer_event VALUES (%s, %s, %s, %s)",
                 (message_data['data']['event_type'],
                  message_data['data']['event_id'],
                  u2i(message_data['data']['timestamp']),
                  message_data['data']['data']['customer_id']))


def legacy_sub_unsub(db, message_data):
    nsid = db.query_str(''.join(("SELECT northstar_id FROM quasar.users "
                                 "WHERE email = %s")),
                        (message_data['data']['data']['email_address'],))
    if message_data['data']['event_type'] == 'customer_subscribed':
        status = 'subscribed'
    else:
        status = 'unsubscribed'
    if strip_str(nsid) != "":
        db.query_str(''.join(("UPDATE quasar.users SET "
                              "customer_io_subscription_status = %s, "
                              "customer_io_subscription_timestamp = %s"
                              " WHERE northstar_id = %s")),
                     (status,
                      u2i(message_data['data']['timestamp']),
                      strip_str(nsid)))
    else:
        db.query_str("INSERT INTO cio.legacy_sub_backlog VALUES (%s, %s, %s)",
                     (status,
                      u2i(message_data['data']['timestamp']),
                      message_data['data']['data']['customer_id']))


queue = CioQueue()


def main():
    queue.start_consume()
