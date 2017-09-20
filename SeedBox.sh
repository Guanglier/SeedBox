#!/bin/sh - 
### BEGIN INIT INFO
# Provides: SeedBoxOpenVPN
# Required-Start: $remote_fs $syslog
# Required-Stop: $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Lance la seedbox en demarrant le vpn et transmi
# Description: Lance la seedbox en demarrant le vpn et transmi
### END INIT INFO

# ATTENTION : on stoppe pas transmission-daemon car il est automatiquement stoppé par openvpn
# service transmission-daemon stop
#sudo update-rc.d SeedBox.sh defaults


log_file=/var/log/seedbox.log


#==================================================
#     sequence de démarrage
#   on stoppe tout et puis on lance openvpn qui se chargera de lancer transmission lorsqu'il sera connecté
#==================================================
start() {
    stop
    cd /etc/openvpn
    ./cfg_openvpn.sh
    openvpn --config /etc/openvpn/cfg.ovpn --daemon --script-security 2 --up /etc/openvpn/vpn_StateChange.sh  --down /etc/openvpn/vpn_StateChange.sh
}

#==================================================
#     sequence d'arrêt
#==================================================
stop() {
    service openvpn stop
    sleep 5
    killall openvpn
    killall transmission-daemon
    sleep 2
}



#==================================================
#     main logic
#==================================================
case "$1" in
  start)
        echo $(date -u) ": START" >> $log_file
        start
        echo $(date -u) ": END" >> $log_file
        echo " " >> $log_file
        ;;
  stop)
        echo $(date -u) ": STOP" >> $log_file
        stop
        echo $(date -u) ": END" >> $log_file
        echo " " >> $log_file
        ;;
  status)
        ;;
  restart|reload|condrestart)
        stop
        start
        echo $(date -u) ": END" >> $log_file
        echo " " >> $log_file
        ;;
  *)
        echo $"Usage: $0 {start|stop|restart|reload|status}"
        exit 1
esac

exit 0




