#!/system/bin/sh
if [ ! -f "/data/adb/modules/zapret/nfqws" ]; then
    case "$(uname -m)" in "x86_64") BINARY="nfqws-x86_64";; "i386"|"i686") BINARY="nfqws-x86";; "armv7l"|"arm") BINARY="nfqws-arm";; "aarch64") BINARY="nfqws-aarch64";; *) echo "Unknown arch: $(uname -m)"; exit 1;; esac
    if [ -f "/data/adb/modules/zapret/$BINARY" ]; then
        mv "/data/adb/modules/zapret/$BINARY" "/data/adb/modules/zapret/nfqws"
        chmod 777 "/data/adb/modules/zapret/nfqws"
        rm -rf /data/adb/modules/zapret/nfqws-*
        if [ $(stat -c "%a" "/data/adb/modules/zapret/zapret.sh") != "777" ]; then
          chmod 777 "/data/adb/modules/zapret/zapret.sh"
        fi
    fi
fi
su -c "/data/adb/modules/zapret/zapret.sh"
