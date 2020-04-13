#!/bin/bash

source chuboe.properties
IDPID=`sudo -u $CHUBOE_PROP_IDEMPIERE_OS_USER jcmd | grep "[0-9]* /opt/idempiere-server" -o | grep "[0-9]*" -o`
IDDATE=$(date +%s.%N)

echo pid=$IDPID
echo date=$IDDATE

sudo -u $CHUBOE_PROP_IDEMPIERE_OS_USER jcmd $IDPID GC.heap_dump /tmp/heap_dump.$IDPID.$IDDATE
top -H -b -n1 -p $IDPID |& tee /tmp/heap_top.$IDPID.$IDDATE

echo set file ownership to $USER
sudo chown $USER:$USER /tmp/*$IDDATE*

echo see /tmp/ for output. execute the following command to see latest files in /tmp/
echo ls -ltrh /tmp/*$IDDATE*
echo files created:
ls -ltrh /tmp/*$IDDATE*