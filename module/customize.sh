#!/sbin/sh

umask 022

ui_print() {
  echo "$1"
}

check_requirements() {
  case "$ARCH" in
    arm)
      BINARY_PATH=$MODPATH/nfqws-arm
      ;;
    arm64)
      BINARY_PATH=$MODPATH/nfqws-aarch64
      ;;
    x86)
      BINARY_PATH=$MODPATH/nfqws-x86
      ;;
    x86_64)
      BINARY_PATH=$MODPATH/nfqws-x86_x64
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
  MODULE_DIR="/data/adb/modules/zapret"
  MODULE_UPDATE_DIR="/data/adb/modules_update/zapret"
  SERVICE_DIR="/data/adb/service.d"

  ui_print "- Killing processes"
  pkill nfqws
  pkill zapret

  ui_print "- Copying nfqws for $ARCH"
  mv "$BINARY_PATH" "$MODPATH/nfqws"

  ui_print "- Remove binaries for another processors"
  rm -rf nfqws-*
  
  if [ -f "$MODULE_DIR/zapret.sh" ]; then
    mv "$MODULE_DIR/zapret.sh" "$SERVICE_DIR/zapret.sh"
    ui_print "- zapret.sh moved to $SERVICE_DIR/"
  fi

  if [ -f "$MODULE_UPDATE_DIR/zapret.sh" ]; then
    mv "$MODULE_UPDATE_DIR/zapret.sh" "$SERVICE_DIR/zapret.sh"
    ui_print "- zapret.sh moved to $SERVICE_DIR/"
  fi

  if [ ! -f "$SERVICE_DIR/zapret.sh" ]; then
    ui_print "! zapret.sh not found in $SERVICE_DIR"
    abort
  fi

  ui_print "- Fixing scripts"
  sed -i 's/\r$//' "$SERVICE_DIR/zapret.sh"

  ui_print "- Setting permissions"
  chmod 755 "$MODULE_DIR"/*
  chmod 755 "$SERVICE_DIR/zapret.sh"

  ui_print "************************************"
  ui_print "- sevcator.t.me / sevcator.github.io"
  ui_print "************************************"
  ui_print "- Done"
}

install_module
exit 0
