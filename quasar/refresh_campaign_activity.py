from .database import Database
import time


def main():
    db = Database()
    start_time = time.time()
    """Keep track of start time of script."""

    db.query("REFRESH MATERIALIZED VIEW CONCURRENTLY public.signups")
    db.query("REFRESH MATERIALIZED VIEW CONCURRENTLY public.latest_post")
    db.query("REFRESH MATERIALIZED VIEW CONCURRENTLY public.posts")
    db.query("REFRESH MATERIALIZED VIEW CONCURRENTLY public.reported_back")
    db.query("REFRESH MATERIALIZED VIEW CONCURRENTLY public.campaign_activity")
    db.disconnect()

    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    print('duration: ', duration)


if __name__ == "__main__":
    main()
