import json
import logging
import os
import pydash
import sys

from .queue import QuasarQueue
from .cio_queue import CioQueue
from .rogue_queue import RogueQueue
from .utils import log


class RouteQueue(QuasarQueue):

    def __init__(self):
        self.amqp_uri = os.environ.get('AMQP_URI')
        self.blink_queue = os.environ.get('BLINK_QUEUE')
        self.blink_exchange = os.environ.get('BLINK_EXCHANGE')
        super().__init__(self.amqp_uri, self.blink_queue,
                         self.blink_exchange)
        self.rogue_queue = RogueQueue()
        self.cio_queue = CioQueue()

    def process_message(self, message_data):
        if pydash.get(message_data, 'data.meta.message_source') == 'rogue':
            message_id = pydash.get(message_data, 'data.data.id')
            log("Routing message {} to Rogue queue.".format(message_id))
            self.rogue_queue.pub_message(message_data)
        else:
            log(''.join(("Publishing C.IO event id:"
                         "{} to c.io Postgres queue."
                         "")).format(message_data['data']['event_id']))
            self.cio_queue.pub_message(message_data)
