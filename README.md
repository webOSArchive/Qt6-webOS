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