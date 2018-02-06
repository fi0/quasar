import re
import sys

from .config import config
from .database import Database


class MemberEventLog:
    def __init__(self):
        db_opts = {'use_unicode': True, 'charset': 'utf8'}
        self.db = Database(db_opts)

    def teardown(self):
        self.db.disconnect()

    def drop_tables(self):
        drop_mel = "DROP TABLE IF EXISTS quasar.member_event_log;"
        drop_game_log = "DROP TABLE IF EXISTS quasar.sms_game_log;"
        self.db.query(drop_mel)
        self.db.query(drop_game_log)

    def create_game_log(self):
        game_log_query = """
         CREATE TABLE IF NOT EXISTS quasar.sms_game_log AS
            (SELECT
                concat(IF(mml.mu_uid > 0,
                            mml.mu_uid,
                            mml.ms_phone_number),
                            (mml.ms_activated_at),
                            mml.mc_run_id, 6) AS 'event_id',
                IF(mml.mu_uid > 0 , mml.mu_uid, mml.ms_phone_number) AS 'uid',
                (mml.ms_activated_at) AS 'timestamp',
                "sms_game" AS 'action',
                "6" AS 'action_id',
                mml.mc_run_id AS 'run_nid',
                mml.n_title AS 'run_name'
            FROM users_and_activities.mobile_master_lookup_lite mml
            LEFT JOIN quasar.campaign_info ci
                ON ci.campaign_run_id = mml.mc_run_id
            WHERE (ci.campaign_type = 'sms_game' OR ci.campaign_run_id = 7931));
	        """
        self.db.query(game_log_query)

    def create_member_event_log(self):
        mel_query = """
        CREATE TABLE IF NOT EXISTS quasar.member_event_log AS
        (SELECT
            concat(a.northstar_id,
                   a.timestamp,
                   a.action_id,
                   a.action_serial_id) AS 'event_id',
            a.action_serial_id,
            a.northstar_id AS 'northstar_id',
            a.timestamp AS 'timestamp',
            a.action AS 'action_type',
            a.action_id AS 'action_id',
            a.source AS 'source'
        FROM
            (SELECT ### campaign sign up ###
                ca.northstar_id AS 'northstar_id',
                    ca.signup_created_at AS 'timestamp',
                    "sign-up" AS 'action',
                    "1" AS 'action_id',
                    ca.signup_source AS 'source',
                    ca.signup_id AS 'action_serial_id'
                FROM quasar.campaign_activity ca
                WHERE ca.signup_created_at > '0000-00-00 00:00:00'
                UNION ALL
                SELECT ### campaign reportback ###
                rb.northstar_id AS 'northstar_id',
                rb.submission_created_at AS 'timestamp',
                "reportback" AS 'action',
                "2" AS 'action_id',
                rb.post_source AS 'source',
                rb.post_id AS 'action_serial_id'
            FROM quasar.campaign_activity rb
            WHERE rb.post_id > 0
            UNION ALL
            SELECT ### site access ###
                u.northstar_id AS 'northstar_id',
                u.last_accessed AS 'timestamp',
                "site_access" AS 'action',
                "3" AS 'action_id',
                NULL AS 'source',
                "0" AS 'action_serial_id'
            FROM quasar.users_log u
            WHERE u.last_accessed > u.created_at
            UNION ALL
            SELECT ### site login ###
                u.northstar_id AS 'northstar_id',
                u.last_logged_in AS 'timestamp',
                "site_login" AS 'action',
                "4" AS 'action_id',
                NULL AS 'source',
                "0" AS 'action_serial_id'
            FROM quasar.users_log u
            WHERE u.last_logged_in > u.created_at
            UNION ALL
            SELECT ### account creation ###
                u.northstar_id AS 'northstar_id',
                u.created_at AS 'timestamp',
                "account_creation" AS 'action',
                "7" AS 'action_id',
                u.source AS 'source',
                u.northstar_id AS 'action_serial_id'
            FROM quasar.users u) AS a)
        ORDER BY a.timestamp asc;"""
        self.db.query(mel_query)

    def add_indices(self):
        index_query = ''.join(("ALTER TABLE `quasar.member_event_log` "
                               "ADD INDEX "
                               "(event_id, northstar_id, timestamp)"))
        self.db.query(index_query)

    def sequence(self):
        self.drop_tables()
        self.create_game_log()
        self.create_member_event_log()
        self.add_indices()
        self.db.disconnect()


def mel():
    mel = MemberEventLog()
    mel.sequence()
