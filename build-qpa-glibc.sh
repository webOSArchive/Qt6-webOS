#!/bin/bash
# Build webOS QPA plugin with glibc toolchain

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/qt6-qpa-webos-plugin/build-glibc"
QT6_DIR="$SCRIPT_DIR/qt6-arm-glibc-custom-install"
TOOLCHAIN_FILE="$SCRIPT_DIR/toolchain-webos-armv7-glibc-custom.cmake"

# glibc toolchain (2018.07 bleeding-edge with GCC 8.1 and glibc 2.27)
export PATH="$HOME/toolchains/armv7-eabihf--glibc--bleeding-edge-2018.07-1/bin:$PATH"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Configuring webOS QPA plugin with glibc toolchain..."
# Temporarily use glibc CMakeLists
cp "$SCRIPT_DIR/qt6-qpa-webos-plugin/CMakeLists.txt" "$SCRIPT_DIR/qt6-qpa-webos-plugin/CMakeLists.txt.bak"
cp "$SCRIPT_DIR/qt6-qpa-webos-plugin/CMakeLists-glibc.txt" "$SCRIPT_DIR/qt6-qpa-webos-plugin/CMakeLists.txt"

"$QT6_DIR/bin/qt-cmake" -G Ninja \
    -DCMAKE_INSTALL_PREFIX="$QT6_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-D_GNU_SOURCE -I$SCRIPT_DIR/webos-egl-stubs -I/opt/PalmPDK/include" \
    -DCMAKE_CXX_FLAGS="-D_GNU_SOURCE -I$SCRIPT_DIR/webos-egl-stubs -I/opt/PalmPDK/include" \
    "$SCRIPT_DIR/qt6-qpa-webos-plugin"

# Restore original CMakeLists
mv "$SCRIPT_DIR/qt6-qpa-webos-plugin/CMakeLists.txt.bak" "$SCRIPT_DIR/qt6-qpa-webos-plugin/CMakeLists.txt"

echo ""
echo "Building..."
cmake --build . --parallel

echo ""
echo "Installing..."
cmake --install .

echo ""
echo "Done! Plugin installed to $QT6_DIR/plugins/platforms/"
