#!/bin/sh
set -e

if [ -n "$TZ" ]; then
    echo "date.timezone=$TZ" > /usr/local/etc/php/conf.d/zz-timezone.ini
fi

exec "$@"
