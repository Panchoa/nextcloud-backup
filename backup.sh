#!/bin/bash

#Mise en maintenance de Nextcloud
sudo -u www-data /usr/bin/php /var/www/html/nextcloud/occ php occ maintenance:mode --on

#Copie des fichiers de l'application Nextcloud
rsync -avz -e "ssh -i /home/backup-nextcloud/.ssh/id_rsa" --rsync-path="sudo rsync" backup-nextcloud@nextcloud:/var/www/html/nextcloud/ /data/backup/files/

#Backup de la base de données
ssh -i /home/backup-nextcloud/.ssh/id_rsa backup-nextcloud@nextcloud "mysqldump --single-transaction -u 'oc_admin' -pk6wvf+vqhqlwT9zXS9oLXA0X+l9Imm nextcloud > /home/backup-nextcloud/nextcloud-sqlbkp_`date + \"%Y%m%d\"`.bak"
rsync -avz -e "ssh -i /home/backup-nextcloud/.ssh/id_rsa" --rsync-path="sudo rsync"  backup-nextcloud@nextcloud:/home/backup-nextcloud/nextcloud-sqlbkp_`date + \"%Y%m%d\"`.bak /data/backup/database/
ssh -i /home/backup-nextcloud/.ssh/id_rsa backup-nextcloud@nextcloud "rm /home/backup-nextcloud/nextcloud-sqlbkp*"

#Remise à normal de Nextcloud
sudo -u www-data /usr/bin/php /var/www/html/nextcloud/occ php occ maintenance:mode --off
