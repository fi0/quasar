from .config import config
from .quasar_queue import CioPostgresQueue


queue = CioPostgresQueue()


def main():
    queue.start_consume()
