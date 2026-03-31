#!/bin/sh
set -e

if [ -n "$TZ" ]; then
    if printf '%s' "$TZ" | grep -Eq '^[A-Za-z0-9_./+-]+$'; then
        echo "date.timezone=$TZ" > /usr/local/etc/php/conf.d/zz-timezone.ini
    else
        echo "Warning: invalid TZ value '$TZ', ignoring" >&2
    fi
fi

exec "$@"
