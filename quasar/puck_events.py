from .database_pg import Database
import boto3
import pydash
import time

dms = boto3.resource('dms')

def start_puck_refresh():
    dms.start_replication_task(ReplicationTaskArn='arn:aws:dms:us-east-1:389428637636:task:JAWXM5VSC7MIQYD3RMBJKZ2PKI',
                               StartReplicationTaskType='reload-target')

def check_refresh_status():
    task_progess = dms.describe_replication_tasks(Filters=[
        {'Name': 'replication-task-arn', 
         'Values': ['arn:aws:dms:us-east-1:389428637636:task:JAWXM5VSC7MIQYD3RMBJKZ2PKI']}])
    refresh_status['status'] = pydash.get(status, 'ReplicationTasks.0.Status')
    refresh_status['reason'] = pydash.get(status, 'ReplicationTasks.0.StopReason')
    refresh_status['progress'] = pydash.get(status, 'ReplicationTasks.0.ReplicationTaskStats.FullLoadProgressPercent')
    return refresh_status

def main():
    start_time = time.time()
    """Keep track of start time of script."""

    # Kick off Puck DB refresh
    start_puck_refresh()
    # Give job 10 seconds to start on AWS as a safety measure.
    time.sleep(10)

    status = check_refresh_status()
    while not (status['status'] == 'stopped' and
                  status['reason'] == 'Stop Reason FULL_LOAD_ONLY_FINISHED' and
                  status['progress'] == 100):
        # SLeep between checks for 60 seconds, then try again.
        time.sleep(60)
        status = check_refresh_status()

    db = Database()

    db.query('REFRESH MATERIALIZED VIEW puck.events_json')
    db.query('REFRESH MATERIALIZED VIEW public.path_campaign_lookup')
    db.query('REFRESH MATERIALIZED VIEW public.phoenix_events')
    db.query('REFRESH MATERIALIZED VIEW public.phoenix_sessions')
    db.query('REFRESH MATERIALIZED VIEW public.device_northstar_crosswalk')
    db.disconnect()

    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    print('duration: ', duration)


if __name__ == "__main__":
    main()
