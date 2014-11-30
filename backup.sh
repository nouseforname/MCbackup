#!/bin/bash

# Don't forget to make the script executable

# - cron
# if running the script hourly, daily or weekly
# just copy it to the corresponding folder in
# /etc/cron.hourly
# /etc/cron.daily
# /etc/cron.weekly
#
# if this is not enough, open crontab editor with 
# >>crontab -e
# 
# minute hour day-of-month month day-of-week command
# 
# eg
# 0 3 * * * /path/to/backup.sh
#
# will run the script every day at 3am
#
# ----------------------------------------------
#
# for the SMB share you need to install cifs.
# >>sudo apt-get install cifs-utils
#
# create a folder in /mnt for backup inclusion
# >>sudo mkdir /mnt/backup
#
# to mount the shared folder from smb manually:
# sudo mount -t cifs //smb/path/folder /mnt/backup -o user=nobody 
# 
# to mount the shared folder automatically at reboot open the file "/etc/fstab" as root
# add one line in the following format:
# //smb/path/backup /mnt/backup cifs defaults,rw,username=YOURWINUSER,password=YOURWINPASSWORD,file_mode=0777,dir_mode=0777 0 0
#
# this should mount the shared folder at start up if available.
# Run "umount /mnt/backup;mount -a" after changing the fstab file to test out the changes
#
# -----------------------------------------------
#
# to install 7z use
# >> sudo apt-get install p7zip-full
#
#
# good luck
#
# 
# script created by
# nouseforname @ nouseforname.de @ 28. Nov. 2014
# 
#
###############################################################

# ***** CONFIG START ***** #
#
#
# ***** local ******
# path to MCServer
sourcePath=/home/user/MCServer
#
# files/folders to backup
backupList=( 'gal/' 'world/' 'Galleries.cfg' 'Galleries.sqlite' )
#
# path to local backup folder
localBackupPath=/home/user/backup
#
#
# ***** remote server via ssh ******
# remote username
remoteUser=myUser
#
# remote host
remoteHost=localhost
#
# remote port
remotePort=22
#
# remote path to backup folder
remotePath=/home/user/backup
#
# keyfile to use for the remote. Note that it shouldn't be password-protected
# Use "openssl rsa -in remoteprivkey.pem -out remoteprivkey-passwordless.pem" to remove password
remoteKeyFile=/home/user/.ssh/remoteprivkey-passwordless.pem
#
#
# Make sure the keyfile and its folder have the right permissions:
# chmod 700 /home/user/.ssh && chmod 600 /home/user/.ssh/remoteprivkey-passwordless.pem

# ***** SMB shared folder ******
#
# remote SMB share path
smbPath=/mnt/backup
#
#
# ***** misc *****
#
# delete local backup after?
deleteLocal=false
#
# 7z or tar
packer=7z
#
# ***** CONFIG END ***** #
###############################################################

fileDateFormat=$(date +"%Y-%m-%d_%H-%M-%S")
targetFolderFormat=$(date +"%Y-%m")

# check if any files/folders given
if [ ! $backupList ] ; then
  echo "No files for backup"
  exit 1
fi


# write file list
for i in "${backupList[@]}"
do
    echo $sourcePath/$i >> tmp
done

# Use 7z or tar to pack the files
if [ "$packer" == "7z" ] ; then
    packedFileName=$localBackupPath/$fileDateFormat.7z
    # Using -mx3 to reduce memory requirements; -mx9 won't work at all on the RasPi; -mx5 and -mx7 randomly fail due to out-of-memory
    7z a -mx3 $packedFileName @tmp
else
    packedFileName=$localBackupPath/$fileDateFormat.tgz
    tar cvfz $packedFileName -T tmp
fi


# copy to smb
if [ ! -d $smbPath/$targetFolderFormat ] ; then
    mkdir $smbPath/$targetFolderFormat
fi

cp $packedFileName $smbPath/$targetFolderFormat/


# copy to remote via scp
ssh -i $remoteKeyFile -p $remotePort $remoteUser@$remoteHost "mkdir -p $remotePath/$targetFolderFormat" && scp -rp -i $remoteKeyFile -P $remotePort $packedFileName $remoteUser@$remoteHost:$remotePath/$targetFolderFormat


# check if local backup should be deleted
if [ "$deleteLocal" = true ] ; then
  rm $localBackupPath/*
fi

exit 0
