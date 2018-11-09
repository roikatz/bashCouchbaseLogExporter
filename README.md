# Couchbase log files exporter (BASH)

This bash script will assist you in consolidating your Couchbase cluster logs and send these to Couchbase.
You won't need any special installations of any tool, just a user who have sudo permissions.

```
Note, this is an independent tool and won't be supported by Couchbase. It can make your log collection a bit easier, use it with caution
```

## What the script does
1. Connects to one of the Couchbase nodes to get the cluster map, which is all of the nodes in the cluster
2. For each node
  2.1. Make a temp folder for the user connected (locally)
  2.2 Copy the log file with the specified date to a reachable folder that the scp can read
  2.3 fix permissions
  2.4 scp the file to the computer which runs the script
3. for each local file copies
  2.1 fix local permissions from root to the local user
  2.2 curl post to the right location in Couchbase AWS servers.

## How to use
0. Pre-requisite, collect logs from couchbase UI (or locally). By default the output would be on /opt/couchbase/var/lib/couchbase/tmp/
1. Now that you have to log, execute the script, you would need the date of the log collection (YYYY-MM-DD),
one of your Couchbase cluster nodes, specify wheter you want to fetch the logs from the cluster (in this step = false)
and the ticket number you want to assosiate the logs with (doesn't matter for the initial step).

``` bash
sudo ./exportLogs.sh 2018-11-07 cb-node01 false 91919
```
2. Once gathered, Upload the files to Couchbase servers. note - you would have to have a permission to upload from that server.

``` bash
sudo ./exportLogs.sh 2018-11-07 cb-node01 true 91919
```
