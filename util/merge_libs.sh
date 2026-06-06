#!/bin/bash
# Merge all FFmpeg static libraries into a single shared library
# This script runs inside the Docker container after FFmpeg make install
set -xe

PREFIX="$1"
TARGET="$2"

cd "$PREFIX/lib"

# Collect all FFmpeg static libs
FFMPEG_LIBS=""
for lib in libavfilter.a libavcodec.a libavdevice.a libavformat.a libswresample.a libswscale.a libpostproc.a libavutil.a; do
    if [ -f "$PREFIX/lib/$lib" ]; then
        FFMPEG_LIBS="$FFMPEG_LIBS $PREFIX/lib/$lib"
    fi
done

# Get all external dependency linker flags from FFmpeg pkg-config files
DEPS=""
for pc in "$PREFIX"/lib/pkgconfig/libav*.pc; do
    if [ -f "$pc" ]; then
        libname=$(basename "$pc" .pc)
        pkgdeps=$(pkg-config --libs --static "$libname" 2>/dev/null || true)
        DEPS="$DEPS $pkgdeps"
    fi
done

# Deduplicate and clean up deps - remove ffmpeg libs themselves from the dep list
DEPS=$(echo "$DEPS" | tr ' ' '\n' | \
    grep -v -- '-L/ffbuild' | \
    grep -v -- '-I/ffbuild' | \
    grep -v '^-l.*\(avcodec\|avformat\|avutil\|avdevice\|avfilter\|avresample\|swresample\|swscale\|postproc\|swresample\)$' | \
    grep -v '^$' | \
    sort -u | tr '\n' ' ')

# Platform-specific common libs
if [[ "$TARGET" == win* ]]; then
    DEPS="$DEPS -lm -lpthread -lz"
elif [[ "$TARGET" == android* ]]; then
    # Android: libdl and libpthread are in libc, -llog needed for Android logging
    DEPS="$DEPS -lm -lz -llog"
else
    DEPS="$DEPS -lm -lpthread -lz -ldl"
fi

# Use --start-group/--end-group to handle circular FFmpeg lib dependencies
FFMPEG_GROUP="-Wl,--start-group $FFMPEG_LIBS -Wl,--end-group"

if [[ "$TARGET" == win* ]]; then
    # Windows: create ffmpeg.dll with import library
    echo "Creating merged DLL for Windows target..."
    $CC -shared -o "$PREFIX/bin/ffmpeg.dll" \
        $FFMPEG_GROUP \
        $DEPS \
        -Wl,--export-all-symbols \
        -Wl,--output-def,"$PREFIX/lib/ffmpeg.def" \
        -Wl,--out-implib,"$PREFIX/lib/libffmpeg.dll.a" \
        -static-libgcc -static-libstdc++

    echo "Merged library created: $PREFIX/bin/ffmpeg.dll"
    echo "Import lib: $PREFIX/lib/libffmpeg.dll.a"
    echo "DEF file: $PREFIX/lib/ffmpeg.def"
elif [[ "$TARGET" == android* ]]; then
    # Android: create libffmpeg.so
    echo "Creating merged .so for Android target..."
    $CC -shared -o "$PREFIX/lib/libffmpeg.so" \
        $FFMPEG_GROUP \
        $DEPS \
        -Wl,-soname,libffmpeg.so \
        -fPIC

    # Strip to reduce size
    if command -v llvm-strip &>/dev/null; then
        llvm-strip "$PREFIX/lib/libffmpeg.so"
    fi
    echo "Merged library created: $PREFIX/lib/libffmpeg.so"
    ls -lh "$PREFIX/lib/libffmpeg.so"
else
    # Linux: create libffmpeg.so
    echo "Creating merged .so for Linux target..."
    $CC -shared -o "$PREFIX/lib/libffmpeg.so" \
        $FFMPEG_GROUP \
        $DEPS \
        -Wl,-soname,libffmpeg.so \
        -fPIC

    echo "Merged library created: $PREFIX/lib/libffmpeg.so"
    ls -lh "$PREFIX/lib/libffmpeg.so"
fi
