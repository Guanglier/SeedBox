#!/bin/bash

#-----configuration -----
filedest="/etc/openvpn/cfg.ovpn"
PathFilesCfg="/etc/openvpn/configs/*.ovpn"


#-----lister tous les fichiers puis en prendre un au hasard
files=($PathFilesCfg)
fichier=${files[RANDOM % ${#files[@]}]}


#------supprimer ancien puis copier le fichier choisi
rm $filedest
cp $fichier     $filedest

#------modificer le fichier : le fichier contenant le mot de passe est "readme"
sed -i "s/auth-user-pass/auth-user-pass readme/g" $filedest



