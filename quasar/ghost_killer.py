from .database_pg import Database
import time

db = Database()

def remove_ghost_posts():
    # Get list of all posts to remove.
    posts = db.query(''.join(("SELECT DISTINCT p.id "
                             "FROM rogue.signups s "
                             "INNER JOIN (SELECT g.id "
                             "FROM rogue.signups g WHERE g.why_participated = "
                             "'why_participated_ghost_test') ghost "
                             "ON s.id = ghost.id "
                             "INNER JOIN rogue.posts p ON p.signup_id = s.id")))

    # Copy all posts into ghost posts table to remove from official counts.
    for post in posts:
        db.query_str(''.join(("INSERT INTO rogue.ghost_posts SELECT * FROM "
                             "rogue.posts p WHERE p.id = %s")),
                     (post,))

    # Remove posts from posts table.
    for post in posts:
        db.query_str(''.join(("DELETE FROM rogue.posts p WHERE "
                              "p.id = %s")),
                     (post,))


def remove_ghost_signups():
    # Get list of all signups to remove.
    signups = db.query(''.join(("SELECT DISTINCT su.id FROM "
                                "rogue.signups su INNER JOIN "
                                "(SELECT DISTINCT s.id FROM rogue.signups s "
                                "WHERE s.why_participated = "
                                "'why_participated_ghost_test') ghost_ids "
                                "ON ghost_ids.id = su.id")))

    # Copy all signups into ghost signups table to remove from official counts.
    for signup in signups:
        db.query_str(''.join(("INSERT INTO rogue.ghost_signups SELECT * FROM "
                             "rogue.signups s WHERE s.id = %s")),
                     (signup,))

    # Remove signups from signups table.
    for signup in signups:
        db.query_str(''.join(("DELETE FROM rogue.signups s WHERE "
                              "s.id = %s")),
                     (signup,))


def main():
    start_time = time.time()
    """Keep track of start time of script."""

    remove_ghost_posts()
    remove_ghost_signups()
    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    print('duration: ', duration)


if __name__ == "__main__":
    main()
