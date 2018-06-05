import boto3
import pydash

dms = boto3.client('dms')


def start_dms_refresh(aws_arn):
    # Refresh DMS with full reload by passing in arn, including 'arn:' part.
    dms.start_replication_task(ReplicationTaskArn=aws_arn,
                               StartReplicationTaskType='reload-target')


def check_refresh_status(aws_arn):
    # Report back metrics for DMS progress.
    task_progess = dms.describe_replication_tasks(Filters=[
        {'Name': 'replication-task-arn',
         'Values': [aws_arn]}])
    refresh_status = {}
    refresh_status['status'] = pydash.get(task_progess,
                                          'ReplicationTasks.0.Status')
    refresh_status['reason'] = pydash.get(task_progess,
                                          'ReplicationTasks.0.StopReason')
    refresh_status['progress'] = pydash.get(task_progess,
                                            'ReplicationTasks.0.ReplicationTaskStats.FullLoadProgressPercent')
    if (status['status'] == 'stopped' and
        status['reason'] == 'Stop Reason FULL_LOAD_ONLY_FINISHED' and
        status['progress'] == 100):
        return True
    else:
        return False

def refresh_finished(aws_arn):
    # Return true only when refresh is finished.
    status = check_refresh_status()
    while not check_refresh_status(aws_arn):
        # SLeep between checks for 60 seconds, then try again.
        print("DMS refresh still not done, checking in 60.")
        time.sleep(60)
        status = check_refresh_status()
    print("DMS finished!")
    return None
