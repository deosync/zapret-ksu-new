#!/sbin/sh
# sevcator/zapret-magisk

umask 022

ui_print() {
  echo "$1"
}

check_requirements() {
  case "$ARCH" in
    arm)
      BINARY=nfqws-arm
      ;;
    arm64)
      BINARY=nfqws-aarch64
      ;;
    x86)
      BINARY=nfqws-x86
      ;;
    x86_64)
      BINARY=nfqws-x86_x64
      ;;
    *)
      ui_print "! Unsupported architecture: $ARCH"
      abort
      ;;
  esac

  if [ -n "$API" ]; then
    ui_print "- Device Android API is $API"
    if [ "$API" -lt 27 ]; then
      ui_print "! Minimal Android API level is required: 27 (Android 7.1)"
      abort
    fi
  else
    ui_print "! Unable to determine Android API level"
    exit 1
  fi

  if which busybox > /dev/null 2>&1; then
    ui_print "- The device has busybox installed"
  else
    ui_print "! busybox is not installed on the device!"
    abort
  fi
}

check_requirements

install_module() {
  MODULE_UPDATE_DIR="/data/adb/modules_update/zapret"
  
  ui_print "- Killing processes"
  pkill nfqws
  pkill zapret

  ui_print "- Copying nfqws for $ARCH"
  mv "$MODULE_UPDATE_DIR/$BINARY" "$MODPATH/nfqws"
  mv "$MODPATH/$BINARY" "$MODPATH/nfqws"

  ui_print "- Removing binaries for another processors"
  rm -rf "$MODPATH/nfqws-*"
  rm -rf "$MODULE_UPDATE_DIR/nfqws-*"

  if ls $MODPATH/*.txt 1> /dev/null 2>&1; then
    ui_print "- Copying txt in update dir"
    cp $MODPATH/*.txt $MODULE_UPDATE_DIR/
  fi

  ui_print "- Fixing scripts"
  sed -i 's/\r$//' "$MODPATH/service.sh"
  sed -i 's/\r$//' "$MODPATH/zapret-service"
  sed -i 's/\r$//' "$MODPATH/uninstall.sh"
  
  ui_print "- Setting permissions"
  chmod 755 "$MODPATH"/*
  chmod 755 "$SERVICE_DIR/zapret.sh"

  ui_print "*******************************************************"
  ui_print "-         sevcator.t.me / sevcator.github.io           "
  ui_print "- Please leave star on GitHub, if you like this module "
  ui_print "*******************************************************"
  ui_print "- Done"
}

install_module
exit 0
