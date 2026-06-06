ARG GH_REPO=ghcr.io/btbn/ffmpeg-builds
FROM $GH_REPO/base:latest

# Install Android NDK
ENV ANDROID_NDK_VERSION=r27c
ENV ANDROID_NDK_HOME=/opt/android-ndk
ENV ANDROID_NDK_ROOT=${ANDROID_NDK_HOME}/android-ndk-${ANDROID_NDK_VERSION}
ENV API_LEVEL=24

RUN \
    curl -fsSL "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip" -o /tmp/ndk.zip && \
    mkdir -p "${ANDROID_NDK_HOME}" && \
    unzip -q /tmp/ndk.zip -d "${ANDROID_NDK_HOME}" && \
    rm -f /tmp/ndk.zip && \
    mkdir /opt/ffbuild

ENV FFBUILD_TOOLCHAIN=aarch64-linux-android
ENV NDK_TOOLCHAIN_DIR=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64

# The NDK's clang wrappers
ENV \
    PATH="${NDK_TOOLCHAIN_DIR}/bin:${PATH}" \
    FFBUILD_TARGET_FLAGS="--sysroot=${NDK_TOOLCHAIN_DIR}/sysroot --target-os=android --arch=aarch64 --cross-prefix=${FFBUILD_TOOLCHAIN}-" \
    FFBUILD_CROSS_PREFIX="${FFBUILD_TOOLCHAIN}-" \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_DESTDIR=/opt/ffdest \
    FFBUILD_DESTPREFIX=/opt/ffdest/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG=pkg-config \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig \
    PKG_CONFIG_SYSROOT_DIR="${NDK_TOOLCHAIN_DIR}/sysroot" \
    CC="${NDK_TOOLCHAIN_DIR}/bin/${FFBUILD_TOOLCHAIN}${API_LEVEL}-clang" \
    CXX="${NDK_TOOLCHAIN_DIR}/bin/${FFBUILD_TOOLCHAIN}${API_LEVEL}-clang++" \
    LD="${NDK_TOOLCHAIN_DIR}/bin/ld.lld" \
    AR="${NDK_TOOLCHAIN_DIR}/bin/llvm-ar" \
    RANLIB="${NDK_TOOLCHAIN_DIR}/bin/llvm-ranlib" \
    NM="${NDK_TOOLCHAIN_DIR}/bin/llvm-nm" \
    STRIP="${NDK_TOOLCHAIN_DIR}/bin/llvm-strip" \
    CFLAGS="-I/opt/ffbuild/include -O2 -pipe -fPIC -DPIC -D_FORTIFY_SOURCE=2" \
    CXXFLAGS="-I/opt/ffbuild/include -O2 -pipe -fPIC -DPIC -D_FORTIFY_SOURCE=2" \
    LDFLAGS="-L/opt/ffbuild/lib -O2 -pipe -fPIC" \
    STAGE_CFLAGS="-fvisibility=hidden -fno-semantic-interposition" \
    STAGE_CXXFLAGS="-fvisibility=hidden -fno-semantic-interposition"

ADD toolchain.cmake /toolchain.cmake
ADD cross.meson /cross.meson