import json
import os
import pydash
import sys

from .database import Database
from .queue import QuasarQueue
from .utils import log, logerr


class RogueQueue(QuasarQueue):

    def __init__(self):
        self.amqp_uri = os.environ.get('AMQP_URI')
        self.rogue_queue = os.environ.get('ROGUE_QUEUE')
        self.quasar_exchange = os.environ.get('QUASAR_EXCHANGE')
        super().__init__(self.amqp_uri, self.rogue_queue,
                         self.quasar_exchange)
        self.db = Database()

    def _add_signup(self, signup_data):
        self.db.query_str_rogue(''.join(("INSERT INTO rogue.signups "
                                         "(id, northstar_id, campaign_id, "
                                         "campaign_run_id, quantity, "
                                         "why_participated, source, "
                                         "source_details, details, "
                                         "created_at, updated_at) "
                                         "VALUES (%s,%s,%s,%s,%s,%s,"
                                         "%s,%s,%s,%s,%s) ON CONFLICT "
                                         "(id, updated_at) "
                                         "DO NOTHING")),
                                (signup_data['signup_id'],
                                 signup_data['northstar_id'],
                                 signup_data['campaign_id'],
                                 signup_data['campaign_run_id'],
                                 signup_data['quantity'],
                                 signup_data['why_participated'],
                                 signup_data['signup_source'],
                                 signup_data['source_details'],
                                 signup_data['details'],
                                 signup_data['created_at'],
                                 signup_data['updated_at']),
                                signup_data, signup_data['signup_id'])
        log(''.join(("Signup {} ETL'd."
                     "")).format(signup_data['signup_id']))

    def _delete_signup(self, signup_id, deleted_at):
        self.db.query_str(''.join(("INSERT INTO rogue.signups "
                                   "(id, updated_at, "
                                   "deleted_at) VALUES "
                                   "(%s,%s,%s) ON CONFLICT "
                                   "(id,  updated_at) DO UPDATE "
                                   "SET deleted_at = %s")),
                          (signup_id, deleted_at, deleted_at,
                           deleted_at))
        log("Signup {} deleted and archived.".format(signup_id))

    def _add_post(self, post_data):
        self.db.query_str_rogue(''.join(("INSERT INTO rogue.posts "
                                         "(id, signup_id, campaign_id, "
                                         "northstar_id, "
                                         "type, action, quantity, url, "
                                         "caption, status, source, "
                                         "source_details, signup_source, "
                                         "remote_addr, created_at, "
                                         "updated_at) VALUES "
                                         "(%s,%s,%s,%s,%s,%s,%s,%s,"
                                         "%s,%s,%s,%s,%s,%s,%s,%s) "
                                         "ON CONFLICT DO NOTHING")),
                                (post_data['id'],
                                 post_data['signup_id'],
                                 post_data['campaign_id'],
                                 post_data['northstar_id'],
                                 post_data['type'],
                                 post_data['action'],
                                 post_data['quantity'],
                                 post_data['media']['url'],
                                 post_data['media']['caption'],
                                 post_data['status'],
                                 post_data['source'],
                                 post_data['source_details'],
                                 post_data['signup_source'],
                                 post_data['remote_addr'],
                                 post_data['created_at'],
                                 post_data['updated_at']),
                                post_data, post_data['id'])
        log("Post {} ETL'd.".format(post_data['id']))

    def _delete_post(self, post_id, deleted_at):
        # Set post status to 'deleted'.
        self.db.query_str(''.join(("INSERT INTO rogue.posts "
                                   "(id, updated_at, "
                                   "status, deleted_at) VALUES "
                                   "(%s,%s,%s,%s) ON CONFLICT "
                                   "(id, updated_at) "
                                   "DO UPDATE SET "
                                   "deleted_at = %s, status = %s")),
                          (post_id, deleted_at, 'deleted',
                           deleted_at, deleted_at, 'deleted'))

    def _add_post_details(self, post_id, post_details):
        # TODO: Remove type check if Rogue sends this as JSON/dict.
        if type(post_details) is str:
            details = json.loads(post_details)
        else:
            details = post_details
        # Check for status key that indicates Turbovote.
        if pydash.get(details, 'voter-registration-status'):
            if pydash.get(details, 'source_details'):
                self.db.query_str(''.join(("INSERT INTO rogue.turbovote "
                                           "(post_id, hostname, "
                                           "referral_code, "
                                           "partner_comms_opt_in, "
                                           "created_at, "
                                           "updated_at, source_details, "
                                           "voter_registration_status, "
                                           "voter_registration_source, "
                                           "voter_registration_method, "
                                           "voter_registration_preference, "
                                           "email_subscribed, sms_subscribed) "
                                           " VALUES (%s,%s,%s,%s,%s,%s,%s,%s,"
                                           "%s,%s,%s,%s,%s) ON CONFLICT "
                                           "DO NOTHING")),
                                  (post_id,
                                   details['hostname'],
                                   details['referral-code'],
                                   details['partner-comms-opt-in'],
                                   details['created-at'],
                                   details['updated-at'],
                                   details['source_details'],
                                   details['voter-registration-status'],
                                   details['voter-registration-source'],
                                   details['voter-registration-method'],
                                   details['voting-method-preference'],
                                   details['email subscribed'],
                                   details['sms subscribed']))
            else:
                self.db.query_str(''.join(("INSERT INTO rogue.turbovote "
                                           "(post_id, hostname, "
                                           "referral_code, "
                                           "partner_comms_opt_in, "
                                           "created_at, updated_at, "
                                           "voter_registration_status, "
                                           "voter_registration_source, "
                                           "voter_registration_method, "
                                           "voter_registration_preference, "
                                           "email_subscribed, sms_subscribed) "
                                           " VALUES (%s,%s,%s,%s,%s,%s,%s,"
                                           "%s,%s,%s,%s,%s) ON CONFLICT "
                                           "DO NOTHING")),
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
            log("Turbovote details for post {} ETL'd.".format(post_id))
        # Check for status key that indicates Rock the Vote.
        elif pydash.get(details, 'Finish with State'):
            self.db.query_str(''.join(("INSERT INTO rogue.rock_the_vote "
                                       "(post_id, "
                                       "tracking_source, "
                                       "started_registration, "
                                       "finish_with_state, "
                                       "status, email, "
                                       "zip) "
                                       "VALUES (%s,%s,%s,%s,%s,%s,%s)")),
                              (post_id,
                               details['Tracking Source'],
                               details['Started registration'],
                               details['Finish with State'],
                               details['Status'],
                               details['Email address'],
                               details['Home zip code']))
            log('Rock the Vote for post {} ETL\'d.'.format(post_id))
        else:
            self.db.query_str(''.join(("INSERT INTO rogue.post_details "
                                       "(data, post_id) VALUES (%s,%s)")),
                              (post_details, post_id))
            log("Details for post {} ETL'd.".format(post_id))

    def process_message(self, message_data):
        data = message_data['data']
        if data['meta']['type'] == 'signup':
            if pydash.get(data, 'deleted_at'):
                self._delete_signup(data['id'], data['deleted_at'])
            else:
                self._add_signup(data)
        elif data['meta']['type'] == 'post':
            if pydash.get(data, 'deleted_at'):
                self._delete_post(data['id'], data['deleted_at'])
            else:
                self._add_post(data)
                if (pydash.get(data, 'details') is None or
                        pydash.get(data, 'details') == ''):
                    pass
                else:
                    self._add_post_details(data['id'], data['details'])
        else:
            logerr("Unknown rogue message type. Exiting.")
            sys.exit(1)
