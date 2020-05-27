import json
import os
import pydash
import sys

from .cio_database import Database
from .queue import QuasarQueue
from .utils import log, logerr, unixtime_to_isotime


class CioQueue(QuasarQueue):

    def __init__(self):
        self.amqp_uri = os.environ.get('AMQP_URI')
        self.blink_queue = os.environ.get('BLINK_QUEUE')
        self.blink_exchange = os.environ.get('BLINK_EXCHANGE')
        super().__init__(self.amqp_uri, self.blink_queue,
                         self.blink_exchange)
        self.db = Database()

    def process_message(self, message_data):
        # Extract data subfield.
        data = message_data['data']
        # Get timestamp entry and convert from Unixtime to ISO8601 format.
        timestamp = unixtime_to_isotime(data['timestamp'])
        # Get top-level event_id for logging purposes, but no PII revealed.
        event_id = data['event_id']
        try:
            self.db.insert_event(data, timestamp, event_id)
            log("Processed message with event_id: {}".format(event_id))
        except:
            logerr("Something went wrong with C.IO consumer!{}".format(sys.exc_info()))
            self.db.disconnect()
            sys.exit(1)
