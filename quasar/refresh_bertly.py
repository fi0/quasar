import os
import time
from .aws_dms import start_dms_refresh, refresh_finished


def main():
    bertly_dms = os.environ.get('BERTLY_DMS_ARN')
    start_dms_refresh(bertly_dms)
    time.sleep(10)
    refresh_finished(bertly_dms)


if __name__ == "__main__":
    main()
