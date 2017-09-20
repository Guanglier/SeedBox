

il faut 

 1 - configurer l'utilisateur et le mot de passe du VPN dans le fichier "readme".
 2 - avoir un fichier "configs.zip" contenant les différents fichiers de connexion .ovpn et le certificat (ici c'est ceux d'ipvanish)
 3 - lancer le script install en sudo et regarder les retours du script pour voir si tout se passe bien


Fonctions : 
 - installe tout seul tout ce qu'il faut (openvpn, transmission) et configure tout
 - configure transmission-daemon pour utiliser openvpn
 - accès à l'interface de gestion de transmission-daemon par l'adresse en local
 - utilisation d'une liste "blocklist" pour bloquer les ip indésirables
 - utilisation d'une config vpn (et donc un serveur vpn) différent à chaque démarrage (d'ou le fichier "configs.zip" contenant de multiples configs)


============================
attention sur pi v 3 :
============================

1) la pi semble planter sous charge :  dans /boot/cmdline.txt rajouter à la fin de la ligne :
   smsc95xx.turbo_mode=N

2) changer le type de notify pour transmission par systemd :
dans 
/lib/systemd/system/transmission.service
changer Type=notify  par  Type=simple (ou supprimer la ligne)

tout cela ne résoud pas tout à fait le pb ...

