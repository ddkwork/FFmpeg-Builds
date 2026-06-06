#!/bin/bash

FFBUILD_MERGED=1

package_variant() {
    IN="$1"
    OUT="$2"

    # Package the merged DLL + import lib + .def + headers
    mkdir -p "$OUT"/bin
    cp "$IN"/bin/ffmpeg.dll "$OUT"/bin/

    mkdir -p "$OUT"/lib
    cp "$IN"/lib/libffmpeg.dll.a "$OUT"/lib/
    cp "$IN"/lib/ffmpeg.def "$OUT"/lib/

    mkdir -p "$OUT"/include
    cp -r "$IN"/include/* "$OUT"/include

    mkdir -p "$OUT"/doc
    cp -r "$IN"/share/doc/ffmpeg/* "$OUT"/doc 2>/dev/null || true

    mkdir -p "$OUT"/presets
    cp "$IN"/share/ffmpeg/*.ffpreset "$OUT"/presets 2>/dev/null || true
}