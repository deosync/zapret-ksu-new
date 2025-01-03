#!/system/bin/sh
arch=$(uname -m)
case "$arch" in
    "x86_64")
        nfqws="nfqws-x86_64"
        ;;
    "i386"|"i686")
        nfqws="nfqws-x86"
        ;;
    "armv7l"|"arm")
        nfqws="nfqws-arm"
        ;;
    "aarch64")
        nfqws="nfqws-aarch64"
        ;;
    *)
        echo "Unknown arch: $arch"
        exit 1
        ;;
esac
BINARY=nfqws-aarch64
if [ -f "/data/adb/modules/zapret/$BINARY" ]; then
    mv "/data/adb/modules/zapret/$BINARY" "/data/adb/modules/zapret/nfqws"
    chmod 777 "/data/adb/modules/zapret/nfqws"
    rm -rf /data/adb/modules/zapret/nfqws-*
    if [ $(stat -c "%a" "/data/adb/modules/zapret/zapret.sh") != "777" ]; then
      chmod 777 "/data/adb/modules/zapret/zapret.sh"
    fi
fi
su -c "/data/adb/modules/zapret/zapret.sh"
