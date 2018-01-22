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
        print("Meta is {}.".format(message['meta']))
        print("Data is {}.".format(message['data']))


rogue_queue = RogueQueue()


class TestQueue(QuasarQueue):

    def __init__(self):
        super(TestQueue, self).__init__(config.AMQP_URI, config.TEST_QUEUE,
                                        config.QUASAR_EXCHANGE)

    def pub_generic_messages(self):
        for i in range(100):
            print(''.join(("Publishing generic message {} to "
                           "queue {}.")).format(i, config.TEST_QUEUE))
            message_data = {"data": { "data": { "timestamp": time.time() },
                            "meta": { "message_num": i } } }
            self.pub_message(self.body_encode(message_data))

    def pub_test_rogue_messages(self):
        for i in range(100):
            print(''.join(("Publishing Rogue test message {} to "
                           "queue {}.")).format(i, config.TEST_QUEUE))
            message_data = {"data": { "data": { "timestamp": time.time() },
                            "meta": { "message_source": "rogue" } } }
            self.pub_message(self.body_encode(message_data))

    def process_message(self, message_data):
        message = json.loads(message_data)
        if ('message_source' in message['data']['meta'] and 
                message['data']['meta']['message_source'] == 'rogue'):
            print("Routing Rogue message to Rogue queue.")
            rogue_queue.pub_message(message_data)
        elif int(message['data']['meta']['message_num']) < 100:
            print(''.join(("Generic message {} processed."
                           "")).format(message['data']['meta']['message_num']))
        else:
            print("Message just ack'd.")


test_queue = TestQueue()


def pub_generic():
    test_queue.pub_generic_messages()

def pub_rogue():
    test_queue.pub_test_rogue_messages()

def test_consume():
    test_queue.start_consume()


def rogue_consume():
    rogue_queue.start_consume()
