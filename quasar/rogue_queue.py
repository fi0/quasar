import json
import time

from .config import config
from .queue import QuasarQueue

class RogueQueue(QuasarQueue):

    def __init__(self):
        super(RogueQueue, self).__init__(config.AMQP_URI, config.ROGUE_QUEUE,
                                         config.QUASAR_EXCHANGE)

    def process_message(self, message_data):
        message = json.loads(message_data)
        print(''.join(("Timestamp {} for Rogue message consumed."
                       "")).format(message['data']['data']['timestamp']))
