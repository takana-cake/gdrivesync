#!/bin/bash

PATH=$PATH:/usr/local/bin
gdrive_id = ''

#sync local to gdrive
gdrive sync upload /mnt/sda $gdrive_id
if [ $? -eq 0 ]; then
echo "<br>gdrive syn:<font color=blue>OK</font>" >> /var/www/html/plugin/status.mkbackup_result
else
echo "<br>gdrive syn:<font color=red>false</font>" >> /var/www/html/plugin/status.mkbackup_result
fi

#make list_G diff
gdrive list --no-header | tr -s [:space:] | sort -t ' ' -k 2 > gdrive_list

#make list_lo diff
ls -lR /mnt | grep ^[d,l,\-] | tr -s [:space:] | sort -t ' ' -k 9 > sda_list

#TOKUNI IMI NASHI
join -1 2 -2 9 gdrive_list sda_list > File_ID_LIST

#del list
join -1 2 -2 9 -v 1 gdrive_list sda_list | cut -d ' ' -f 2 > rm_list
cat rm_list | while read list
do
    gdrive delete -r $list
done
