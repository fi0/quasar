import json
import pydash
import os
import sys

from .database import Database
from .queue import QuasarQueue
from .utils import unixtime_to_isotime as u2i
from .utils import strip_str


class RouteQueue(QuasarQueue):

    def __init__(self):
        self.amqp_uri = os.environ.get('AMQP_URI')
        self.blink_queue = os.environ.get('BLINK_QUEUE')
        self.blink_exchange = os.environ.get('BLINK_EXCHANGE')
        super().__init__(self.amqp_uri, self.blink_queue,
                         self.blink_exchange)
        self.rogue_queue = RogueQueue()
        self.cio_queue = CioQueue()
        self.db = Database()

    def process_message(self, message_data):
        if pydash.get(message_data, 'data.meta.message_source') == 'rogue':
            print("Routing message to Rogue queue.")
            self.rogue_queue.pub_message(message_data)
        else:
            print(''.join(("Publishing C.IO event id:"
                           "{} to c.io Postgres queue."
                           "")).format(message_data['data']['event_id']))
            self.cio_queue.pub_message(message_data)


class CioQueue(QuasarQueue):

    def __init__(self):
        self.amqp_uri = os.environ.get('AMQP_URI')
        self.cio_queue = os.environ.get('CIO_QUEUE')
        self.quasar_exchange = os.environ.get('QUASAR_EXCHANGE')
        super().__init__(self.amqp_uri, self.cio_queue,
                         self.quasar_exchange)
        self.db = Database()

    # Save entire c.io JSON blob to event_log table.
    def _log_event(self, data):
        self.db.query_str(''.join(("INSERT INTO cio.event_log "
                                   "(event) VALUES (%s)")),
                          (json.dumps(data),))
        print(''.join(("Logged data from "
                       "C.IO event id {}.")).format(data['event_id']))

    # Save customer sub data and dates.
    def _add_sub_event(self, data):
        self.db.query_str(''.join(("INSERT INTO cio.customer_event "
                                   "(email_id, customer_id, email_address, "
                                   "event_id, timestamp, "
                                   "event_type) VALUES (%s,%s,%s,%s,"
                                   "to_timestamp(%s),%s) "
                                   "ON CONFLICT (email_id, customer_id, "
                                   "timestamp, event_type) "
                                   "DO NOTHING")),
                          (data['data']['email_id'],
                           data['data']['customer_id'],
                           data['data']['email_address'],
                           data['event_id'], data['timestamp'],
                           data['event_type']))
        print(''.join(("Added customer event from "
                       "C.IO event id {}.")).format(data['event_id']))

    # Save customer unsub data and dates.
    def _add_unsub_event(self, data):
        if pydash.get(data, 'template_id'):
            self.db.query_str(''.join(("INSERT INTO cio.customer_event "
                                       "(email_id, customer_id,"
                                       "email_address, template_id, event_id,"
                                       "timestamp, event_type) "
                                       "VALUES (%s,%s,%s,%s,%s,"
                                       "to_timestamp(%s),%s) "
                                       "ON CONFLICT (email_id, customer_id, "
                                       "timestamp, event_type) "
                                       "DO NOTHING")),
                              (data['data']['email_id'],
                               data['data']['customer_id'],
                               data['data']['email_address'],
                               data['data']['template_id'],
                               data['event_id'], data['timestamp'],
                               data['event_type']))
        else:
            self.db.query_str(''.join(("INSERT INTO cio.customer_event "
                                       "(email_id, customer_id,"
                                       "email_address, event_id, "
                                       "timestamp, event_type) "
                                       "VALUES (%s,%s,%s,%s,"
                                       "to_timestamp(%s),%s) "
                                       "ON CONFLICT (email_id, customer_id, "
                                       "timestamp, event_type) "
                                       "DO NOTHING")),
                              (data['data']['email_id'],
                               data['data']['customer_id'],
                               data['data']['email_address'],
                               data['event_id'], data['timestamp'],
                               data['event_type']))
        print(''.join(("Added customer event from "
                       "C.IO event id {}.")).format(data['event_id']))

    # Save email event data and dates, e.g. email_click.
    def _add_email_event(self, data):
        self.db.query_str(''.join(("INSERT INTO cio.email_event "
                                   "(email_id, customer_id, email_address, "
                                   "template_id, event_id, timestamp, "
                                   "event_type) VALUES "
                                   "(%s,%s,%s,%s,%s,to_timestamp(%s),%s) "
                                   "ON CONFLICT (email_id, customer_id, "
                                   "timestamp, event_type) "
                                   "DO NOTHING")),
                          (data['data']['email_id'],
                           data['data']['customer_id'],
                           data['data']['email_address'],
                           data['data']['template_id'],
                           data['event_id'], data['timestamp'],
                           data['event_type']))
        print(''.join(("Added email event from "
                       "C.IO event id {}.")).format(data['event_id']))

    # Save email event data and dates, e.g. email_click.
    def _add_email_click_event(self, data):
        self.db.query_str(''.join(("INSERT INTO cio.email_event "
                                   "(email_id, customer_id, email_address, "
                                   "template_id, subject, href, link_id, "
                                   "event_id, timestamp, "
                                   "event_type) VALUES "
                                   "(%s,%s,%s,%s,%s,%s,%s,%s,"
                                   "to_timestamp(%s),%s) "
                                   "ON CONFLICT (email_id, customer_id, "
                                   "timestamp, event_type) "
                                   "DO NOTHING")),
                          (data['data']['email_id'],
                           data['data']['customer_id'],
                           data['data']['email_address'],
                           data['data']['template_id'],
                           data['data']['subject'],
                           data['data']['href'],
                           data['data']['link_id'],
                           data['event_id'], data['timestamp'],
                           data['event_type']))
        print(''.join(("Added email event from "
                       "C.IO event id {}.")).format(data['event_id']))

    def process_message(self, message_data):
        data = message_data['data']
        event_type = pydash.get(data, 'event_type')
        # Set for checking email event types.
        email_event = {
            'email_converted',
            'email_opened',
            'email_unsubscribed'
        }
        # Always capture atomic c.io event in raw format.
        self._log_event(data)
        if event_type == 'customer_subscribed':
            self._add_sub_event(data)
        elif event_type == 'customer_unsubscribed':
            self._add_unsub_event(data)
        elif event_type == 'email_clicked':
            self._add_email_click_event(data)
        elif event_type in email_event:
            self._add_email_event(data)
        else:
            print("Something went wrong with C.IO consumer!")
            sys.exit(1)


class RogueQueue(QuasarQueue):

    def __init__(self):
        self.amqp_uri = os.environ.get('AMQP_URI')
        self.rogue_queue = os.environ.get('ROGUE_QUEUE')
        self.quasar_exchange = os.environ.get('QUASAR_EXCHANGE')
        super().__init__(self.amqp_uri, self.rogue_queue,
                         self.quasar_exchange)
        self.db = Database()

    def _add_signup(self, signup_data):
        self.db.query_str(''.join(("INSERT INTO rogue.signups "
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
                           signup_data['updated_at']))
        print("Signup {} ETL'd.".format(signup_data['signup_id']))

    def _delete_signup(self, signup_id, deleted_at):
        self.db.query_str(''.join(("INSERT INTO rogue.signups "
                                   "(id, updated_at, "
                                   "deleted_at) VALUES "
                                   "(%s,%s,%s) ON CONFLICT "
                                   "(id,  updated_at) DO UPDATE "
                                   "SET deleted_at = %s")),
                          (signup_id, deleted_at, deleted_at,
                           deleted_at))
        print("Signup {} deleted and archived.".format(signup_id))

    def _add_post(self, post_data):
        self.db.query_str(''.join(("INSERT INTO rogue.posts "
                                   "(id, signup_id, campaign_id, "
                                   "northstar_id, "
                                   "type, action, quantity, url, caption, "
                                   "status, source, "
                                   "source_details, signup_source, "
                                   "remote_addr, created_at, "
                                   "updated_at) VALUES "
                                   "(%s,%s,%s,%s,%s,%s,%s,%s,%s,"
                                   "%s,%s,%s,%s,%s,%s,%s) ON CONFLICT "
                                   "DO NOTHING")),
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
                           post_data['updated_at']))
        print("Post {} ETL'd.".format(post_data['id']))

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
            print("Turbovote details for post {} ETL'd.".format(post_id))
        else:
            self.db.query_str(''.join(("INSERT INTO rogue.post_details "
                                       "(data) VALUES (%s)")),
                              (post_details,))
            print("Details for post {} ETL'd.".format(post_id))

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
            print("Unknown rogue message type. Exiting.")
            sys.exit(1)
