#!/system/bin/sh
# MODDIR=${0%/*}
# SERVICEDDIR=/data/adb/service.d

su -c "kill $(pgrep -f '/data/adb/service.d/zapret.sh')"
su -c 'pkill nfqws'
su -c 'pkill zapret'
su -c 'iptables -t mangle -F PREROUTING'
su -c 'iptables -t mangle -F POSTROUTING'
