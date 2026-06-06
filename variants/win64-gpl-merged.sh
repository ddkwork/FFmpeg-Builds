#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/windows-install-merged.sh
source "$(dirname "$BASH_SOURCE")"/defaults-gpl-merged.sh
FF_CONFIGURE+=" --extra-ldflags='-static-libgcc -static-libstdc++'"