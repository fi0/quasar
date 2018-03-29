import json
from .config import config
import oauthlib
from oauthlib.oauth2 import BackendApplicationClient
from requests_oauthlib import OAuth2Session
from .scraper import Scraper


class NorthstarScraper(Scraper):

    def __init__(self, url):
        Scraper.__init__(self, url, params={
                         'limit': 100, 'pagination': 'cursor'})
        self.auth_headers = self.fetch_auth_headers()

    def fetch_auth_headers(self):
        oauth = OAuth2Session(client=BackendApplicationClient(
            client_id=config.ns_client_id))
        scopes = ['admin', 'user']
        new_token = oauth.fetch_token(self.url + '/v2/auth/token',
                                      client_id=config.ns_client_id,
                                      client_secret=config.ns_client_secret,
                                      scope=scopes)
        return {'Authorization': 'Bearer ' + str(new_token['access_token'])}

    def authenticated(func):
        def _authenticated(self, *args, **kwargs):
            response = func(self, *args, **kwargs)
            if response.status_code == 401:
                self.auth_headers = self.fetch_auth_headers()
                response = func(self, *args, **kwargs)
            return response
        return _authenticated

    @authenticated
    def get(self, path, query_params=''):
        return super().get(path, headers=self.auth_headers,
                           params=query_params)

    def process_all_pages(self, path, params, process_fn):
        i = 1
        if 'page' in params:
            i = params['page']

        _next = True
        while _next is True:
            params['page'] = i
            response = self.get(path, params).json()
            process_fn(i, response)
            i += 1
            if response['meta']['cursor']['next'] is None:
                _next = False
