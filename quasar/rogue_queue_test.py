import json
import pydash
import time


from .config import config
from .queue import QuasarQueue
from .rogue_queue import RogueQueue


class TestQueue(QuasarQueue):

    def __init__(self):
        super(TestQueue, self).__init__(config.AMQP_URI, config.TEST_QUEUE,
                                        config.QUASAR_EXCHANGE)
        self.rogue_queue = RogueQueue()

    def pub_generic_messages(self):
        for i in range(100):
            print(''.join(("Publishing generic message {} to "
                           "queue {}.")).format(i, config.TEST_QUEUE))
            message_data = {"data": {"data": {"timestamp": time.time()},
                            "meta": {"message_num": i}}}
            self.pub_message(message_data)

    def pub_test_rogue_messages(self):
        for i in range(100):
            print(''.join(("Publishing Rogue test message {} to "
                           "queue {}.")).format(i, config.TEST_QUEUE))
            message_data = {"data": {"data": {"timestamp": time.time()},
                            "meta": {"message_source": "rogue"}}}
            self.pub_message(message_data)

    def process_message(self, message_data):
        if pydash.get(message_data, 'data.meta.message_source') == 'rogue':
            print("Routing Rogue message to Rogue queue.")
            self.rogue_queue.pub_message(message_data)
        else:
            message_num = message_data['data']['meta']['message_num']
            print(''.join(("Generic message {} processed."
                           "")).format(message_num))


def pub_generic():
    test_queue = TestQueue()
    test_queue.pub_generic_messages()


def pub_rogue():
    test_queue = TestQueue()
    test_queue.pub_test_rogue_messages()


def test_consume():
    test_queue = TestQueue()
    test_queue.start_consume()


def rogue_consume():
    rogue_queue = RogueQueue()
    rogue_queue.start_consume()
