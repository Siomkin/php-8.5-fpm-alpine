[![8.5-fpm-alpine Docker Image CI](https://github.com/Siomkin/php-8.5-fpm-alpine/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Siomkin/php-8.5-fpm-alpine/actions/workflows/docker-image.yml)

# PHP 8.5 FPM Alpine Docker Image

A lightweight Docker image based on Alpine Linux that includes PHP 8.5 FPM with common extensions and development tools.

## Features

- **PHP 8.5.0RC2** with FPM
- Alpine Linux based for minimal size
- Common PHP extensions pre-installed
- Xdebug support (currently disabled due to compatibility issues with PHP 8.5)
- Non-root user for security
- Health check endpoint

## Quick Start

```bash
# Pull the image
docker pull siomkin/8.5-fpm-alpine

# Run a container
docker run -d -p 9000:9000 --name php-app siomkin/8.5-fpm-alpine

# Test PHP version
docker exec php-app php -v
```

## Docker Hub

https://hub.docker.com/repository/docker/siomkin/8.5-fpm-alpine

## Build Locally

```bash
# Clone the repository
git clone https://github.com/Siomkin/php-8.5-fpm-alpine.git
cd php-8.5-fpm-alpine

# Build the image
docker build -t siomkin/8.5-fpm-alpine .

# Run with custom timezone
docker run -d -p 9000:9000 -e TZ=Europe/Moscow --name php-app siomkin/8.5-fpm-alpine

# Build without Xdebug
docker build --build-arg INSTALL_XDEBUG=false -t siomkin/8.5-fpm-alpine .
```

## PHP Extensions

The image includes the following PHP extensions:
- bcmath
- exif
- gd
- gmp
- intl
- mysqli
- pcntl
- pdo_mysql
- pdo_pgsql
- redis
- sockets
- xsl
- zip
- xdebug (optional)

## Configuration

### Build Arguments

- `TZ`: Timezone (default: UTC)
- `INSTALL_XDEBUG`: Install Xdebug extension (default: true)

### Environment Variables

- `TZ`: Set from build argument, affects container timezone

## Health Check

The image includes a health check that verifies PHP-FPM is running correctly:

```bash
docker ps  # Will show health status
```

## Security

- Runs as non-root user (www:1000)
- Minimal Alpine Linux base
- Regular security updates via automated builds

## License

MIT License

## PHP 8.5 Features

Learn about the new features and improvements in PHP 8.5 in our [PHP 8.5 Features Guide](./PHP-8.5-FEATURES.md).
