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

    def process_message(self, message_data):
        # Extract data subfield.
        data = message_data['data']
        # Get timestamp entry.
        timestamp = data['timestamp']
        try:
            self.db.insert_event(data, timestamp)
        except:
            logerr("Something went wrong with C.IO consumer!")
            self.db.disconnect()
            sys.exit(1)
