from .quasar_queue import CioPostgresQueue


queue = CioPostgresQueue()


def main():
    queue.start_consume()
