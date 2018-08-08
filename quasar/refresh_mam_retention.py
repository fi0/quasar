from .database import Database
import logging


logging.getLogger().setLevel(logging.INFO)


def main():
    db = Database()
    logging.info('Refreshing MAM retention materialized view.')
    db.query('REFRESH MATERIALIZED VIEW public.mam_retention')
    db.disconnect()


if __name__ == "__main__":
    main()
