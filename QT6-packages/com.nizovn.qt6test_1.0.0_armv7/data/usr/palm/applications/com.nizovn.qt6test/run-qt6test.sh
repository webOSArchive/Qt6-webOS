#!/bin/sh
# Qt6 Test App Launcher
# Uses custom glibc and Qt6 libraries without polluting global environment

APPDIR="/media/cryptofs/apps/usr/palm/applications"
GLIBC6_LIB="$APPDIR/com.nizovn.glibc6/lib"
QT6_LIB="$APPDIR/com.nizovn.qt6/lib"
QPA_LIB="$APPDIR/com.nizovn.qt6qpaplugins/lib"
QPA_PLUGINS="$APPDIR/com.nizovn.qt6qpaplugins/plugins"
THISAPP="$APPDIR/com.nizovn.qt6test"

# Set library path inline (only affects this process, not the shell)
# Then exec the custom ld-linux with the app
LD_LIBRARY_PATH="$QT6_LIB:$QPA_LIB:$GLIBC6_LIB" \
QT_PLUGIN_PATH="$QPA_PLUGINS" \
QT_QPA_PLATFORM=eglfs \
exec "$GLIBC6_LIB/ld-linux.so.3" \
    "$THISAPP/qt6-hello-world"
