import boto3
import pydash
import time
from .utils import log

dms = boto3.client('dms', region_name='us-east-1')


def start_dms_refresh(arn):
    """Refresh DMS task from given ARN."""
    dms.start_replication_task(ReplicationTaskArn=arn,
                               StartReplicationTaskType='reload-target')


def check_refresh_status(arn):
    """Report back metrics for DMS progress."""
    task_progess = dms.describe_replication_tasks(Filters=[
        {'Name': 'replication-task-arn',
         'Values': [arn]}])
    refresh_status = {}
    refresh_status['status'] = pydash.get(task_progess,
                                          'ReplicationTasks.0.Status')
    refresh_status['reason'] = pydash.get(task_progess,
                                          'ReplicationTasks.0.StopReason')
    refresh_status['progress'] = pydash.get(task_progess,
                                            'ReplicationTasks.0.ReplicationTaskStats.FullLoadProgressPercent')
    return refresh_status


def refresh_dms(arn, name=None):
    start_time = time.time()
    """Keep track of start time of script."""

    # Kick off DMS refresh
    log("Starting {} DMS refresh.".format(name))
    start_dms_refresh(arn)
    # Give job 10 seconds to start on AWS as a safety measure.
    time.sleep(10)

    status = check_refresh_status(arn)
    while not (status['status'] == 'stopped' and
               status['reason'] == 'Stop Reason FULL_LOAD_ONLY_FINISHED' and
               status['progress'] == 100):
        # SLeep between checks for 60 seconds, then try again.
        log("{} DMS refresh still not done, waiting.".format(name))
        time.sleep(60)
        status = check_refresh_status(arn)

    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    log("duration: {}".format(duration))
    