import boto3
import pydash
import time
from .utils import log
from .gambit import refresh_gambit_full

dms = boto3.client('dms', region_name='us-east-1')


def start_gambit_import():
    """Refresh Gambit events to Quasar Prod."""
    dms.start_replication_task(ReplicationTaskArn='arn:aws:dms:us-east-1:389428637636:task:MUFXOH6A4Z4S2UMOQECGJ5Z6RU',
                               StartReplicationTaskType='reload-target')


def check_refresh_status():
    """Report back metrics for DMS progress."""
    task_progess = dms.describe_replication_tasks(Filters=[
        {'Name': 'replication-task-arn',
         'Values': ['arn:aws:dms:us-east-1:389428637636:task:MUFXOH6A4Z4S2UMOQECGJ5Z6RU']}])
    refresh_status = {}
    refresh_status['status'] = pydash.get(task_progess,
                                          'ReplicationTasks.0.Status')
    refresh_status['reason'] = pydash.get(task_progess,
                                          'ReplicationTasks.0.StopReason')
    refresh_status['progress'] = pydash.get(task_progess,
                                            'ReplicationTasks.0.ReplicationTaskStats.FullLoadProgressPercent')
    return refresh_status


def main():
    start_time = time.time()
    """Keep track of start time of script."""

    # Kick off Gambit DB refresh
    log("Starting Gambit DMS refresh.")
    start_gambit_import()
    # Give job 10 seconds to start on AWS as a safety measure.
    time.sleep(10)

    status = check_refresh_status()
    while not (status['status'] == 'stopped' and
               status['reason'] == 'Stop Reason FULL_LOAD_ONLY_FINISHED' and
               status['progress'] == 100):
        # SLeep between checks for 60 seconds, then try again.
        log("Gambit DMS refresh still not done, waiting.")
        time.sleep(60)
        status = check_refresh_status()

    # Refresh Gambit conversations and messages json and flattened tables.
    refresh_gambit_full()

    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    log("duration: {}".format(duration))


if __name__ == "__main__":
    main()
