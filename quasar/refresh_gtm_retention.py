from .database import Database
import logging


logging.getLogger().setLevel(logging.INFO)


def main():
    db = Database()
    logging.info('Refreshing GTM retention materialized view.')
    db.query('REFRESH MATERIALIZED VIEW public.gtm_retention')
    db.disconnect()


if __name__ == "__main__":
    main()
