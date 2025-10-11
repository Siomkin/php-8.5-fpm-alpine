FROM php:8.5.0RC2-fpm-alpine

ARG TZ=UTC
ARG INSTALL_XDEBUG=false

ENV TZ=${TZ}

# Add a non-root user
RUN addgroup -g 1000 www && \
    adduser -u 1000 -G www -s /bin/sh -D www

# Set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install PHP extension installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install system dependencies, PHP extensions, and clean up in a single layer
RUN apk add --no-cache \
        mariadb-client \
        ca-certificates \
        postgresql-client \
        libssh2 \
        zip \
        libzip \
        libxml2 \
        jpegoptim \
        optipng \
        pngquant \
        gifsicle \
        libxslt \
        rabbitmq-c \
        icu-libs \
        oniguruma \
        gmp \
        freetype \
        libjpeg-turbo \
        libpng \
        jpeg \
        libwebp \
        supervisor \
        bash \
        curl \
        unzip \
        git \
        fcgi \
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
        linux-headers \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions bcmath exif gd gmp intl mysqli pcntl pdo_mysql pdo_pgsql sockets xsl zip \
    && if [ "$INSTALL_XDEBUG" = "true" ]; then \
        curl -L https://xdebug.org/files/xdebug-3.5.0alpha2.tgz | tar -xz && \
        cd xdebug-3.5.0alpha2 && \
        phpize && \
        ./configure --enable-xdebug && \
        make && \
        make install && \
        cd .. && \
        rm -rf xdebug-3.5.0alpha2 && \
        docker-php-ext-enable xdebug; \
       fi \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

WORKDIR /var/www

# Switch to non-root user
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000

HEALTHCHECK --interval=5m --timeout=3s \
  CMD SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -connect 127.0.0.1:9000 || exit 1

CMD ["php-fpm"]
