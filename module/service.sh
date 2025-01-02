#!/system/bin/sh
case "$ARCH" in arm) BINARY=nfqws-arm;; arm64) BINARY=nfqws-aarch64;; x86) BINARY=nfqws-x86;; x86_64) BINARY=nfqws-x86_x64) esac
if [ -f "/data/adb/modules/zapret/$BINARY" ]; then
    mv "/data/adb/modules/zapret/$BINARY" "/data/adb/modules/zapret/nfqws"
    chmod 777 "/data/adb/modules/zapret/nfqws"
    rm -rf /data/adb/modules/zapret/nfqws-*
    if [ $(stat -c "%a" "/data/adb/modules/zapret/zapret.sh") != "777" ]; then
      chmod 777 "/data/adb/modules/zapret/zapret.sh"
    fi
fi
su -c "/data/adb/modules/zapret/zapret.sh"
