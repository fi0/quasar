from oauthlib.oauth2 import BackendApplicationClient
import os
from requests_oauthlib import OAuth2Session
from .scraper import Scraper


class NorthstarScraper(Scraper):

    def __init__(self, url):
        Scraper.__init__(self, url, params={
                         'limit': 100, 'pagination': 'cursor',
                         'include': ''.join(("last_name,email,mobile,"
                                             "birthdate,addr_street1,"
                                             "addr_street2,age,school_id"))})
        self.auth_headers = self.fetch_auth_headers()

    def fetch_auth_headers(self):
        oauth = OAuth2Session(client=BackendApplicationClient(
            client_id=os.environ.get('NS_CLIENT_ID')))
        scopes = ['admin', 'user']
        ns_client_id = os.environ.get('NS_CLIENT_ID')
        ns_client_secret = os.environ.get('NS_CLIENT_SECRET')
        new_token = oauth.fetch_token(self.url + '/v2/auth/token',
                                      client_id=ns_client_id,
                                      client_secret=ns_client_secret,
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
