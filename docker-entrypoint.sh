#!/bin/sh
set -e

if [ -n "$TZ" ]; then
    if printf '%s' "$TZ" | grep -Eq '^[A-Za-z0-9_./+-]+$'; then
        echo "date.timezone=$TZ" > /usr/local/etc/php/conf.d/zz-timezone.ini 2>/dev/null || true
    else
        echo "Warning: invalid TZ value '$TZ', ignoring" >&2
    fi
fi

# Replicate docker-php-entrypoint flag handling
if [ "${1#-}" != "$1" ]; then
    set -- php-fpm "$@"
fi

exec "$@"
