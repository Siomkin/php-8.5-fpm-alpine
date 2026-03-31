FROM php:8.5.4-fpm-alpine

ARG TZ=UTC
ARG INSTALL_XDEBUG=true

ENV TZ=${TZ}

# Install PHP extension installer with pinned version for reproducibility
ADD https://github.com/mlocati/docker-php-extension-installer/releases/download/2.10.8/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Add a non-root user
RUN addgroup -g 1000 www && \
    adduser -u 1000 -G www -s /bin/sh -D www

# Set default timezone and prepare writable ini for runtime TZ override
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && echo "date.timezone=$TZ" > /usr/local/etc/php/conf.d/zz-timezone.ini \
    && chown www:www /usr/local/etc/php/conf.d/zz-timezone.ini

# Install system dependencies and PHP extensions in a single layer
RUN apk add --no-cache --update \
        ca-certificates \
        curl \
        unzip \
        git \
        bash \
        fcgi \
        mariadb-client \
        postgresql-client \
        jpegoptim \
        optipng \
        pngquant \
        gifsicle \
        freetype \
        gmp \
        icu-libs \
        jpeg \
        libavif \
        libjpeg-turbo \
        libpng \
        libssh2 \
        libwebp \
        libxpm \
        libxslt \
        libxml2 \
        libzip \
        oniguruma \
        rabbitmq-c \
        zip \
        supervisor \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        postgresql-dev \
        libssh-dev \
        libzip-dev \
        libxml2-dev \
        libxslt-dev \
        rabbitmq-c-dev \
        icu-dev \
        oniguruma-dev \
        gmp-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        jpeg-dev \
        libwebp-dev \
        libavif-dev \
        linux-headers \
    && install-php-extensions bcmath exif gd gmp intl mysqli opcache pcntl pdo_mysql pdo_pgsql redis sockets xsl zip \
    && if [ "$INSTALL_XDEBUG" = "true" ]; then \
        install-php-extensions xdebug; \
    fi \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /var/www

# Switch to non-root user
USER www

EXPOSE 9000

HEALTHCHECK --interval=5m --timeout=3s \
  CMD SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -connect 127.0.0.1:9000 || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
