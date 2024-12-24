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
      ui_print "! Device Architecture: $ARCH"
      abort
      ;;
  esac

  if [ -n "$API" ]; then
    ui_print "- Device Android API: $API"
    if [ "$API" -lt 27 ]; then
      ui_print "! Device Android API: required 27 (Android 7.1)"
      abort
    fi
  else
    ui_print "! Device Android API: Error"
    exit 1
  fi

  if which busybox > /dev/null 2>&1; then
    ui_print "- Busybox: Installed"
  else
    ui_print "! Busybox: Not found"
    abort
  fi
}

check_requirements

install_module() {
  MODULE_UPDATE_DIR="/data/adb/modules_update/zapret"
  MODULE_DIR="/data/adb/modules/zapret"
  pkill nfqws
  pkill zapret

  ui_print "- Device Architecture: $ARCH"
  mv "$MODULE_UPDATE_DIR/$BINARY" "$MODULE_DIR/nfqws"
  mv "$MODULE_DIR/$BINARY" "$MODULE_DIR/nfqws"
  rm -rf $MODULE_DIR/nfqws-*
  rm -rf $MODULE_UPDATE_DIR/nfqws-*

  if ls $MODULE_DIR/*.txt 1> /dev/null 2>&1; then
    cp $MODULE_DIR/*.txt $MODULE_UPDATE_DIR/
  fi

  sed -i 's/\r$//' "$MODULE_DIR/service.sh"
  sed -i 's/\r$//' "$MODULE_DIR/zapret-service"
  sed -i 's/\r$//' "$MODULE_DIR/uninstall.sh"
  
  ui_print "- Setting permissions"
  set_perm_recursive "$MODULE_DIR/*" 0 0 0755 0755
  set_perm_recursive "$MODULE_UPDATE_DIR/*" 0 0 0755 0755
  
  ui_print "*******************************************************"
  ui_print "-         sevcator.t.me / sevcator.github.io           "
  ui_print "- Please leave star on GitHub, if you like this module "
  ui_print "*******************************************************"
  ui_print "- Done"
}

install_module
exit 0
