from oauthlib.oauth2 import BackendApplicationClient
import os
from requests_oauthlib import OAuth2Session
from .scraper import Scraper


class DSOAuthScraper(Scraper):

    def __init__(self, url):
        Scraper.__init__(self, url)
        self.auth_headers = self.fetch_auth_headers()

    def fetch_auth_headers(self):
        oauth = OAuth2Session(client=BackendApplicationClient(
            client_id=os.getenv('NS_CLIENT_ID')))
        scopes = ['admin', 'user']
        new_token = oauth.fetch_token(os.getenv('NS_URI') + '/v2/auth/token',
                                      client_id=os.getenv('NS_CLIENT_ID'),
                                      client_secret=os.getenv('NS_CLIENT_SECRET'),
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
