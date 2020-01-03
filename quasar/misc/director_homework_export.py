import argparse
import csv
import hashlib
from pathlib import Path

from utils import log
from export_sql_to_file import export_sql

# Get home directory path
home = str(Path.home())
# Get arguments.
parser = argparse.ArgumentParser()
parser.add_argument("--file", "-f",
                    help="Provide SQL query file name, including path.")
parser.add_argument("--output", "-o",
                    help="Output file name. File written to home directory.")
parser.add_argument("--mel_export", "-me",
                    help="Export homework for 2019 Director of Data job.")
args = parser.parse_args()


def mel_homework_export():
    # Used to export master mel key file and homework for 2019 Director
    # of Data position. Hash's Northstar ID's as extra column and removes
    # original NSID column from homework CSV.
    if args.mel_export and args.file and args.output:
        export_sql(args.file, args.output)
        # Specify inport and export files.
        csv_in = home + "/" + args.output
        mel_key_out = home + "/mel-key-" + args.output
        homework_out = home + "/homework-" + args.output
        # This block generates master key file with extra hash column.
        with open(mel_key_out, "w") as key_out, open(csv_in, "r") as csv_read:
            reader = csv.reader(csv_read)
            writer = csv.writer(key_out)
            # Next 3 lines generate additional column to header line and
            # skips first header line before data lines written.
            header = next(reader)
            header.append('hashed_northstar_id')
            writer.writerow(header)
            # Hash Northstar ID for each row and write to last value.
            for row in reader:
                ns_hash = hashlib.md5(row[1].encode('utf-8')).hexdigest()
                row.append(ns_hash)
                writer.writerow(row)
        # This block removes the Northstar ID column & values for sending to
        # the director candidate.
        with open(mel_key_out, "r") as key_in, \
                open(homework_out, "w") as dir_out:
            reader = csv.reader(key_in)
            writer = csv.writer(dir_out)
            for row in reader:
                del row[1]
                writer.writerow(row)
        log("MEL exported key file is located at {}".format(mel_key_out))
        log("Homework file is located at {}".format(homework_out))
    else:
        pass


mel_homework_export()
