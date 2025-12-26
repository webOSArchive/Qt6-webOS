#!/bin/bash
# Build webOS IPK packages for Qt6
# Based on Qt5 package structure from QT5-unpacked folder
set -e

PKGDIR="~/Projects/Qt-webOS/QT6-packages"
# Soft-float glibc from GCC 13 toolchain (version 2.35)
SYSROOT="~/Projects/Qt-webOS/webos-softfloat-sysroot"
# Soft-float Qt6 build
QT6_BUILD="~/Projects/Qt-webOS/qt6-softfloat-install"
REBUILT_LIBS="~/Projects/Qt-webOS/rebuilt-libs"

echo "Creating package directory structure..."
rm -rf "$PKGDIR"
mkdir -p "$PKGDIR"

# ============================================
# Package 1: com.nizovn.glibc6 (soft-float glibc 2.35 for Qt6)
# Named differently to coexist with Qt5's com.nizovn.glibc
# ============================================
echo "Building com.nizovn.glibc6 package..."
GLIBC_PKG="$PKGDIR/com.nizovn.glibc6_2.35-0_armv7"
mkdir -p "$GLIBC_PKG/control"
mkdir -p "$GLIBC_PKG/data/usr/palm/applications/com.nizovn.glibc6/lib"

# Create control file
cat > "$GLIBC_PKG/control/control" << 'EOF'
Package: com.nizovn.glibc6
Version: 2.35-0
Architecture: armv7
Maintainer: codpoet
Description: Glibc 2.35 runtime libraries (soft-float) for Qt6
Section: System Utilities
Priority: optional
Depends:
Source: { "Feed":"WebOS Internals", "Type":"Library", "Category":"System Utilities", "Title":"Glibc 2.35 for Qt6", "FullDescription":"Soft-float glibc 2.35 from GCC 13 toolchain, required for Qt6 on webOS 3.0.5 (ARMv7 soft-float ABI). Coexists with Qt5 glibc." }
EOF

# Copy glibc libraries - NO error suppression so we can see failures
# GCC 13's glibc uses direct names like libc.so.6 (not libc-X.XX.so)
echo "Copying glibc libraries..."
cp -avL "$SYSROOT/lib/ld-linux.so.3" "$GLIBC_PKG/data/usr/palm/applications/com.nizovn.glibc6/lib/"
cp -avL "$SYSROOT/lib/libc.so.6" "$GLIBC_PKG/data/usr/palm/applications/com.nizovn.glibc6/lib/"
cp -avL "$SYSROOT/lib/libpthread.so.0" "$GLIBC_PKG/data/usr/palm/applications/com.nizovn.glibc6/lib/"
cp -avL "$SYSROOT/lib/libdl.so.2" "$GLIBC_PKG/data/usr/palm/applications/com.nizovn.glibc6/lib/"
cp -avL "$SYSROOT/lib/libm.so.6" "$GLIBC_PKG/data/usr/palm/applications/com.nizovn.glibc6/lib/"
cp -avL "$SYSROOT/lib/librt.so.1" "$GLIBC_PKG/data/usr/palm/applications/com.nizovn.glibc6/lib/"
cp -avL "$SYSROOT/lib/libgcc_s.so.1" "$GLIBC_PKG/data/usr/palm/applications/com.nizovn.glibc6/lib/"
cp -avL "$SYSROOT/lib/libstdc++.so.6.0.30" "$GLIBC_PKG/data/usr/palm/applications/com.nizovn.glibc6/lib/"
cp -avL "$SYSROOT/lib/libatomic.so.1.2.0" "$GLIBC_PKG/data/usr/palm/applications/com.nizovn.glibc6/lib/"

# Verify files were copied
echo "Verifying glibc6 lib contents:"
ls -la "$GLIBC_PKG/data/usr/palm/applications/com.nizovn.glibc6/lib/"

# Create HARD COPIES with standard names (webOS cryptofs doesn't support symlinks reliably)
# Note: ld-linux.so.3 is for soft-float, ld-linux-armhf.so.3 is for hard-float
# We keep the soft-float name
cd "$GLIBC_PKG/data/usr/palm/applications/com.nizovn.glibc6/lib"
cp -v libstdc++.so.6.0.30 libstdc++.so.6
cp -v libatomic.so.1.2.0 libatomic.so.1
# Also create ld.so symlink-equivalent for Qt5-style launcher compatibility
cp -v ld-linux.so.3 ld.so

# ============================================
# Package 2: com.nizovn.qt6qpaplugins (QPA platform plugins + SDL)
# ============================================
echo "Building com.nizovn.qt6qpaplugins package..."
QPA_PKG="$PKGDIR/com.nizovn.qt6qpaplugins_6.6.3-0_armv7"
mkdir -p "$QPA_PKG/control"
mkdir -p "$QPA_PKG/data/usr/palm/applications/com.nizovn.qt6qpaplugins/plugins/platforms"
mkdir -p "$QPA_PKG/data/usr/palm/applications/com.nizovn.qt6qpaplugins/lib"

# Create control file
cat > "$QPA_PKG/control/control" << 'EOF'
Package: com.nizovn.qt6qpaplugins
Version: 6.6.3-0
Architecture: armv7
Maintainer: codepoet
Description: Qt6 QPA platform plugins for webOS
Section: System Utilities
Priority: optional
Depends: com.nizovn.glibc6, com.nizovn.qt6
Source: { "Feed":"WebOS Internals", "Type":"Library", "Category":"System Utilities", "Title":"Qt6 QPA Plugins", "FullDescription":"Qt6 platform abstraction plugins including eglfs for webOS 3.0.5" }
EOF

# Copy QPA plugins - verbose, follow symlinks
echo "Copying QPA plugins..."
cp -avL "$QT6_BUILD/plugins/platforms/"* "$QPA_PKG/data/usr/palm/applications/com.nizovn.qt6qpaplugins/plugins/platforms/"

# Verify QPA plugins
echo "Verifying QPA plugins:"
ls -la "$QPA_PKG/data/usr/palm/applications/com.nizovn.qt6qpaplugins/plugins/platforms/"

# Copy rebuilt SDL library
if [ -e "$REBUILT_LIBS/libSDL-1.2.so.0.11.2" ]; then
    echo "Copying rebuilt SDL library..."
    cp -avL "$REBUILT_LIBS/libSDL-1.2.so.0.11.2" "$QPA_PKG/data/usr/palm/applications/com.nizovn.qt6qpaplugins/lib/"
    cd "$QPA_PKG/data/usr/palm/applications/com.nizovn.qt6qpaplugins/lib"
    # Create HARD COPIES instead of symlinks (webOS cryptofs doesn't support symlinks reliably)
    cp -v libSDL-1.2.so.0.11.2 libSDL-1.2.so.0
    cp -v libSDL-1.2.so.0.11.2 libSDL.so
    echo "Verifying SDL lib:"
    ls -la "$QPA_PKG/data/usr/palm/applications/com.nizovn.qt6qpaplugins/lib/"
else
    echo "WARNING: SDL library not found at $REBUILT_LIBS/libSDL-1.2.so.0.11.2"
fi

# ============================================
# Package 3: com.nizovn.qt6 (Qt6 core libraries)
# ============================================
echo "Building com.nizovn.qt6 package..."
QT6_PKG="$PKGDIR/com.nizovn.qt6_6.6.3-0_armv7"
mkdir -p "$QT6_PKG/control"
mkdir -p "$QT6_PKG/data/usr/palm/applications/com.nizovn.qt6/lib"
mkdir -p "$QT6_PKG/data/usr/palm/applications/com.nizovn.qt6/qml"

# Create control file
cat > "$QT6_PKG/control/control" << 'EOF'
Package: com.nizovn.qt6
Version: 6.6.3-0
Architecture: armv7
Maintainer: codepoet
Description: Qt6 runtime libraries
Section: System Utilities
Priority: optional
Depends: com.nizovn.glibc6
Source: { "Feed":"WebOS Internals", "Type":"Library", "Category":"System Utilities", "Title":"Qt6 Libraries", "FullDescription":"Qt 6.6.3 runtime libraries compiled for webOS 3.0.5 (ARM Cortex-A8)" }
EOF

# Copy Qt6 libraries - use -L to follow symlinks and copy actual content
echo "Copying Qt6 libraries..."
echo "Looking in: $QT6_BUILD/lib/"
ls "$QT6_BUILD/lib/"*.so.*.*.* 2>/dev/null | head -5 || echo "No .so.*.*.* files found!"

lib_count=0
for lib in "$QT6_BUILD/lib/"*.so.*.*.*; do
    if [ -e "$lib" ]; then
        # Use -L to dereference symlinks (copy actual file content)
        cp -avL "$lib" "$QT6_PKG/data/usr/palm/applications/com.nizovn.qt6/lib/"
        lib_count=$((lib_count + 1))
    fi
done
echo "Copied $lib_count Qt6 libraries"

# Verify Qt6 libs
echo "Verifying Qt6 libs (first 10):"
ls -la "$QT6_PKG/data/usr/palm/applications/com.nizovn.qt6/lib/" | head -15

# Create HARD COPIES instead of symlinks (webOS cryptofs doesn't support symlinks reliably)
cd "$QT6_PKG/data/usr/palm/applications/com.nizovn.qt6/lib"
for lib in *.so.*.*.*; do
    if [ -f "$lib" ]; then
        # Extract base name (e.g., libQt6Core from libQt6Core.so.6.6.3)
        base="${lib%.so.*.*.*}"
        # Create .so.6 copy
        cp -v "$lib" "${base}.so.6"
        # Create .so copy
        cp -v "$lib" "${base}.so"
    fi
done

# Copy QML modules if they exist
if [ -d "$QT6_BUILD/qml" ]; then
    echo "Copying QML modules..."
    cp -avL "$QT6_BUILD/qml/"* "$QT6_PKG/data/usr/palm/applications/com.nizovn.qt6/qml/"
    echo "Verifying QML modules:"
    ls -la "$QT6_PKG/data/usr/palm/applications/com.nizovn.qt6/qml/" | head -10
else
    echo "WARNING: No QML directory found at $QT6_BUILD/qml"
fi

# ============================================
# Package 4: com.nizovn.qt6test (Qt6 test application)
# ============================================
echo "Building com.nizovn.qt6test package..."
QT6TEST_PKG="$PKGDIR/com.nizovn.qt6test_1.0.0_armv7"
QT6TEST_APP="$QT6TEST_PKG/data/usr/palm/applications/com.nizovn.qt6test"

# Create directories if they don't exist
mkdir -p "$QT6TEST_PKG/control"
mkdir -p "$QT6TEST_APP"

# Create control file
cat > "$QT6TEST_PKG/control/control" << 'EOF'
Package: com.nizovn.qt6test
Version: 1.0.0
Architecture: armv7
Maintainer: codepoet
Description: Qt6 Test Application
Section: Applications
Priority: optional
Depends: com.nizovn.glibc6, com.nizovn.qt6, com.nizovn.qt6qpaplugins
Source: { "Feed":"WebOS Internals", "Type":"Application", "Category":"System Utilities", "Title":"Qt6 Test App", "FullDescription":"Simple Qt6 QML test application for webOS 3.0.5" }
EOF

# Create appinfo.json
cat > "$QT6TEST_APP/appinfo.json" << 'EOF'
{
    "id": "com.nizovn.qt6test",
    "version": "1.0.0",
    "vendor": "codepoet",
    "type": "pdk",
    "main": "run-qt6test.sh",
    "title": "Qt6 Test",
    "icon": "icon.png"
}
EOF

# Create launcher script
cat > "$QT6TEST_APP/run-qt6test.sh" << 'EOF'
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
EOF
chmod +x "$QT6TEST_APP/run-qt6test.sh"

# Copy the Qt6 test binary (soft-float build)
QT6_TEST_BIN="~/Projects/Qt-webOS/qt6-hello-softfloat-build/qt6-hello-world"
if [ -e "$QT6_TEST_BIN" ]; then
    echo "Copying Qt6 test binary..."
    cp -avL "$QT6_TEST_BIN" "$QT6TEST_APP/"
else
    echo "ERROR: Qt6 test binary not found at $QT6_TEST_BIN"
    exit 1
fi

# Create a simple placeholder icon (1x1 PNG)
# This is a minimal valid PNG file
printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f\x00\x00\x01\x01\x00\x05\x18\xd8N\x00\x00\x00\x00IEND\xaeB`\x82' > "$QT6TEST_APP/icon.png"

echo "Verifying qt6test app contents:"
ls -la "$QT6TEST_APP/"

# ============================================
# Build IPK packages
# ============================================
echo ""
echo "Building IPK files..."

for pkg_dir in "$PKGDIR"/com.nizovn.*_*_armv7; do
    pkg_name=$(basename "$pkg_dir")
    echo ""
    echo "=========================================="
    echo "Building $pkg_name.ipk..."
    echo "=========================================="

    cd "$pkg_dir"

    # Create debian-binary
    echo "2.0" > debian-binary

    # Create control.tar.gz with correct structure
    # The tarball should contain ./ entry, then ./control
    echo "Creating control.tar.gz..."
    cd control
    chmod 644 control
    tar --owner=root --group=root -czvf ../control.tar.gz ./
    cd ..

    # Verify control.tar.gz contents
    echo "Verifying control.tar.gz contents:"
    tar -tzvf control.tar.gz

    # Create data.tar.gz with correct structure
    # The tarball should contain ./ entry, then ./usr/palm/applications/...
    echo "Creating data.tar.gz..."
    cd data
    tar --owner=root --group=root -czvf ../data.tar.gz ./
    cd ..

    # Verify data.tar.gz contents (first 20 entries)
    echo "Verifying data.tar.gz contents (first 20 entries):"
    tar -tzvf data.tar.gz | head -20
    echo "... (total entries: $(tar -tzf data.tar.gz | wc -l))"

    # Create the IPK using ar
    ar rcs "$PKGDIR/$pkg_name.ipk" debian-binary control.tar.gz data.tar.gz

    echo "Created $pkg_name.ipk"
    ls -la "$PKGDIR/$pkg_name.ipk"
done

echo ""
echo "Done! IPK packages created in $PKGDIR:"
ls -la "$PKGDIR"/*.ipk

echo ""
echo "Install order:"
echo "1. palm-install $PKGDIR/com.nizovn.glibc6_2.27-0_armv7.ipk"
echo "2. palm-install $PKGDIR/com.nizovn.qt6_6.6.3-0_armv7.ipk"
echo "3. palm-install $PKGDIR/com.nizovn.qt6qpaplugins_6.6.3-0_armv7.ipk"
echo "4. palm-install $PKGDIR/com.nizovn.qt6test_1.0.0_armv7.ipk"
echo ""
echo "Note: com.nizovn.glibc6 coexists with Qt5's com.nizovn.glibc"
echo "To test: Launch 'Qt6 Test' from the launcher, or run:"
echo "  /media/cryptofs/apps/usr/palm/applications/com.nizovn.qt6test/run-qt6test.sh"
