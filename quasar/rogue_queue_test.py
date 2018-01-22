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


rogue_queue = RogueQueue()


class TestQueue(QuasarQueue):

    def __init__(self):
        super(TestQueue, self).__init__(config.AMQP_URI, config.TEST_QUEUE,
                                        config.QUASAR_EXCHANGE)

    def pub_generic_messages(self):
        for i in range(100):
            print(''.join(("Publishing generic message {} to "
                           "queue {}.")).format(i, config.TEST_QUEUE))
            message_data = {"data": {"data": {"timestamp": time.time() },
                            "meta": {"message_num": i } } }
            self.pub_message(self.body_encode(message_data))

    def pub_test_rogue_messages(self):
        for i in range(100):
            print(''.join(("Publishing Rogue test message {} to "
                           "queue {}.")).format(i, config.TEST_QUEUE))
            message_data = {"data": {"data": {"timestamp": time.time() },
                            "meta": {"message_source": "rogue" } } }
            self.pub_message(self.body_encode(message_data))

    def process_message(self, message_data):
        message = json.loads(message_data)
        if ('message_source' in message['data']['meta'] and
                message['data']['meta']['message_source'] == 'rogue'):
            print("Routing Rogue message to Rogue queue.")
            rogue_queue.pub_message(message_data)
        else:
            message_num = message['data']['meta']['message_num']
            print(''.join(("Generic message {} processed."
                           "")).format(message_num))


test_queue = TestQueue()


def pub_generic():
    test_queue.pub_generic_messages()


def pub_rogue():
    test_queue.pub_test_rogue_messages()


def test_consume():
    test_queue.start_consume()


def rogue_consume():
    rogue_queue.start_consume()
