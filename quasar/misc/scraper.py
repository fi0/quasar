import requests
from requests.packages.urllib3.util.retry import Retry


class Scraper:
    """ Instantiating a session allows us to re-use the same TCP connection
     for multiple requests to the same host
    """

    def __init__(self, url, retry_total=6, backoff_time=1.9, **defaults):
        self.url = url
        self.session = requests.Session()
        for key in defaults:
            value = getattr(self.session, key)
            if value is None:
                value = defaults[key]
            else:
                value.update(defaults[key])
            setattr(self.session, key, value)

        retries = Retry(total=retry_total, backoff_factor=backoff_time)
        adapter = requests.adapters.HTTPAdapter(max_retries=retries)
        self.session.mount('http://', adapter)
        self.session.mount('https://', adapter)

    def get(self, path, **args):
        response = self.session.get(''.join((self.url, path)), **args)
        print(response.url)
        return response

    def getJson(self, path, **args):
        return self.get(path, **args).json()
