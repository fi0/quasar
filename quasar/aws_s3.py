import boto3
import os
import collections

s3 = boto3.client('s3')
rds = boto3.client('rds')

# Backup the newest snapshot each day, check to make sure we're not backing it up twice
# Make sure the backup was successful
# Put them in Glacier in 30 days

def list_backups():
    s3_objects = s3.list_objects_v2(Bucket='dosomething-quasar-archive', Delimiter="/")
    folders = []
    for folder in s3_objects['CommonPrefixes']:
        folders.append(folder['Prefix'][:-1])
    return folders

def list_snapshots():
    response = rds.describe_db_snapshots(DBInstanceIdentifier='quasar-prod')
    snapshots = {}
    for res in response['DBSnapshots']:
        snapshots[res['DBSnapshotIdentifier'][4:]] = res['DBSnapshotArn']
    return snapshots


def check_backup_status():
    # Report back metrics for RDS backup progress.
    task_progress = rds.describe_export_tasks(
        Filters=[
            {
                'Name': 's3-bucket',
                'Values': [os.environ.get('EXPORT_S3_BUCKET_NAME')]
            }
        ]
    )
    task_status = collections.OrderedDict()
    task_status['running'] = 0

    for task in task_progress['ExportTasks']:
        task_status[task['ExportTaskIdentifier']] = {"status" : task['Status']}
        if (task['Status'] in ('IN_PROGRESS', 'STARTING')):
            task_status['running'] += 1
        if ('WarningMessage' in task):
            task_status[task['ExportTaskIdentifier']].update({"msg" : task['WarningMessage']})

    return task_status

def start_export_task():
    rds_snapshots = list_snapshots()
    s3_backups = list_backups()
    # Check which of these snapshots is not saved in the s3 bucket
    # Export RDS snapshots to S3.
    to_backup = list(set(rds_snapshots) - set(s3_backups))

    task_status = check_backup_status()

    backup_slots = 5 - task_status['running'] # StartExportTask only allows for 5 concurrent backups
    if backup_slots > 5:
        try:
            i = 0
            if i <= backup_slots:
                for snapshot in to_backup:
                        rds.start_export_task(ExportTaskIdentifier=snapshot, # S3 folder name
                                                   SourceArn=rds_snapshots[snapshot], # RDS Snapshot ARN
                                                   S3BucketName=os.environ.get('EXPORT_S3_BUCKET_NAME'),
                                                   IamRoleArn=os.environ.get('EXPORT_ROLE_ARN'),
                                                   KmsKeyId=os.environ.get('EXPORT_KMS_ID'))
                        i += 1

        except (ExportTaskLimitReachedFault) as export_limit:
            print('Wait for backups to complete before before attempting. {error}'.format(error=export_limit))
