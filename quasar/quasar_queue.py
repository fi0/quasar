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

    def process_message(self, message_data):
        data = message_data['data']
        if data['meta']['type'] == 'signup':
            self.db.query_str("REPLACE INTO " +
                              self.campaign_activity_table +
                              " SET northstar_id = %s,\
                                   signup_id = %s,\
                                   campaign_id = %s,\
                                   campaign_run_id = %s,\
                                   quantity = %s,\
                                   why_participated = %s,\
                                   signup_source = %s,\
                                   signup_details = %s,\
                                   signup_created_at = %s,\
                                   signup_updated_at = %s,\
                                   post_id = -1,\
                                   url = NULL,\
                                   caption = NULL,\
                                   status = NULL,\
                                   remote_addr = NULL,\
                                   post_source = NULL,\
                                   submission_created_at = ''",
                              (strip_str(data['northstar_id']),
                               strip_str(data['signup_id']),
                               strip_str(data['campaign_id']),
                               strip_str(data['campaign_run_id']),
                               strip_str(data['quantity']),
                               strip_str(data['why_participated']),
                               strip_str(data['signup_source']),
                               strip_str(data['details']),
                               strip_str(data['created_at']),
                               strip_str(data['updated_at'])))
            print("Signup {} ETL'd.".format(data['signup_id']))
        elif data['meta']['type'] == 'post':
            if not pydash.get(data, 'deleted_at'):
                self.db.query_str("REPLACE INTO " +
                                  self.campaign_activity_table +
                                  " SET northstar_id = %s,\
                                       signup_id = %s,\
                                       campaign_id = %s,\
                                       campaign_run_id = %s,\
                                       quantity = %s,\
                                       why_participated = %s,\
                                       signup_source = %s,\
                                       signup_created_at = %s,\
                                       signup_updated_at = %s,\
                                       post_id = %s,\
                                       url = %s,\
                                       caption = %s,\
                                       status = %s,\
                                       remote_addr = %s,\
                                       post_source = %s,\
                                       submission_created_at = %s,\
                                       submission_updated_at = %s,\
                                       action = %s,\
                                       post_type = %s",
                                  (strip_str(data['northstar_id']),
                                   strip_str(data['signup_id']),
                                   strip_str(data['campaign_id']),
                                   strip_str(data['campaign_run_id']),
                                   strip_str(data['quantity']),
                                   strip_str(data['why_participated']),
                                   strip_str(data['signup_source']),
                                   strip_str(data['signup_created_at']),
                                   strip_str(data['signup_updated_at']),
                                   strip_str(data['id']),
                                   data['media']['url'],
                                   strip_str(data['media']['caption']),
                                   strip_str(data['status']),
                                   strip_str(data['remote_addr']),
                                   strip_str(data['source']),
                                   strip_str(data['created_at']),
                                   strip_str(data['updated_at']),
                                   strip_str(data['action']),
                                   strip_str(data['type'])))
                if data['details'] is not None:
                    details = json.loads(data['details'])
                    self.db.query_str("REPLACE INTO " +
                                      self.campaign_activity_details +
                                      " SET post_id = %s,\
                                           hostname = %s,\
                                           referral_code = %s,\
                                           partner_comms_opt_in = %s,\
                                           created_at = %s,\
                                           updated_at = %s,\
                                           voter_registration_status = %s,\
                                           voter_registration_source = %s,\
                                           voter_registration_method = %s,\
                                           voting_method_preference = %s,\
                                           email_subscribed = %s,\
                                           sms_subscribed = %s",
                                      (data['id'],
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
                print("Post {} ETL'd.".format(data['id']))
            else:
                self.db.query_str("REPLACE INTO " +
                                  self.campaign_activity_table +
                                  " SET status = %s,\
                                       submission_updated_at = %s,\
                                       WHERE post_id = %s",
                                  ('deleted',
                                   strip_str(data['deleted_at']),
                                   data['id']))
                self.db.query_str("INSERT IGNORE INTO " +
                                  self.campaign_activity_log_table +
                                  " * FROM " +
                                  self.campaign_activity_table +
                                  " WHERE post_id = %s AND" +
                                  " submission_updated_at = %s",
                                  (data['id'],
                                   strip_str(data['deleted_at'])))
                self.db.query_str("DELETE FROM " +
                                  self.campaign_activity_table +
                                  " WHERE status = %s AND" +
                                  " post_id = %s AND" +
                                  " submission_updated_at = %s",
                                  ('deleted',
                                   data['id'],
                                   strip_str(data['deleted_at'])))
                print("Post {} deleted and archived.".format(data['id']))
        else:
            print("Unknown rogue message type. Exiting.")
            sys.exit(1)

