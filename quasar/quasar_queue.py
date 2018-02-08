import json
import pydash
import sys

from .config import config
from .database import Database
from .queue import QuasarQueue
from .utils import unixtime_to_isotime as u2i
from .utils import strip_str


class CioQueue(QuasarQueue):

    def __init__(self):
        super(CioQueue, self).__init__(config.AMQP_URI, config.BLINK_QUEUE,
                                       config.BLINK_EXCHANGE)
        self.rogue_queue = RogueQueue()
        self.db = Database()

    def process_message(self, message_data):
        if pydash.get(message_data, 'data.meta.message_source') == 'rogue':
            print("Routing message to Rogue queue.")
            self.rogue_queue.pub_message(message_data)
        else:
            print(message_data)
            print(''.join(("Processing C.IO event id: "
                           "{}.")).format(message_data['data']['event_id']))
            self.log_event(message_data)
            self.customer_event(message_data)
            event_type = message_data['data']['event_type']
            if (event_type == 'customer_subscribed' or
                    event_type == 'customer_unsubscribed'):
                self.legacy_sub_unsub(message_data)

    def log_event(self, message_data):
        self.db.query_str(''.join(("INSERT INTO cio.event_log"
                          "(meta, data) VALUES (%s, %s)")),
                          (json.dumps(message_data['meta']),
                           json.dumps(message_data['data'])))

    def customer_event(self, message_data):
        self.db.query_str(''.join(("INSERT INTO cio.customer_event "
                                   "VALUES (%s, %s, %s, %s)")),
                          (message_data['data']['event_type'],
                           message_data['data']['event_id'],
                           u2i(message_data['data']['timestamp']),
                           message_data['data']['data']['customer_id']))

    def legacy_sub_unsub(self, message_data):
        email = message_data['data']['data']['email_address']
        nsid = self.db.query_str(''.join(("SELECT northstar_id "
                                          "FROM quasar.users "
                                          "WHERE email = %s")),
                                 (email,))
        if message_data['data']['event_type'] == 'customer_subscribed':
            status = 'subscribed'
        else:
            status = 'unsubscribed'
        if strip_str(nsid) != "":
            self.db.query_str(''.join(("UPDATE quasar.users SET "
                                       "customer_io_subscription_status = %s,"
                                       "customer_io_subscription_timestamp "
                                       " = %s WHERE northstar_id = %s")),
                              (status,
                               u2i(message_data['data']['timestamp']),
                               strip_str(nsid)))
        else:
            self.db.query_str(''.join(("INSERT INTO cio.legacy_sub_backlog "
                                       "VALUES (%s, %s, %s)")),
                              (status,
                               u2i(message_data['data']['timestamp']),
                               message_data['data']['data']['customer_id']))


class RogueQueue(QuasarQueue):

    def __init__(self):
        super(RogueQueue, self).__init__(config.AMQP_URI, config.ROGUE_QUEUE,
                                         config.QUASAR_EXCHANGE)
        self.db = Database()
        self.campaign_activity_table = config.CAMPAIGN_ACTIVITY_TABLE
        self.campaign_activity_log_table = config.CAMPAIGN_ACTIVITY_LOG_TABLE
        self.campaign_activity_details = config.CAMPAIGN_ACTIVITY_DETAIL_TABLE

    def _add_signup(self, signup_data):
        self.db.query_str(''.join(("REPLACE INTO ",
                                   self.campaign_activity_table,
                                   " SET northstar_id = %s, "
                                   "signup_id = %s, campaign_id = %s, "
                                   "campaign_run_id = %s, quantity = %s, "
                                   "why_participated = %s, "
                                   "signup_source = %s, signup_details = %s, "
                                   "signup_created_at = %s, "
                                   "signup_updated_at = %s, "
                                   "post_id = -1, url = NULL, "
                                   "caption = NULL, status = NULL, "
                                   "remote_addr = NULL, post_source = NULL, "
                                   "submission_created_at = ''")),
                          (signup_data['northstar_id'],
                           signup_data['signup_id'],
                           signup_data['campaign_id'],
                           signup_data['campaign_run_id'],
                           signup_data['quantity'],
                           signup_data['why_participated'],
                           signup_data['signup_source'],
                           signup_data['details'],
                           signup_data['created_at'],
                           signup_data['updated_at']))
        print("Signup {} ETL'd.".format(signup_data['signup_id']))

    def _delete_signup(self, signup_id, deleted_at):
        # Set signup status to 'deleted'.
        self.db.query_str(''.join(("UPDATE ",
                                   self.campaign_activity_table,
                                   " SET status = %s, "
                                   "signup_updated_at = %s "
                                   "WHERE signup_id = %s")),
                          ('signup_deleted', deleted_at, signup_id))
        # Copy signup into campaign_activity_log table.
        self.db.query_str(''.join(("INSERT IGNORE INTO ",
                                   self.campaign_activity_log_table,
                                   " SELECT * FROM ",
                                   self.campaign_activity_table,
                                   " WHERE signup_id = %s AND "
                                   "signup_updated_at = %s")),
                          (signup_id, deleted_at))
        # Delete signup from campaign_activity table.
        self.db.query_str(''.join(("DELETE FROM ",
                                   self.campaign_activity_table,
                                   " WHERE status = %s AND "
                                   "signup_id = %s AND "
                                   "signup_updated_at = %s")),
                          ('signup_deleted', signup_id, deleted_at))
        print("Signup {} deleted and archived.".format(signup_id))

    def _add_post(self, post_data):
        self.db.query_str(''.join(("REPLACE INTO ",
                                   self.campaign_activity_table,
                                   " SET northstar_id = %s, "
                                   "signup_id = %s, campaign_id = %s, "
                                   "campaign_run_id = %s, quantity = %s, "
                                   "why_participated = %s,"
                                   "signup_source = %s, "
                                   "signup_created_at = %s, "
                                   "signup_updated_at = %s, "
                                   "post_id = %s, url = %s, caption = %s, "
                                   "status = %s, remote_addr = %s, "
                                   "post_source = %s, "
                                   "submission_created_at = %s, "
                                   "submission_updated_at = %s, "
                                   "action = %s, post_type = %s")),
                          (post_data['northstar_id'],
                           post_data['signup_id'],
                           post_data['campaign_id'],
                           post_data['campaign_run_id'],
                           post_data['quantity'],
                           post_data['why_participated'],
                           post_data['signup_source'],
                           post_data['signup_created_at'],
                           post_data['signup_updated_at'],
                           post_data['id'],
                           post_data['media']['url'],
                           post_data['media']['caption'],
                           post_data['status'],
                           post_data['remote_addr'],
                           post_data['source'],
                           post_data['created_at'],
                           post_data['updated_at'],
                           post_data['action'],
                           post_data['type']))
        print("Post {} ETL'd.".format(post_data['id']))

    def _add_post_details(self, post_id, post_details):
        # TODO: Remove type check if Rogue sends this as JSON/dict.
        if type(post_details) is str:
            details = json.loads(post_details)
        self.db.query_str(''.join(("REPLACE INTO ",
                                   self.campaign_activity_details,
                                   " SET post_id = %s, hostname = %s, "
                                   "referral_code = %s, "
                                   "partner_comms_opt_in = %s, "
                                   "created_at = %s, updated_at = %s, "
                                   "voter_registration_status = %s, "
                                   "voter_registration_source = %s, "
                                   "voter_registration_method = %s, "
                                   "voting_method_preference = %s, "
                                   "email_subscribed = %s, "
                                   "sms_subscribed = %s")),
                          (post_id,
                           details['hostname'],
                           details['referral-code'],
                           details['partner-comms-opt-in'],
                           details['created-at'],
                           details['updated-at'],
                           details['voter-registration-status'],
                           details['voter-registration-source'],
                           details['voter-registration-method'],
                           details['voting-method-preference'],
                           details['email subscribed'],
                           details['sms subscribed']))
        print("Details for post {} ETL'd.".format(post_id))

    def _delete_post(self, post_id, deleted_at):
        # Set post status to 'deleted'.
        self.db.query_str(''.join(("UPDATE ",
                                   self.campaign_activity_table,
                                   " SET status = %s, "
                                   "submission_updated_at = %s, "
                                   "signup_updated_at = %s "
                                   "WHERE post_id = %s")),
                          ('deleted', deleted_at, deleted_at, post_id))
        # Copy post into campaign_activity_log table.
        self.db.query_str(''.join(("INSERT IGNORE INTO ",
                                   self.campaign_activity_log_table,
                                   " SELECT * FROM ",
                                   self.campaign_activity_table,
                                   " WHERE post_id = %s AND "
                                   "submission_updated_at = %s")),
                          (post_id, deleted_at))
        # Delete record from campaign_activity table.
        self.db.query_str(''.join(("DELETE FROM ",
                                   self.campaign_activity_table,
                                   " WHERE status = %s AND "
                                   "post_id = %s AND "
                                   "signup_updated_at = %s")),
                          ('deleted', post_id, deleted_at))
        print("Post {} deleted and archived.".format(post_id))

    def process_message(self, message_data):
        data = message_data['data']
        if data['meta']['type'] == 'signup':
            if not pydash.get(data, 'deleted_at'):
                self._add_signup(data)
            else:
                self._delete_signup(data['id'], data['deleted_at'])
        elif data['meta']['type'] == 'post':
            if not pydash.get(data, 'deleted_at'):
                self._add_post(data)
                if data['details'] is not None:
                    self._add_post_details(data['id'], data['details'])
            else:
                self._delete_post(data['id'], data['deleted_at'])
        else:
            print("Unknown rogue message type. Exiting.")
            sys.exit(1)
