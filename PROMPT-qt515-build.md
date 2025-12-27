# Qt 5.15 Build for webOS TouchPad - Project Prompt

## Goal
Cross-compile Qt 5.15.x for the HP TouchPad running webOS 3.0.5.

## Target Device Constraints

- **Kernel**: 2.6.35 (very old, limits glibc options)
- **CPU**: ARMv7 Qualcomm Scorpion (Cortex-A8 compatible)
- **ABI**: **MUST be soft-float** (`-mfloat-abi=softfp`)
- **Filesystem**: cryptofs doesn't support symlinks - use hard copies in packages

## Why This Should Work (Unlike Qt6)

Qt 5.15 only requires C++11 (not C++17), so it can be built with older GCC versions that come with older glibc that supports kernel 2.6.x. Qt6 required C++17 → GCC 8+ → glibc 2.28+ → kernel 3.2.0+ minimum, which was incompatible.

## Working Reference: Qt 5.9.7

A working Qt5 installation exists on the device:
- Package: `com.nizovn.qt5`
- glibc: `com.nizovn.glibc` (glibc 2.19, soft-float, kernel 2.6.16 compatible)
- Install path: `/media/cryptofs/apps/usr/palm/applications/`

The toolchain that built Qt 5.9.7 should also build Qt 5.15.

## Critical Lessons Learned

### 1. ABI Verification
Always verify soft-float ABI with:
```bash
readelf -h libQt5Core.so | grep Flags
# Must show: Flags: 0x5000200  (soft-float)
# NOT:       Flags: 0x5000400  (hard-float) ← WRONG
```

### 2. glibc Kernel Compatibility
Check glibc's minimum kernel requirement:
```bash
readelf -n libc.so.6 | grep -A1 "ABI:"
# Should show: ABI: 2.6.16 or similar
# NOT:         ABI: 3.2.0 ← incompatible with webOS kernel
```

### 3. EGL/OpenGL ES Stubs
Qt needs EGL headers for cross-compilation. We created stub libraries at:
`~/Projects/Qt-webOS/webos-egl-stubs/`

**IMPORTANT**: Stub libraries MUST have SONAME set, otherwise absolute build paths get baked into binaries:
```bash
patchelf --set-soname libEGL.so libEGL.so
patchelf --set-soname libGLESv2.so libGLESv2.so
```

### 4. OpenGL ES Headers
Use PalmPDK headers: `/opt/PalmPDK/include/GLES2/`

### 5. SDL Library
The device's original SDL has issues. Use rebuilt version:
`~/Projects/Qt-webOS/rebuilt-libs/libSDL-1.2.so.0.11.2`

### 6. Package Deployment
- Use `palm-install` for deployment (handles cryptofs correctly)
- Transfer large files via: `novacom put file:///media/internal/filename < localfile`
- Don't use `/` for storage - root partition is tiny, use `/media/internal/`

### 7. Dynamic Linker
For soft-float glibc, the dynamic linker is `ld-linux.so.3` (NOT `ld-linux-armhf.so.3`).

### 8. Runtime Environment
Apps need to use the bundled glibc's dynamic linker:
```bash
exec "$GLIBC_PATH/ld-linux.so.3" \
    --library-path "$GLIBC_PATH:$QT_PATH/lib:$QT_PATH/plugins/platforms" \
    "$APP_BINARY"
```

## Toolchain Requirements

The toolchain must have:
- GCC 5.x or similar (C++11 support, NOT GCC 8+ which brings new glibc)
- Configured for `arm-linux-gnueabi` (soft-float)
- glibc 2.19 or similar with `--enable-kernel=2.6.16`

**Check existing toolchain location** - likely the one used for Qt 5.9.7 build. Search in:
- `~/toolchains/`
- `~/Projects/qupzilla/toolchains/` (Linaro toolchains found here previously)

## Recommended Build Steps

1. **Verify/locate the Qt 5.9.7 build toolchain**
2. **Download Qt 5.15.x source** (use offline installer or git)
3. **Create CMake/qmake toolchain file** with soft-float flags
4. **Configure Qt 5.15** with similar options to Qt 5.9.7, skipping unneeded modules
5. **Build and verify ABI** with readelf
6. **Package** using existing `build-qt6-packages.sh` as template (rename appropriately)
7. **Test on device**

## Files in This Project

- `build-qt6-packages.sh` - Package builder (adapt for Qt5.15)
- `toolchain-webos-armv7-softfloat.cmake` - CMake toolchain (may need adaptation)
- `webos-egl-stubs/` - EGL headers and stub libraries
- `rebuilt-libs/` - Fixed SDL library
- `webos-device-libs/` - Device libraries (libnapp.so, libpdl.so)
- `qt6-hello-world/` - Test app (works for Qt5 with minor changes)

## Qt 5.15 Configure Options (Starting Point)

```bash
./configure \
    -prefix /usr/palm/applications/com.nizovn.qt5 \
    -extprefix "$INSTALL_DIR" \
    -release \
    -opensource -confirm-license \
    -xplatform linux-arm-gnueabi-g++ \
    -opengl es2 \
    -no-openssl \
    -nomake examples \
    -nomake tests \
    -skip qt3d \
    -skip qtwebengine \
    -skip qtwayland \
    -skip qtmultimedia \
    -skip qtlocation \
    -skip qtsensors \
    -skip qtconnectivity \
    -skip qtserialport \
    -skip qtwebchannel \
    -skip qtwebsockets \
    -skip qtwebview
```

## Success Criteria

1. `readelf -h libQt5Core.so` shows `soft-float ABI`
2. `readelf -n` on glibc shows kernel ABI 2.6.x
3. Test app launches without "Invalid argument" or segfault
4. QML rendering works (possibly with `QMLSCENE_DEVICE=softwarecontext`)
