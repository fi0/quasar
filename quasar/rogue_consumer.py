from .config import config
from .quasar_queue import RogueQueue


queue = RogueQueue()


def main():
    queue.start_consume()
