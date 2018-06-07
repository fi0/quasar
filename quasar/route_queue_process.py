from .quasar_queue import RouteQueue


queue = RouteQueue()


def main():
    queue.start_consume()
