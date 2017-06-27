#!/bin/bash

PATH=$PATH:/usr/local/bin

gdrive_id = 
# [tmp]が無ければ作成


# [tmp]make gdrive_list_tmp
# 現状のgdrive上の一覧
gdrive list --no-header | tr -s [:space:] | cut -d ' ' -f 1,2 | sort -t ' ' -k 2 > tmp/gdrive_list_tmp


# [tmp]make list_tmp
# 現状のバックアップ元(/mnt/sda)の一覧
find /mnt/sda -type f -o -type d > tmp/sda_test1
cat tmp/sda_test1 | while read list
do
	echo ${list##*/} >> tmp/sda_test2
done
paste -d ' ' tmp/sda_test1 tmp/sda_test2 |  sort -t ' ' -k 2 > tmp/sda_list_tmp


# [tmp]make list_rm
# 前回の実行分sync_listとの差分を
join -t ' ' -1 1 -2 2 -v 1 sync_list tmp/sda_list_tmp | cut -d ' ' -f 2 > tmp/gdrive_list_rm
join -t ' ' -1 1 -2 2 -v 1 sync_list tmp/gdrive_list_tmp | cut -d ' ' -f 3 > tmp/sda_list_rm


# rm gdrive
cat tmp/gdrive_list_rm | while read list
do
	gdrive delete -r $list
done


# rm ras
cat tmp/sda_list_rm | while read list
do
	rm -rf $list
done


# sync
gdrive sync upload /mnt/sda $gdrive_id
gdrive sync download $gdrive_id /mnt/sda
if [ $? -eq 0 ]; then
	echo "<br>gdrive syn:<font color=blue>OK</font>" >> ~/sh/mkbackup_result
else
	echo "<br>gdrive syn:<font color=red>false</font>" >> ~/sh/mkbackup_result
fi


# make sync_list -> name id path
# sync後のファイルとIDの一覧
rm -f tmp/sda_test2
gdrive list --no-header | tr -s [:space:] | cut -d ' ' -f 1,2 | sort -t ' ' -k 2 > tmp/gdrive_list_tmp
find /mnt/sda -type f -o -type d > tmp/sda_test1
cat tmp/sda_test1 | while read list
do
	echo ${list##*/} >> tmp/sda_test2
done
paste -d ' ' tmp/sda_test1 tmp/sda_test2 |  sort -t ' ' -k 2 > tmp/sda_list_tmp
join -t ' ' -1 2 -2 2 tmp/gdrive_list_tmp tmp/sda_list_tmp > sync_list


# [tmp]kataduke
rm -f tmp/*
