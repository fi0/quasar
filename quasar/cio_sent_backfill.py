import os
import requests
from requests.auth import HTTPBasicAuth

from .utils import log, logerr


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


def main():
	page = get_page()
	for id in page['messages']:
		log('Message ID is {}.'.format(id['id']))
	log('The next page ID is {}.'.format(page['next']))
