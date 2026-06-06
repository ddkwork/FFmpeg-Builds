#!/bin/bash

FFBUILD_MERGED=1

package_variant() {
    IN="$1"
    OUT="$2"

    # Only package the merged library + headers
    mkdir -p "$OUT"/lib
    cp "$IN"/lib/libffmpeg.so "$OUT"/lib/

    mkdir -p "$OUT"/include
    cp -r "$IN"/include/* "$OUT"/include

    mkdir -p "$OUT"/doc
    cp -r "$IN"/share/doc/ffmpeg/* "$OUT"/doc 2>/dev/null || true

    mkdir -p "$OUT"/presets
    cp "$IN"/share/ffmpeg/*.ffpreset "$OUT"/presets 2>/dev/null || true
}