import boto3
import pydash
import time
from .utils import log
from .puck_events import main as puck_refresh

dms = boto3.client('dms', region_name='us-east-1')


def start_puck_import():
    """Refresh Puck events to Quasar Prod."""
    dms.start_replication_task(ReplicationTaskArn='arn:aws:dms:us-east-1:389428637636:task:3QEAICCW7MTVODXBHJZ2DMIZOM',
                               StartReplicationTaskType='reload-target')


def check_refresh_status():
    """Report back metrics for DMS progress."""
    task_progess = dms.describe_replication_tasks(Filters=[
        {'Name': 'replication-task-arn',
         'Values': ['arn:aws:dms:us-east-1:389428637636:task:3QEAICCW7MTVODXBHJZ2DMIZOM']}])
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

    # Kick off Puck DB refresh
    log("Starting Puck DMS refresh.")
    start_puck_import()
    # Give job 10 seconds to start on AWS as a safety measure.
    time.sleep(10)

    status = check_refresh_status()
    while not (status['status'] == 'stopped' and
               status['reason'] == 'Stop Reason FULL_LOAD_ONLY_FINISHED' and
               status['progress'] == 100):
        # SLeep between checks for 60 seconds, then try again.
        log("Puck DMS refresh still not done, waiting.")
        time.sleep(60)
        status = check_refresh_status()

    puck_refresh()

    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    log("duration: {}".format(duration))


if __name__ == "__main__":
    main()