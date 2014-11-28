MCbackup
========

simple backup bash script to do auto backup task to remote places



dont forget to make the script executeable
- cron
if running the script hourly, daily or weekly
just copy it to the corresponding folder in
/etc/cron.hourly
/etc/cron.daily
/etc/cron.weekly

if this is not enough, open crontab editor with
>>crontab -e

minute hour day-of-month month day-of-week command

eg
0 3 * * * /path/to/backup.sh

will run the script every day at 3am

----------------------------------------------

for the SMB share you need to install cifs.
>>sudo apt-get install cifs-utils

create a folder in /mnt for backup inclusion
>>sudo mkdir /mnt/backup

to mount the shared folder from smb manually:
sudo mount -t cifs //smb/path/folder /mnt/backup -o user=nobody

to mount the shared folder automatically at reboot open the file "/etc/fstab" as root
add one line in the following format:
//smb/path/backup /mnt/backup cifs defaults,rw,username=YOURUSER,password=YOURPASSWORD 0 0

this should mount the shared folder at start up if available

-----------------------------------------------

for the ssh connection you need to own the private key file and put it into:
/home/USER/.ssh

take care the correct permission for this folder
>>chmod 700 /~.ssh && chmod 600 ~/.ssh/*


to install 7z use
>> sudo apt-get install p7zip-full


good luck


script created by
nouseforname @ nouseforname.de @ 28. Nov. 2014
