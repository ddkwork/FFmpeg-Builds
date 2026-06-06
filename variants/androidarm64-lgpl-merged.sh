#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/linux-install-merged.sh
source "$(dirname "$BASH_SOURCE")"/defaults-lgpl-merged.sh
FF_CONFIGURE+=" --target-os=android --arch=aarch64"