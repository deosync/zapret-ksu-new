#!/system/bin/sh

boot_wait() {
    while [[ -z $(getprop sys.boot_completed) ]]; do sleep 3; done
}

boot_wait

MODDIR=/data/adb/modules/zapret
hostlist="--hostlist-exclude=$MODDIR/exclude.txt --hostlist-auto=$MODDIR/autohostlist.txt --hostlist-auto-fail-threshold=2 --hostlist-auto-fail-time=60 --hostlist-auto-retrans-threshold=2 --hostlist-auto-fail-threshold=2 --hostlist-auto-fail-time=60"
config="--filter-tcp=80,443 --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fooling=md5sig,badsum --dpi-desync-fake-tls=$MODDIR/t_google.bin --dpi-desync-fake-quic=$MODDIR/q_google.bin $hostlist --new";
config="$config --filter-udp=50000-50099 --ipset=$MODDIR/ipset-discord.txt --dpi-desync=fake --dpi-desync-any-protocol --dpi-desync-fake-tls=$MODDIR/t_google.bin --dpi-desync-fake-quic=$MODDIR/q_google.bin --new";
config="$config --filter-udp=80,443 --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-tls=$MODDIR/t_google.bin --dpi-desync-fake-quic=$MODDIR/q_google.bin $hostlist";

sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1 > /dev/null;
chmod 755 $MODDIR/*
chmod 666 "$MODDIR"/*.txt
chmod 666 "$MODDIR"/*.bin

iptAdd() {
    iptDPort="--dport $2"; iptSPort="--sport $2";
    iptables -t mangle -I POSTROUTING -p $1 $iptDPort -j NFQUEUE --queue-num 200 --queue-bypass;
    iptables -t mangle -I PREROUTING -p $1 $iptSPort -j NFQUEUE --queue-num 200 --queue-bypass;
}

iptMultiPort() {
    for current_port in $2; do
        if [[ $current_port == *-* ]]; then
            for i in $(seq ${current_port%-*} ${current_port#*-}); do
                iptAdd "$1" "$i";
            done
        else
            iptAdd "$1" "$current_port";
        fi
    done
}

tcp_ports="$(echo $config | grep -oE 'filter-tcp=[0-9,-]+' | sed -e 's/.*=//g' -e 's/,/\n/g' -e 's/ /,/g' | sort -un)";
udp_ports="$(echo $config | grep -oE 'filter-udp=[0-9,-]+' | sed -e 's/.*=//g' -e 's/,/\n/g' -e 's/ /,/g' | sort -un)";
iptMultiPort "tcp" "$tcp_ports";
iptMultiPort "udp" "$udp_ports";

check_nfqws_running() {
    if pgrep -x "nfqws" > /dev/null; then
        return 0
    else
        return 1
    fi
}

if check_nfqws_running; then
    exit 0
fi

while true; do
    if ! pgrep -x "nfqws" > /dev/null; then
	   # echo "[$(date)] nfqws not started, restarting..." >> "$MODDIR/logs.txt"
	   "$MODDIR/nfqws" --uid=0:0 --bind-fix4 --qnum=200 $config > /dev/null &
	   # echo "[$(date)] nfqws - PID $NFQWS_PID" >> "$MODDIR/logs_watchdog.txt"
    fi
    if ! iptables -t mangle -L POSTROUTING | grep -q "NFQUEUE"; then
        # echo "[$(date)] iptables rules missing, re-adding..." >> "$MODDIR/logs.txt"
        iptMultiPort "tcp" "$tcp_ports";
        iptMultiPort "udp" "$udp_ports";
    fi
    sleep 60
done
