#!/bin/bash

# dont forget to make the script executeable 

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
# //smb/path/backup /mnt/backup cifs defaults,rw,username=YOURUSER,password=YOURPASSWORD 0 0
#
# this should mount the shared folder at start up if available
#
# -----------------------------------------------
#
# for the ssh connection you need to own the private key file and put it into:
# /home/USER/.ssh
# 
# take care the correct permission for this folder
# >>chmod 700 /~.ssh && chmod 600 ~/.ssh/*
#
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
# path to MCServer eg. /home/user/MCServer
sourcePath=MCServer
#
# files/folders do backup
backupList=( 'gal/' 'world/' 'Gallery.cfg' 'Gallery.sqlite' )
#
# path to local backup folder "/home/user/backup"
localBackupPath=backup
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
#
# ***** SMB shared folder ******
#
# smb user
smbUser=nobody
#
# smb password
smbPass=1234
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

fileDateFormat=$(date +"%Y-%m-%d_%H-%M-%S").tgz
targetFolderFormat=$(date +"%Y-%m")

# check if any files/folders given
if [ ! $backupList ] ; then
  echo "No files for backup"
  exit 1
fi


# check for 7z or tar
if [ "$packer" == "7z" ] ; then
    
    for i in "${backupList[@]}" 
    do
        7z a -mx9 $localBackupPath/$fileDateFormat.7z $sourcePath/$i
    done
else
    # delete temp file
    if [ -f "tmp" ] ; then
        rm "tmp"
    fi
    
    # write file list for tar
    for i in "${backupList[@]}" 
    do
        echo $sourcePath/$i >> tmp
    done
    
    # tar everything from list
    tar cvfz $localBackupPath/$fileDateFormat.tgz -T tmp
fi


# copy to smb
if [ ! -d $smbPath/$targetFolderFormat ] ; then
    mkdir $smbPath/$targetFolderFormat
fi

cp $localBackupPath/$fileDateFormat $smbPath/$targetFolderFormat/


# copy to remote via scp
ssh -p $remotePort $remoteUser@$remoteHost "mkdir -p $remotePath/$targetFolderFormat" && scp -rp -P $remotePort $src $remoteUser@$remoteHost:$remotePath/$targetFolderFormat


# check if local backup should be deleted
if [ "$deleteLocal" = true ] ; then
  rm $localBackupPath/*
fi

exit 0
