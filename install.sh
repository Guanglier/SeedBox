#!/bin/bash

clear

echo "->Installation des dépendances ..."
sudo apt-get install transmission-daemon
sudo apt-get install openvpn
sudo apt-get install unzip



echo "->Stop service transmission..."
sudo service transmission-daemon stop
sudo systemctl disable transmission-daemon
sudo update-rc.d -f transmission-daemon remove
if [ ! -e /etc/default/transmission-daemon.orig ]; then
    sudo cp /etc/default/transmission-daemon  /etc/default/transmission-daemon.orig
fi
sudo sed -i 's#ENABLE_DAEMON=1#ENABLE_DAEMON=0#g' /etc/default/transmission-daemon


echo "->Stop service openvpn..."
sudo service openvpn stop
sudo systemctl disable openvpn
sudo update-rc.d -f openvpn remove


echo "->unzip configs VPN..."
unzip -q configs.zip
sudo rm configs.zip


echo "->copie configs VPN..."
DirCfgVPN=/etc/openvpn/configs
if [ -d $DirCfgVPN ]; then
    sudo rm  $DirCfgVPN/*.ovpn
else
    sudo mkdir $DirCfgVPN
fi
sudo mv *.ovpn $DirCfgVPN


echo "->copie certificats..."
sudo mv  *.crt  /etc/openvpn/


echo "->copie scripts..."
sudo rm /etc/openvpn/cfg_openvpn.sh
sudo mv cfg_openvpn.sh          /etc/openvpn/
sudo chmod -c 755 /etc/openvpn/cfg_openvpn.sh

echo "->copie scripts..."
sudo rm /etc/openvpn/readme
sudo mv readme                  /etc/openvpn/
sudo chmod -c 640 /etc/openvpn/readme

echo "->copie scripts..."
sudo rm /etc/openvpn/cfg_transmission.sh
sudo mv cfg_transmission.sh     /etc/openvpn/
sudo chmod -c 755 /etc/openvpn/cfg_transmission.sh

echo "->copie scripts..."
sudo rm /etc/openvpn/vpn_up.sh
sudo mv vpn_up.sh /etc/openvpn/
sudo chmod -c 755 /etc/openvpn/vpn_up.sh


echo "->copie scripts..."
sudo service SeedBox.sh stop
sudo rm /etc/init.d/SeedBox.sh
sudo mv SeedBox.sh  /etc/init.d/
sudo update-rc.d SeedBox.sh defaults


echo "->transmission : Fichier template"

# si fichier pas présent, on le supprime pour le refaire
FileTemplateTransmission="/etc/transmission-daemon/settings_template.json"
if [ -f $FileTemplateTransmission ]; then
    echo "---> transmission : fichier template deja present -> suppression"
    sudo rm -f $FileTemplateTransmission
fi


#si la sauvegarde n'existe pas on la crée, sinon on ne touche pas ...
if [ ! -e /etc/transmission-daemon/settings.json.orig ]; then
    echo "---> transmission : sauvegarde du fichier de config en .orig"
    sudo cp /etc/transmission-daemon/settings.json  /etc/transmission-daemon/settings.json.orig
else
    echo "---> transmission : fichier de config en .orig deja present"
fi


if [ ! -e $FileTemplateTransmission ]; then
    echo "---> transmission : creation fichier template"
    sudo cp /etc/transmission-daemon/settings.json  $FileTemplateTransmission
else
    echo "ERREUR ---> transmission : fichier de config template deja present"
fi

# suppression fichier congif template si deja présent
if [ ! -e  /etc/transmission-daemon/settings.json  ]; then
    echo "---> transmission : suppression du fichier de config present"
    sudo rm /etc/transmission-daemon/settings.json
fi


# configuration pour ne passer que par le VPN
echo "---> transmission : configuration adresse ip pour vpn"
sudo sed -i 's#"bind-address-ipv4": .*#"bind-address-ipv4": "IP_ADDRESS",#g' $FileTemplateTransmission
#sudo sed -i 's#"bind-address-ipv4": "0.0.0.0",#"bind-address-ipv4": "IP_ADDRESS",#g' $FileTemplateTransmission
#sudo sed -i 's#"bind-address-ipv6": "::",#"bind-address-ipv6": "fe80::",#g' $FileTemplateTransmission


# autoristation de connexion a l'interface de gestion avec mot de passe
echo "---> transmission : configuration interface de controle"
sudo sed -i 's#"rpc-whitelist-enabled": *$#"rpc-whitelist-enabled": false,#g' $FileTemplateTransmission
sudo sed -i 's#"rpc-password":.*$#"rpc-password": "fuckhadopi",#g'  $FileTemplateTransmission
sudo sed -i 's#"rpc-username":.*$#"rpc-username": "moncul",#g'  $FileTemplateTransmission


# configuration du dossier de téléchargement
echo "---> transmission : configuration dossier telechargement"
sudo sed -i 's#"download-dir":.*$#"download-dir": "/var/lib/transmission-daemon/downloads/hdd2to",#g'  $FileTemplateTransmission


# mise en place de la blocklist
echo "---> transmission : Configuration blocklist"
sudo sed -i 's#"blocklist-enabled":.*$#"blocklist-enabled": true,#g'  $FileTemplateTransmission
sudo sed -i 's#"blocklist-url":.*$#"blocklist-url": "http://john.bitsurge.net/public/biglist.p2p.gz",#g'  $FileTemplateTransmission

echo "---> transmission : Telechargement de la blocklist... attendre ..."
FileBlockListURL="http://john.bitsurge.net/public/biglist.p2p.gz"
BlockListDir="/var/lib/transmission-daemon/info/blocklists/"
FileBlockListName="${FileBlockListURL##*/}"

wget  $FileBlockListURL
if [ -f $FileBlockListName ]; then
    echo "---> TRANSMISSION : Configuration blocklist ---> Telechargement ok"
    rm -f $BlockListDir*

    gunzip -f $FileBlockListName

    if [ $? -eq 0 ]; then
        echo "---> TRANSMISSION : Configuration blocklist ---> Extraction ok"
        sudo mv *.p2p $BlockListDir
    else
        echo "ERREUR ---> TRANSMISSION : Configuration blocklist ---> extraction"
    fi

else
    echo "ERREUR ---> TRANSMISSION : Configuration blocklist ---> telechargement"
fi






echo "->Clear log systeme..."
./clear.sh

echo ""
echo "==============================================================="
echo ""
echo "Attention il vous reste à configurer :"
echo "---------------------------------------------------------------"
echo " * login et mot de passe du vpn dans le fichier 'readme', login, à la ligne, mot de passe"
echo " * chemin de téléchargement dans le fichier /etc/transmission-daemon/settings_template.json"
echo " "
echo "Pour lancer : sudo service SeedBox start"
echo "Pour stopper : sudo service SeedBox stop"
echo "Pour accéder par navigateur à la gestion : adr_ip:9091   (user=moncul pass=fuckhadopi)"
echo "Pour clear des logs :  sudo ./clear.sh"
echo "Pour avoir le status VPN+transmi : ./status.sh"
echo ""


