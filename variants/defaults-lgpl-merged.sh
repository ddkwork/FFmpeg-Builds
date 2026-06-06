#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/defaults-lgpl.sh
FF_CONFIGURE+=" --disable-shared --enable-static"