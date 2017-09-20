#!/bin/bash
#===================================================
#
#   Configuration de transmission pour l'adresse ip
#
#
#/etc/init.d/transmission-daemon stop
#===================================================


log_file=/var/log/seedbox.log
fcfgtr="/etc/transmission-daemon/settings_template.json"



# si le script contient bien le paramètre script_type cad appelé par openvpn
[ "$script_type" ] || exit 0




# en fonction de la valeur du paramètre, cad démarrage ou stop
case "$script_type" in
  up)
    echo $(date -u) ": cfg_transmission : up" >> $log_file

    # si le fichier de configuration modèle existe (créé par l'installation)
    if [ -f $fcfgtr ]; then

        # ajouter l'adresse par laquelle trans est autorisé à télécharger
        sed s/IP_ADDRESS/$4/  /etc/transmission-daemon/settings_template.json > /etc/transmission-daemon/settings.json

        # lancer le service trans.
        service transmission-daemon start
    else
        echo $(date -u) ": cfg_transmission : ERREUR le fichier template de transmission daemon existe pas" >> $log_file
    fi
	;;

  down)
    echo $(date -u) "cfg_transmission : down" >> $log_file
    service transmission-daemon stop
	;;

esac

echo $(date -u) "cfg_transmission : end" >> $log_file






