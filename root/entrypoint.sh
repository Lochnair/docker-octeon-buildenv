#!/bin/sh
PUID=${PUID:-1234}
PGID=${PGID:-1234}

usermod -u "$PUID" user
groupmod -g "$PGID" user

su-exec "user" env PATH="/opt/cross/bin:$PATH" "$@"
