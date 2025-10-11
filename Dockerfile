FROM php:8.5.0RC2-fpm-alpine

ARG TZ=UTC

ENV TZ=${TZ}

# Install PHP extension installer early for better caching
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Add a non-root user
RUN addgroup -g 1000 www && \
    adduser -u 1000 -G www -s /bin/sh -D www

# Set timezone (stable configuration)
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install runtime dependencies (grouped for optimal layer caching)
RUN apk add --no-cache --update \
        # Core utilities
        ca-certificates \
        curl \
        unzip \
        git \
        bash \
        fcgi \
        # Database clients
        mariadb-client \
        postgresql-client \
        # Image processing tools
        jpegoptim \
        optipng \
        pngquant \
        gifsicle \
        # Runtime libraries (alphabetically sorted)
        freetype \
        gmp \
        icu-libs \
        jpeg \
        libjpeg-turbo \
        libpng \
        libssh2 \
        libwebp \
        libxslt \
        libxml2 \
        libzip \
        oniguruma \
        rabbitmq-c \
        zip \
        # Process management
        supervisor

# Install PHP extensions (layer 1 - stable extensions)
RUN apk add --no-cache --virtual .build-deps \
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
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

# Install Xdebug (layer 2 - separate for better caching)
RUN apk add --no-cache --virtual .xdebug-build-deps \
        $PHPIZE_DEPS \
        linux-headers \
        git \
    && git clone --depth 1 --branch 3.5.0alpha2 https://github.com/xdebug/xdebug.git \
    && cd xdebug \
    && phpize \
    && ./configure --enable-xdebug \
    && make \
    && make install \
    && cd .. \
    && rm -rf xdebug \
    && docker-php-ext-enable xdebug \
    && apk del .xdebug-build-deps \
    && rm -rf /var/cache/apk/*

WORKDIR /var/www

# Switch to non-root user
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000

HEALTHCHECK --interval=5m --timeout=3s \
  CMD SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -connect 127.0.0.1:9000 || exit 1

CMD ["php-fpm"]
