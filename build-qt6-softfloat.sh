#!/bin/bash
# Build Qt6 with soft-float ABI for webOS TouchPad (kernel 2.6.35)
# Uses Linaro soft-float toolchain with glibc 2.25

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QT6_SRC="$SCRIPT_DIR/qt6-src/qt-everywhere-src-6.6.3"
BUILD_DIR="$SCRIPT_DIR/qt6-softfloat-build"
INSTALL_DIR="$SCRIPT_DIR/qt6-softfloat-install"
HOST_DIR="$SCRIPT_DIR/qt6-host"
TOOLCHAIN_FILE="$SCRIPT_DIR/toolchain-webos-armv7-softfloat-gcc13.cmake"

# GCC 13 soft-float toolchain (has <charconv> header required by Qt6)
GCC13_TOOLCHAIN="$HOME/toolchains/arm-linux-gnueabi-gcc13"
export PATH="$GCC13_TOOLCHAIN/bin:$PATH"

# Verify toolchain
if [ ! -x "$GCC13_TOOLCHAIN/bin/arm-linux-gnueabi-gcc" ]; then
    echo "ERROR: GCC 13 soft-float toolchain not found at $GCC13_TOOLCHAIN"
    exit 1
fi

echo "=== Qt6 Soft-Float Build for webOS TouchPad ==="
echo "Toolchain: GCC 13.0.0 (soft-float with C++17 charconv)"
echo "Target ABI: soft-float (compatible with webOS 3.0.5)"
echo ""

# Verify toolchain produces soft-float binaries
echo "Verifying toolchain produces soft-float ABI..."
echo 'int main() { return 0; }' > /tmp/abi_test.c
arm-linux-gnueabi-gcc -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -o /tmp/abi_test /tmp/abi_test.c
ABI_CHECK=$(readelf -h /tmp/abi_test | grep "soft-float")
if [ -z "$ABI_CHECK" ]; then
    echo "ERROR: Toolchain does not produce soft-float binaries!"
    exit 1
fi
echo "OK: Toolchain verified for soft-float ABI"
rm -f /tmp/abi_test /tmp/abi_test.c
echo ""

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Configuring Qt6 with soft-float ABI..."
echo "This build INCLUDES QML support (qtdeclarative)"
echo ""

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
echo "Verifying ABI of built libraries..."
for lib in "$INSTALL_DIR/lib/libQt6Core.so" "$INSTALL_DIR/lib/libQt6Gui.so"; do
    if [ -f "$lib" ]; then
        echo -n "$(basename $lib): "
        readelf -h "$lib" | grep "Flags:" | sed 's/.*Flags://'
    fi
done
echo ""
echo "SUCCESS: Qt6 built with soft-float ABI for webOS TouchPad"
