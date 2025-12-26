#!/bin/bash
# Build Qt6 with custom glibc 2.27 (built for kernel 2.6.16)
# Includes QML support for webOS TouchPad

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QT6_SRC="$SCRIPT_DIR/qt6-src/qt-everywhere-src-6.6.3"
BUILD_DIR="$SCRIPT_DIR/qt6-arm-glibc-custom-build"
INSTALL_DIR="$SCRIPT_DIR/qt6-arm-glibc-custom-install"
HOST_DIR="$SCRIPT_DIR/qt6-host"
TOOLCHAIN_FILE="$SCRIPT_DIR/toolchain-webos-armv7-glibc-custom.cmake"

# Use Bootlin toolchain for compilers (but our custom glibc for runtime)
export PATH="$HOME/toolchains/armv7-eabihf--glibc--bleeding-edge-2018.07-1/bin:$PATH"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Configuring Qt6 with custom glibc 2.27 (kernel 2.6.16 support)..."
echo "This build INCLUDES QML support (qtdeclarative)"

"$QT6_SRC/configure" \
    -prefix /usr/palm/applications/com.nizovn.qt6 \
    -extprefix "$INSTALL_DIR" \
    -release \
    -opengl es2 \
    -no-feature-brotli \
    -nomake examples \
    -nomake tests \
    -skip qtwebengine \
    -skip qt3d \
    -skip qtmultimedia \
    -skip qtquickeffectmaker \
    -skip qtwayland \
    -skip qtquick3d \
    -skip qtgraphs \
    -skip qtdoc \
    -skip qtquick3dphysics \
    -skip qtspeech \
    -skip qtactiveqt \
    -skip qtconnectivity \
    -skip qtlocation \
    -skip qtsensors \
    -skip qtpositioning \
    -skip qtwebchannel \
    -skip qtwebsockets \
    -skip qtwebview \
    -skip qtvirtualkeyboard \
    -skip qthttpserver \
    -skip qtgrpc \
    -skip qtlottie \
    -skip qtmqtt \
    -skip qtscxml \
    -skip qtremoteobjects \
    -skip qtopcua \
    -skip qtcharts \
    -skip qtdatavis3d \
    -skip qt5compat \
    -skip qttools \
    -skip qtlanguageserver \
    -skip qttranslations \
    -qt-host-path "$HOST_DIR" \
    -- \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
    -DEGL_INCLUDE_DIR="$SCRIPT_DIR/webos-egl-stubs" \
    -DOPENGL_EGL_INCLUDE_DIR="$SCRIPT_DIR/webos-egl-stubs" \
    -DEGL_LIBRARY="$SCRIPT_DIR/webos-egl-stubs/libEGL.so" \
    -DGLESv2_LIBRARY="$SCRIPT_DIR/webos-egl-stubs/libGLESv2.so" \
    -DGLESv2_INCLUDE_DIR="/opt/PalmPDK/include" \
    -DCMAKE_C_FLAGS="-D_GNU_SOURCE -include $SCRIPT_DIR/webos-egl-stubs/KHR/khrplatform.h -I$SCRIPT_DIR/webos-egl-stubs -I/opt/PalmPDK/include" \
    -DCMAKE_CXX_FLAGS="-D_GNU_SOURCE -include $SCRIPT_DIR/webos-egl-stubs/KHR/khrplatform.h -I$SCRIPT_DIR/webos-egl-stubs -I/opt/PalmPDK/include" \
    -DQT_FEATURE_qmldom=OFF \
    -DQT_FEATURE_qmllanguageserver=OFF

echo ""
echo "Configuration complete. Building..."
cmake --build . --parallel 8

echo ""
echo "Installing..."
cmake --install .

echo ""
echo "Done! Qt6 installed to $INSTALL_DIR"
