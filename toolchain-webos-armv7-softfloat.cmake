# CMake toolchain file for cross-compiling Qt6 to webOS on HP TouchPad
# Uses soft-float ABI for compatibility with webOS 3.0.5 / kernel 2.6.35

cmake_minimum_required(VERSION 3.16)

# Target system
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Linaro soft-float toolchain (gnueabi = soft-float, gnueabihf = hard-float)
set(SOFTFLOAT_TOOLCHAIN "$ENV{HOME}/toolchains/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabi")
set(TOOLCHAIN_PREFIX "arm-linux-gnueabi")

# Compilers
set(CMAKE_C_COMPILER "${SOFTFLOAT_TOOLCHAIN}/bin/${TOOLCHAIN_PREFIX}-gcc")
set(CMAKE_CXX_COMPILER "${SOFTFLOAT_TOOLCHAIN}/bin/${TOOLCHAIN_PREFIX}-g++")
set(CMAKE_ASM_COMPILER "${SOFTFLOAT_TOOLCHAIN}/bin/${TOOLCHAIN_PREFIX}-gcc")
set(CMAKE_AR "${SOFTFLOAT_TOOLCHAIN}/bin/${TOOLCHAIN_PREFIX}-ar")
set(CMAKE_RANLIB "${SOFTFLOAT_TOOLCHAIN}/bin/${TOOLCHAIN_PREFIX}-ranlib")
set(CMAKE_STRIP "${SOFTFLOAT_TOOLCHAIN}/bin/${TOOLCHAIN_PREFIX}-strip")
set(CMAKE_LINKER "${SOFTFLOAT_TOOLCHAIN}/bin/${TOOLCHAIN_PREFIX}-ld")
set(CMAKE_NM "${SOFTFLOAT_TOOLCHAIN}/bin/${TOOLCHAIN_PREFIX}-nm")
set(CMAKE_OBJCOPY "${SOFTFLOAT_TOOLCHAIN}/bin/${TOOLCHAIN_PREFIX}-objcopy")
set(CMAKE_OBJDUMP "${SOFTFLOAT_TOOLCHAIN}/bin/${TOOLCHAIN_PREFIX}-objdump")

# Use the toolchain's sysroot (glibc 2.25, soft-float, LINUX_2.6 compatible)
set(CMAKE_SYSROOT "${SOFTFLOAT_TOOLCHAIN}/${TOOLCHAIN_PREFIX}/libc")

# Search paths
set(CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}")

# Compiler flags for webOS/HP TouchPad (ARMv7-A, Scorpion core)
# CRITICAL: Using soft-float ABI (-mfloat-abi=softfp)
# - softfp: Uses FPU for calculations but passes float args in integer registers
# - This is ABI-compatible with soft-float code while still using hardware FPU
set(WEBOS_COMPILER_FLAGS "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -mtune=cortex-a8")
set(WEBOS_COMPILER_FLAGS "${WEBOS_COMPILER_FLAGS} -O2 -fno-omit-frame-pointer -D_GNU_SOURCE")

set(CMAKE_C_FLAGS_INIT "${WEBOS_COMPILER_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT "${WEBOS_COMPILER_FLAGS}")
set(CMAKE_ASM_FLAGS_INIT "${WEBOS_COMPILER_FLAGS}")

# Linker flags
set(CMAKE_EXE_LINKER_FLAGS_INIT "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed")

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
set(PKG_CONFIG_LIBDIR "${CMAKE_SYSROOT}/usr/lib/pkgconfig:${CMAKE_SYSROOT}/usr/share/pkgconfig")

# Disable features not available on webOS
set(FEATURE_dbus OFF)
set(FEATURE_glib OFF)
