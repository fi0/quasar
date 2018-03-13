from .quasar_queue import RoguePostgresQueue


queue = RoguePostgresQueue()


def main():
    queue.start_consume()
