# Sauvegarde d'un serveur Nextcloud

##Rappel du contexte
Nous avons deux machines virtuelles :
* Nextcloud - machine virtuelle faisant tourner l'application Nextcloud
* Backup - machine virtuelle faisant office de serveur de sauvegarde

Le but de ce TP est de mettre en place la sauvegarde de l'application. Cette sauvegarde doit pouvoir être historisé avec une durée de rétention de 30 jours.

Il faut aussi bien sauvegarder les fichiers que la base de données afin de permettre une restauration.

##Lancement des scripts

Les scripts se lancent à partir de la machine `Nextcloud`.