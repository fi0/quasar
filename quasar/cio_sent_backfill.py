from concurrent.futures import ThreadPoolExecutor as PoolExecutor
import os
import requests
from requests.auth import HTTPBasicAuth
from sqlalchemy import create_engine
from sqlalchemy.engine.url import URL
from sqlalchemy.sql import select
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
conn = engine.connect()

# Grab a page from C.io messages API with optional next param for pagination.
def get_page(next_page=None):
    params = {'metric': os.getenv('CIO_API_METRIC'),
              'type': os.getenv('CIO_API_TYPE'),
              'limit': os.getenv('CIO_API_LIMIT'),
              'start': next_page}
    user = os.getenv('CIO_API_USER')
    password = os.getenv('CIO_API_PASSWORD')
    uri = os.getenv('CIO_API_URI')
    r = requests.get(uri, params=params, auth=(user, password))
    return r.json()


# Insert C.io email_sent record atomically. 
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
	conn.execute(query, **record)
	log('Message ID {} processed.'.format(message['id']))


# Get next page location.
def get_bookmark():
	s = "SELECT * FROM cio.sent_backfill_track"
	result = conn.execute(s)
	return result.fetchall()


# Keep track of next page location.
def insert_bookmark(next_page):
	query = text(''.join(("INSERT INTO cio.sent_backfill_track(next_page) "
		                  "VALUES (:next_page)")))
	conn.execute("TRUNCATE cio.sent_backfill_track")
	conn.execute(query, next_page=next_page)


def main():
	# Check if this is start of the run. If not, resume from last page.
	if get_bookmark() is None:
		page = get_page()
	else:
		page = get_page(next_page=get_bookmark())
		insert_bookmark(page['next'])
	# While there is a page of results, continue processing.
	while page:
		with PoolExecutor(max_workers=int(os.getenv('POOL_SIZE'))) as executor:
			for _ in executor.map(insert_record, page['messages']):
				pass
		page = get_page(next_page=get_bookmark())
		insert_bookmark(page['next'])
