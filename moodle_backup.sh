#!/bin/bash
export PATH=/bin:/usr/bin:/usr/local/bin

################################################################
######################## Variables #############################

NOWDATE=$(date +"%Y%m%d")
NOWTIME=$(date +"%H%M%S")

### Temporary space
TEMP=/tmp

### MYSQL variables
MYSQL_HOST='localhost'
MYSQL_USER='root'
MYSQL_PASSWORD='+cFdWJ7>Ef'
DATABASES=$(mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

### Logging
LOG_PATH=/var/logs/moodle_backup
LOG_NAME=moodle_backup.log
LOG_FILE=$LOG_PATH/$LOG_NAME
LOG_ARCHIVE=$LOG_PATH/moodle_backup

### File locations for backup (add each web root, making sure each site has a tar command in the magic section
WEB_DIR1=/var/www/html/moodle
WEB_DIR2=/var/www/html/moodledata

### Backup destination settings
DB_BACKUP_PATH=/var/www/html/moodle_backup
DATA_ARCHIVE=moodel_backup-$NOWDATE-$NOWTIME
ARCHIVE_RETENTION=5

#################################################################
################## The magic happens here  ######################

for db in $DATABASES; do
	FILE="${TEMP}/$db.sql"
	mysqldump --single-transaction --routines --quick -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -B $db > $FILE
done

tar czvf $DB_BACKUP_PATH/$DATA_ARCHIVE.tar.gz $WEB_DIR1 $WEB_DIR2 $TEMP/*.sql
rm -f $TEMP/*.sql

tee $LOG_FILE << END
Backup was successfully
$(ls -sh1 $DB_BACKUP_PATH/* |tail -n1)
END
