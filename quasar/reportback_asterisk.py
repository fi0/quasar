import pandas as pd

from .etl_monitoring import DataFrameDB


class LoadReportback:
    def __init__(self):
        db_opts = {}
        self.db = DataFrameDB(db_opts)

    def read_csv(self):
        df = pd.read_csv("quasar/misc/reportbacks_asterisk.csv")
        return df

    def load_csv(self, df):
        df.to_sql(
            name='legacy_reportbacks',
            con=self.db.engine,
            schema='playpen',
            if_exists='replace',
            index=False
        )

    def read_load(self):
        df = self.read_csv()
        self.load_csv(df)


def run_load_reportbacks():
    rb = LoadReportback()
    rb.read_load()
