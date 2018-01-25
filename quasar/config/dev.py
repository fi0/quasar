# Quasar DB
# [18/571]
host = "127.0.0.1"
port = 6603
user = "root"
pw = "password"

# Mobile Commons API
mc_user = 'test@example.org'
mc_pw = 'password'

# Northstar OAuth2 Credentials:
ns_client_id = 'some-client'
ns_client_secret = 'password'
ns_uri = 'https://northstar-thor.dosomething.org'
ns_counter_table = 'quasar_etl_status.thor_northstar_ingestion'

# New Quasar Per Var Settings
AMQP_URI = 'amqps://user:something@server-thing.cloudamqp.com/asdf'
AMQP_QUEUE = 'quasar-customer-io-email-activity'
AMQP_EXCHANGE = 'blink-x'
MYSQL_HOST = '127.0.0.1'
MYSQL_PORT = '6603'
MYSQL_USER = 'root'
MYSQL_PASSWORD = 'password'
MYSQL_SSL = {}
MYSQL_DATABASE = 'quasar'
MYSQL_TABLE = 'users'
BLINK_BACKUP_TABLE = 'blink_queue_backlog'

# Rogue Env Vars
DS_ROGUE_API_KEY = 'someapikey'
CAMPAIGN_ACTIVITY_TABLE = 'campaign_activity'
ROGUE_URI = 'https://rogue.dosomething.org'
ROGUE_PROGRESS_TABLE = 'quasar_etl_status.rogue_ingestion'

# ETL Monitoring Vars
ETLMON_SLACKBOT_TOKEN = 'SLACKBOT_TOKEN'

# Rb CSV Path
RB_CSV_PATH = 'PATH'
