#!/bin/bash
 
set +x
 
ADMINCRED=Administrator:password@ #todo - make a paramter
#SSH_PASSWORD=password
SSH="ssh -o StrictHostKeyChecking=no" #todo - sshpass (this one as a fallback)
SCP="scp -o StrictHostKeyChecking=no" #todo - scppass (this one as a fallback)
 
NOW=`date +%F`
DATE=${1:-$NOW}
IP=${2:-127.0.0.1}
ISUPLOAD=${3:-false}
TICKET=${4}/
 
USER=user
CUSTOMER=myCompany

# Currently you need to run it twice. once for gathering the logs (with upload=false) and once to upload (upload=true)
# usage example: ./getlogs.sh 2018-11-07 cb-node01 false 91919
# -----------------scriptname YYYY-MM-DD hostname      bool  ticketNumber
 
echo  usage example: ./getlogs.sh 2018-11-07 cb-node01 false 91919
echo  ---------------- scriptname YYYY-MM-DD hostname----- bool- ticketNumber

echo Node in the cluster IP:  $IP
echo Running on date: $DATE
 
HOSTS=`curl -su ${ADMINCRED} http://${IP}:8091/pools/nodes  | python -m json.tool |grep hostname | awk '{print substr($2, 2, length($2)-3)}'`
arr_hosts=( $HOSTS )
echo Hosts in the cluster: "${arr_hosts[*]}"
 
 
CBTEMP=/opt/couchbase/var/lib/couchbase/tmp #todo- check for custom directory
COLLECT=collectinfo
LOCAL=/home/$USER/logsFor_$DATE
 
echo $CBTEMP, $COLLECT, $LOCAL
 
fileCounter=0
if [ $ISUPLOAD = false ]; then
echo Loop through nodes "${arr_hosts[*]}"
echo "********************"
for host in "${arr_hosts[@]}"
do
    host_name=${host%:*}
    echo "Connecting to node:" $host_name
    echo Copying files to local folder
    ${SSH} $USER@${host_name} "mkdir $LOCAL" 2>/dev/null || true
    echo ${SSH} $USER@${host_name} "sudo ls /opt/couchbase/var/lib/couchbase/tmp/ | grep $COLLECT-$DATE |  xargs -I '{}' sudo cp $CBTEMP/'{}' $LOCAL/"
    ${SSH} $USER@${host_name} "sudo ls /opt/couchbase/var/lib/couchbase/tmp/ | grep $COLLECT-$DATE | xargs -I '{}' sudo cp $CBTEMP/'{}' $LOCAL/"
    echo fixing permissions
    echo ${SSH} $USER@${host_name} "sudo chown $USER:$USER $LOCAL/$COLLECT*" 2>/dev/null || true
    ${SSH} $USER@${host_name} "sudo chown $USER:$USER $LOCAL/$COLLECT*" 2>/dev/null || true
    echo Copying files to local folder
    echo ${SCP} $USER@${host_name}:${LOCAL}/$COLLECT* .
    ${SCP} $USER@${host_name}:${LOCAL}/$COLLECT* .
done
echo "Total number of file copied: " $fileCounter
fi

fileCounter=0
if [ $ISUPLOAD = true  ]; then
  for file in $(ls *.zip)
  do
        echo "Uploading file " $file ": "  $fileCounter
        sudo chown $USER:$USER $file
        curl -v --upload-file $file https://s3.amazonaws.com/customers.couchbase.com/$CUSTOMER/$TICKET
        let fileCounter++
  done
  echo "Total number of files uploaded: " $fileCounter
fi
