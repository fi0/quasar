import os
import requests
from requests.auth import HTTPBasicAuth
from sqlalchemy import create_engine
from sqlalchemy.engine.url import URL
from sqlalchemy.sql import text

from .utils import log, logerr

pg_vars = {
    'drivername': os.getenv('PG_DRIVER'),
    'username': os.getenv('PG_USER'),
    'password': os.getenv('PG_PASSWORD'),
    'host': os.getenv('PG_HOST'),
    'port': os.getenv('PG_PORT'),
    'database': os.getenv('PG_DATABASE')
}

pg_ssl = os.getenv('PG_SSL')

# Setup SQL Alchemy postgres connection.
engine = create_engine(URL(**pg_vars),
                       connect_args={'sslmode': pg_ssl})
connection = engine.connect()

# Grab a page from C.io messages API with optional next param for pagination.
def get_page(next_page=None):
    params = {'metric': os.getenv('CIO_API_METRIC'),
              'type': os.getenv('CIO_API_TYPE'),
              'limit': os.getenv('CIO_API_LIMIT'),
              'next': next_page}
    user = os.getenv('CIO_API_USER')
    password = os.getenv('CIO_API_PASSWORD')
    uri = os.getenv('CIO_API_URI')
    r = requests.get(uri, params=params, auth=(user, password))
    return r.json()


# Insert record atomically. 
def insert_record(message):
	query = text(''.join(("INSERT INTO cio.email_sent(email_id, customer_id, "
		                  "email_address, template_id, subject, timestamp)"
		                  "VALUES (:email_id, :customer_id, :email_address,"
		                  ":template_id, :subject, to_timestamp(:timestamp))"
		                  "ON CONFLICT (email_id, customer_id, timestamp) "
		                  "DO NOTHING")))
	record = {
	    'email_id': message['id'],
	    'customer_id': message['customer_id'],
	    'email_address': message['recipient'],
	    'template_id': message['msg_template_id'],
	    'subject': message['subject'],
	    'timestamp': message['metrics']['sent']
	}
	connection.execute(query, **record)


def main():
	page = get_page()
	for id in page['messages']:
		insert_record(id)
		log('Message ID is {}.'.format(id['id']))
	log('The next page ID is {}.'.format(page['next']))
