from .sa_database import Database
from .utils import Duration


def main():
    db = Database()
    duration = Duration()

    db.query("REFRESH MATERIALIZED VIEW public.path_campaign_lookup")
    db.query("REFRESH MATERIALIZED VIEW ft_puck_heroku_wzsf6b3z.phoenix_utms")
    db.query("REFRESH MATERIALIZED VIEW public.phoenix_events")
    db.query("REFRESH MATERIALIZED VIEW public.phoenix_sessions")
    db.query("REFRESH MATERIALIZED VIEW public.device_northstar_crosswalk")
    db.disconnect()

    duration.duration()


if __name__ == "__main__":
    main()
