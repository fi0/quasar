from .config import config
from .quasar_queue import CioQueue


queue = CioQueue()


def main():
    queue.start_consume()
