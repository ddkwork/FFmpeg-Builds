#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/windows-install-merged.sh
source "$(dirname "$BASH_SOURCE")"/defaults-lgpl.sh
FF_CONFIGURE+=" --disable-shared --enable-static --extra-ldflags='-static-libgcc -static-libstdc++'"