# Building QT6

This project is an attempt to build QT6 for webOS TouchPads (armv7). So far, it hasn't succeeded.

Packages have been built, but ultimately QT6 apps cannot run.

We're stuck in a compatibility matrix:

  | Need                 | Constraint                            |
  |----------------------|---------------------------------------|
  | Qt6 needs <charconv> | Requires GCC 8+                       |
  | GCC 8+ toolchains    | Ship with glibc requiring kernel 3.2+ |
  | Old glibc (2.17)     | Can't be built with GCC 13            |
  | Touchpad             | Has kernel 2.6.35                     |

  The only real solution is to build a custom toolchain with crosstool-ng:
  - GCC 8 or 9 (has <charconv>, can build old glibc)
  - glibc 2.17 with --enable-kernel=2.6.16
  - ARM soft-float

  This requires installing crosstool-ng and building a complete toolchain. It's the only proper path forward - there's no shortcut around this compatibility matrix.

# Alternatives

An alternative may be building QT5.15. A prompt to kick off that effort is in PROMPT-qt515-build.md

Qt 5.15 is much more achievable than Qt6 was. Here's why:

  Why Qt6 failed:
  - Qt6 requires C++17 → needs GCC 8+
  - GCC 8+ bundles glibc 2.28+ → requires kernel 3.2.0+
  - webOS has kernel 2.6.35 → incompatible

  Why Qt 5.15 should work:

  | Version | C++ Requirement | Minimum GCC |
  |---------|-----------------|-------------|
  | Qt 5.9  | C++11           | GCC 4.7     |
  | Qt 5.12 | C++11           | GCC 4.8     |
  | Qt 5.15 | C++11           | GCC 5.0     |

  Qt 5.15 only needs C++11, which means:
  - Can use older GCC (5.x or even 4.9)
  - Older GCC comes with older glibc (2.19-2.23)
  - Older glibc supports kernel 2.6.x

  The path forward:
  1. Use the same toolchain/glibc that built Qt 5.9.7 (the one that's currently working)
  2. Download Qt 5.15.x source
  3. Cross-compile with the existing soft-float toolchain
  4. Package with the existing com.nizovn.glibc (glibc 2.19)

  The toolchain that built your working Qt 5.9.7 should build Qt 5.15 with minimal changes. You'd get:
  - Qt Quick 2 improvements
  - Better QML engine
  - Bug fixes through 2023 (LTS)
  - No glibc/kernel compatibility hell
