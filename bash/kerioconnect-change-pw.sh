#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# license: GPLv3
# script set same password for all users except admin account

CURDATE=`date '+%Y-%m-%d-%H%M%S'`
FILE=/opt/kerio/mailserver/users.cfg
BKPDIR=/root
BKPFILE=$BKPDIR/users-${CURDATE}.cfg

# stop service
/etc/init.d/kerio-connect stop

# backup users config file
cp $FILE $BKPFILE
chmod 600 $BKPFILE

# set same password for all users
xmlstarlet edit -L --update "/config/list[@name='User']/listitem/variable[@name='Password']" --value "D3S:fds5416f4ds568fd4s224bff4sw8f9wf4w1c5ds6" $FILE                          

# set password for admin (replace line 10 in users.cfg file)
sed -i '10 c <variable name="Password">D3S:fds45f6ds4f56ds46f234fsd4fds89f4ds98f4ds98f</variable>' $FILE                          

# start service
/etc/init.d/kerio-connect start
