#!/bin/bash
# Build Qt6 with HYBRID toolchain:
# - GCC 13 compiler (C++17 <charconv> support)
# - glibc 2.19 sysroot (kernel 2.6.x compatible)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QT6_SRC="$SCRIPT_DIR/qt6-src/qt-everywhere-src-6.6.3"
BUILD_DIR="$SCRIPT_DIR/qt6-hybrid-build"
INSTALL_DIR="$SCRIPT_DIR/qt6-hybrid-install"
HOST_DIR="$SCRIPT_DIR/qt6-host"
TOOLCHAIN_FILE="$SCRIPT_DIR/toolchain-webos-hybrid.cmake"

# GCC 13 for C++17 support
GCC13_TOOLCHAIN="$HOME/toolchains/arm-linux-gnueabi-gcc13"
export PATH="$GCC13_TOOLCHAIN/bin:$PATH"

# Verify toolchain
if [ ! -x "$GCC13_TOOLCHAIN/bin/arm-linux-gnueabi-gcc" ]; then
    echo "ERROR: GCC 13 toolchain not found at $GCC13_TOOLCHAIN"
    exit 1
fi

echo "=== Qt6 HYBRID Build for webOS TouchPad ==="
echo "Compiler: GCC 13.0.0 (C++17 support)"
echo "Sysroot: glibc 2.19 (kernel 2.6.31 compatible)"
echo "Target ABI: soft-float"
echo ""

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Configuring Qt6 with hybrid toolchain..."

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
echo "Configuration complete. Building with $(nproc) cores..."
cmake --build . --parallel $(nproc)

echo ""
echo "Installing..."
cmake --install .

echo ""
echo "=== Build Complete ==="
echo "Qt6 installed to: $INSTALL_DIR"
echo ""
echo "Verifying ABI and glibc requirements..."
for lib in "$INSTALL_DIR/lib/libQt6Core.so" "$INSTALL_DIR/lib/libQt6Gui.so"; do
    if [ -f "$lib" ]; then
        echo -n "$(basename $lib): "
        readelf -h "$lib" | grep "Flags:" | sed 's/.*Flags://'
        echo "  GLIBC versions needed:"
        readelf -V "$lib" 2>/dev/null | grep "GLIBC_" | sort -u | head -5
    fi
done
