import json

from .config import config
from .database import Database
from .queue import QuasarQueue

db = Database()

class RogueQueue(QuasarQueue):

    def __init__(self):
        super(RogueQueue, self).__init__(config.AMQP_URI, config.ROGUE_QUEUE,
                                         config.QUASAR_EXCHANGE)

    def process_message(self, message_data):
        data = message_data['data']
        if data['posts']['data'] == []:
            db.query_str("REPLACE INTO " +
                         campaign_activity_table +
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
        else:
            for post in data['posts']['data']:
                db.query_str("REPLACE INTO " +
                             campaign_activity_table +
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
                                  post_id = %s,\
                                  url = %s,\
                                  caption = %s,\
                                  status = %s,\
                                  remote_addr = %s,\
                                  post_source = %s,\
                                  submission_created_at = %s,\
                                  submission_updated_at = %s",
                             (strip_str(data['northstar_id']),
                              strip_str(data['signup_id']),
                              strip_str(data['campaign_id']),
                              strip_str(data['campaign_run_id']),
                              strip_str(data['quantity']),
                              strip_str(data['why_participated']),
                              strip_str(data['signup_source']),
                              strip_str(data['details']),
                              strip_str(data['created_at']),
                              strip_str(data['updated_at']),
                              strip_str(post['id']),
                              post['media']['url'],
                              strip_str(post['media']['caption']),
                              strip_str(post['status']),
                              strip_str(post['remote_addr']),
                              strip_str(post['source']),
                              strip_str(post['created_at']),
                              strip_str(post['updated_at'])))
                print("Post {} ETL'd.".format(post['id']))
