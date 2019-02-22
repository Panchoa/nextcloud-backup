#!/bin/bash

echo "Starting backup."
printf "\n\n\n"
echo "--------------------------------------------------"

#Login serveur nextcloud
echo "***Setup Nextcloud***"
echo "Veuillez entrer l'adresse du serveur Nextcloud : "
read nextcloudHost

printf "\n\n"
echo "***Setup Backup server***"
echo "Veuillez entrer l'adresse du serveur de backup : "
read backupHost

printf "\n\n"
echo "***Setup SSH user***"
echo "Veuillez saisir un user pour la connexion SSH : "
read user

printf "\n\n\n"
echo "--------------------------------------------------"

echo "Ajout des serveurs aux known_hosts"
ssh-keyscan -H ${nextcloudHost} >> ~/.ssh/known_hosts
ssh-keyscan -H ${backupHost} >> ~/.ssh/known_hosts

#Création d'un utilisateur pour les backups
sudo -S adduser backup-nextcloud --disabled-password --gecos '' --shell /sbin/nologin --quiet
echo "Utilisateur backup-nextcloud créé"

#Génération des clés SSH pour le user créé
echo "***Génération d'une clé SSH ***"
sudo -S  mkdir /home/backup-nextcloud/.ssh
sshKeyPath="/home/backup-nextcloud/.ssh/id_rsa"
sudo -S ssh-keygen -t rsa -N \"\" -f ${sshKeyPath}
sudo -S chown -R backup-nextcloud:backup-nextcloud /home/backup-nextcloud/.ssh

echo "Copie de la clé publique vers le server backup, entrez le mot de passe quand c'est demandé"
ssh-copy-id -i ${sshKeyPath} ${user}@${backupHost}

echo "Cle copiée avec succès !"

printf "\n\n\n"
echo "--------------------------------------------------"

#Création d'un utilisateur sur le serveur backup
echo "Creation d'un utilisateur backup-nextcloud sur le serveur de backup"
ssh -i ${sshKeyPath} ${user}@${backupHost} "sudo -S adduser backup-nextcloud --disabled-password --gecos '' --shell /sbin/nologin --quiet"
echo "Utilisateur backup-nextcloud créé"

printf "\n\n"
echo "Creation des dossiers pour les backups"
ssh -i ${sshKeyPath} ${user}@${backupHost} "sudo -S mkdir -p /data/snapshots /data/backup/files /data/backup/database | sudo -S chown backup-nextcloud:baclup-nextcloud /data/snapshots /data/backup/files /data/backup/database"

echo "Setup terminé pour le serveur de backup"

printf "\n\n\n"
echo "--------------------------------------------------"

#Backup script
echo "Backup script"
scp -i ${sshKeyPath} -p ./backup.sh ${user}@${backupHost}:/home/user
ssh -i ${sshKeyPath} ${user}@${backupHost} \
"sudo -S mv /home/user/backup.sh /home/backup-nextcloud/ &&
 sudo -S chmod +x /home/backup-nextcloud/backup.sh &&
 sudo -S chown backup-nextcloud:backup-nextcloud /home/backup-nextcloud/backup.sh"

printf "\n\n\n"
echo "--------------------------------------------------"

#TODO : Tâches CRON pour automatiser