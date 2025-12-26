# Qt6 for webOS (HP TouchPad) - Build Notes

## Target Device
- HP TouchPad running webOS 3.0.5
- Kernel 2.6.35 (old, requires special handling)
- ARMv7 Cortex-A8, **soft-float ABI required**

## Current Status: BLOCKED - Toolchain Compatibility

Qt6 6.6.3 was successfully built with soft-float ABI, but **cannot run on webOS** due to a glibc/kernel incompatibility.

### The Problem

| Requirement | Constraint |
|-------------|------------|
| Qt6 needs `<charconv>` | Requires GCC 8+ |
| GCC 8+ toolchains | Ship with glibc requiring kernel 3.2+ |
| Old glibc (2.17) | Can't be built with GCC 13 (too new) |
| webOS kernel | 2.6.35 (needs glibc with kernel 2.6.x support) |

The GCC 13 toolchain's glibc 2.35 has `ABI: 3.2.0` (requires kernel 3.2.0+).
When run on webOS kernel 2.6.35, syscalls fail with "Invalid argument".

### What Works
- Qt5 apps work using `com.nizovn.glibc` package (glibc 2.19 with `ABI: 2.6.16`)
- The Qt5 glibc was built with `--enable-kernel=2.6.16`

### Solution Needed
Build a custom toolchain with **crosstool-ng** containing:
- GCC 8 or 9 (has `<charconv>`, can build older glibc)
- glibc 2.17 with `--enable-kernel=2.6.16`
- ARM soft-float ABI

## What Was Accomplished

### 1. Qt6 Soft-Float Build (Compiles, but glibc incompatible)
- Location: `qt6-softfloat-install/`
- Built with GCC 13 soft-float toolchain
- All libraries have correct ABI: `0x5000200, soft-float ABI`
- **Issue**: Linked against glibc 2.35 which requires kernel 3.2+

### 2. EGL Stubs Fixed
- Location: `webos-egl-stubs/`
- Added SONAME to `libEGL.so` and `libGLESv2.so` using patchelf
- Fixed absolute path embedding issue in Qt6 libraries

### 3. Test Application
- Source: `qt6-hello-world/`
- Built binary: `qt6-hello-softfloat-build/qt6-hello-world`
- Soft-float ABI verified

### 4. Package Build Script
- Script: `build-qt6-packages.sh`
- Creates IPK packages for deployment
- **Note**: Packages won't work until glibc issue is resolved

## Key Files

### Toolchain Files
- `toolchain-webos-armv7-softfloat-gcc13.cmake` - GCC 13 soft-float (current)
- `toolchain-webos-hybrid.cmake` - Attempted hybrid (didn't work)

### Build Scripts
- `build-qt6-softfloat.sh` - Qt6 build with GCC 13
- `build-qt6-packages.sh` - IPK package creation

### Source Patches Applied
- `qtdeclarative/src/3rdparty/masm/wtf/OSAllocatorPosix.cpp:32`
  - Added `#include <linux/limits.h>` for PATH_MAX

## Directory Structure

```
Qt-webOS/
├── qt6-src/                    # Qt6 6.6.3 source
├── qt6-host/                   # Host Qt6 tools for cross-compilation
├── qt6-softfloat-install/      # Built Qt6 (soft-float, glibc 2.35)
├── qt6-hello-world/            # Test app source
├── qt6-hello-softfloat-build/  # Built test app
├── QT6-packages/               # Generated IPK packages
├── QT5-unpacked/               # Reference Qt5 packages (working glibc)
├── webos-egl-stubs/            # EGL/GLESv2 stubs with SONAMEs
├── webos-softfloat-sysroot/    # GCC 13's glibc (kernel 3.2+ required)
├── rebuilt-libs/               # Rebuilt SDL library
├── gawk-install/               # gawk 5.2.2 (for building glibc)
├── toolchain-*.cmake           # CMake toolchain files
└── build-*.sh                  # Build scripts
```

## Qt5 Reference (Working)

The working Qt5 deployment uses:
- Package: `com.nizovn.glibc` (glibc 2.19, `ABI: 2.6.16`)
- Dynamic linker: `$GLIBC/ld.so`
- libstdc++.so.6.0.19 (GCC 4.8)
- libatomic.so.1

## Next Steps for Contributors

1. **Build custom toolchain** using crosstool-ng:
   ```
   ct-ng arm-unknown-linux-gnueabi
   # Configure: GCC 8/9, glibc 2.17, --enable-kernel=2.6.16, soft-float
   ct-ng build
   ```

2. **Rebuild Qt6** with the custom toolchain

3. **Test on device** to verify glibc compatibility

## Deployment Notes

- Use `palm-install` for package deployment
- Transfer files: `novacom put file:///media/internal/filename < localfile`
- Test location: `/media/cryptofs/apps/usr/palm/applications/`

## References

- [Bootlin Toolchains](https://toolchains.bootlin.com/) - Prebuilt toolchains
- [crosstool-ng](https://crosstool-ng.github.io/) - Custom toolchain builder
- Qt5 working glibc in `QT5-unpacked/com.nizovn.glibc_4.8-2015.06-0_armv7/`
