# CMake toolchain file for cross-compiling Qt6 to webOS on HP TouchPad
# HYBRID: GCC 13 compiler (C++17) + glibc 2.19 sysroot (kernel 2.6.x compatible)

cmake_minimum_required(VERSION 3.16)

# Target system
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# GCC 13 toolchain for C++17 support
set(GCC13_TOOLCHAIN "$ENV{HOME}/toolchains/arm-linux-gnueabi-gcc13")

# glibc 2.19 sysroot (kernel 2.6.31 compatible) from Linaro
set(LINARO_SYSROOT "$ENV{HOME}/Projects/qupzilla/toolchains/gcc-linaro/arm-linux-gnueabi/libc")

# Compilers from GCC 13
set(CMAKE_C_COMPILER "${GCC13_TOOLCHAIN}/bin/arm-linux-gnueabi-gcc")
set(CMAKE_CXX_COMPILER "${GCC13_TOOLCHAIN}/bin/arm-linux-gnueabi-g++")
set(CMAKE_ASM_COMPILER "${GCC13_TOOLCHAIN}/bin/arm-linux-gnueabi-gcc")
set(CMAKE_AR "${GCC13_TOOLCHAIN}/bin/arm-linux-gnueabi-ar")
set(CMAKE_RANLIB "${GCC13_TOOLCHAIN}/bin/arm-linux-gnueabi-ranlib")
set(CMAKE_STRIP "${GCC13_TOOLCHAIN}/bin/arm-linux-gnueabi-strip")
set(CMAKE_NM "${GCC13_TOOLCHAIN}/bin/arm-linux-gnueabi-nm")
set(CMAKE_OBJCOPY "${GCC13_TOOLCHAIN}/bin/arm-linux-gnueabi-objcopy")
set(CMAKE_OBJDUMP "${GCC13_TOOLCHAIN}/bin/arm-linux-gnueabi-objdump")
set(CMAKE_LINKER "${GCC13_TOOLCHAIN}/bin/arm-linux-gnueabi-ld")

# Use the Linaro sysroot for glibc 2.19 headers and libraries
set(CMAKE_SYSROOT "${LINARO_SYSROOT}")

# Search paths for CMake find_* commands
set(CMAKE_FIND_ROOT_PATH "${LINARO_SYSROOT}")

# Compiler flags for webOS/HP TouchPad (ARMv7-A, Scorpion core)
# Using soft-float ABI (-mfloat-abi=softfp) for webOS compatibility
set(WEBOS_COMPILER_FLAGS "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -mtune=cortex-a8")
set(WEBOS_COMPILER_FLAGS "${WEBOS_COMPILER_FLAGS} -O2 -fno-omit-frame-pointer -D_GNU_SOURCE")
# Tell GCC 13 to use the Linaro sysroot's headers and libs
set(WEBOS_COMPILER_FLAGS "${WEBOS_COMPILER_FLAGS} --sysroot=${LINARO_SYSROOT}")

set(CMAKE_C_FLAGS_INIT "${WEBOS_COMPILER_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT "${WEBOS_COMPILER_FLAGS}")
set(CMAKE_ASM_FLAGS_INIT "${WEBOS_COMPILER_FLAGS}")

# Linker flags - use the Linaro sysroot
set(CMAKE_EXE_LINKER_FLAGS_INIT "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed --sysroot=${LINARO_SYSROOT}")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed --sysroot=${LINARO_SYSROOT}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed --sysroot=${LINARO_SYSROOT}")

# Don't look in the host system for programs
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Look in the target sysroot for libraries and headers
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# OpenGL ES configuration - use PalmPDK headers and device libraries
set(FEATURE_opengles2 ON)
set(FEATURE_opengles3 OFF)
set(FEATURE_opengl OFF)

# EGL stub headers and library
set(WEBOS_EGL_STUBS "$ENV{HOME}/Projects/Qt-webOS/webos-egl-stubs")

# PalmPDK paths for OpenGL ES, with our EGL stubs
set(OPENGL_INCLUDE_DIR "/opt/PalmPDK/include")
set(OPENGL_EGL_INCLUDE_DIR "${WEBOS_EGL_STUBS}")
set(EGL_INCLUDE_DIR "${WEBOS_EGL_STUBS}")
set(EGL_LIBRARY "${WEBOS_EGL_STUBS}/libEGL.so")
set(GLESv2_LIBRARY "${WEBOS_EGL_STUBS}/libGLESv2.so")
set(GLESv2_INCLUDE_DIR "/opt/PalmPDK/include")
list(APPEND CMAKE_FIND_ROOT_PATH "/opt/PalmPDK/device" "${WEBOS_EGL_STUBS}")

# Qt-specific settings
set(QT_COMPILER_FLAGS "${WEBOS_COMPILER_FLAGS}")
set(QT_LINKER_FLAGS "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed")

# pkg-config settings
set(PKG_CONFIG_EXECUTABLE "/usr/bin/pkg-config")
set(PKG_CONFIG_LIBDIR "${LINARO_SYSROOT}/usr/lib/pkgconfig:${LINARO_SYSROOT}/usr/share/pkgconfig")

# Disable features not available on webOS
set(FEATURE_dbus OFF)
set(FEATURE_glib OFF)
