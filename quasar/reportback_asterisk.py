import os
import pandas as pd
import sqlalchemy as sal

from .etl_monitoring import DataFrameDB


class LoadReportback:
    def __init__(self):
        db_opts = {}
        self.db = DataFrameDB(db_opts)
        self.csv_path = os.environ.get('RB_CSV_PATH')

    def read_csv(self, path):
        df = pd.read_csv(path)
        return df

    def load_csv(self, df):
        df.to_sql(
            name='legacy_reportbacks',
            con=self.db.engine,
            schema='playpen',
            if_exists='replace',
            index=False,
            dtype={'date': sal.types.DATE(),
                   'rbs': sal.types.INTEGER(),
                   'calls': sal.types.INTEGER(),
                   'social': sal.types.INTEGER(),
                   'voter_registrations': sal.types.INTEGER(),
                   'other': sal.types.INTEGER(),
                   'campaign_run_id': sal.types.INTEGER(),
                   'campaign': sal.types.NVARCHAR(length=64)
                   }
        )

    def read_load(self):
        df = self.read_csv(self.csv_path)
        self.load_csv(df)


def run_load_reportbacks():
    rb = LoadReportback()
    rb.read_load()
