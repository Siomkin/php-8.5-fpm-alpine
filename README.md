[![8.5-fpm-alpine Docker Image CI](https://github.com/Siomkin/php-8.5-fpm-alpine/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Siomkin/php-8.5-fpm-alpine/actions/workflows/docker-image.yml)

# PHP 8.5 FPM Alpine Docker Image

A lightweight Docker image based on Alpine Linux that includes PHP 8.5 FPM with common extensions and development tools.

## Features

- **PHP 8.5.4** with FPM
- Alpine Linux based for minimal size
- Common PHP extensions pre-installed (including OPcache and Redis)
- **Xdebug support** (optional, enabled by default in development images)
- **Separate production and development images** available
- Non-root user for security
- Health check endpoint
- Multi-architecture support (amd64, arm64)

## Quick Start

```bash
# Pull the development image (with Xdebug)
docker pull siomkin/8.5-fpm-alpine:latest

# Pull the production image (without Xdebug, optimized for performance)
docker pull siomkin/8.5-fpm-alpine:latest-prod

# Run a development container
docker run -d -p 9000:9000 --name php-app siomkin/8.5-fpm-alpine

# Run a production container
docker run -d -p 9000:9000 --name php-app-prod siomkin/8.5-fpm-alpine:latest-prod

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

# Build the development image (with Xdebug)
docker build -t siomkin/8.5-fpm-alpine .

# Build the production image (without Xdebug, faster build)
docker build --build-arg INSTALL_XDEBUG=false -t siomkin/8.5-fpm-alpine:prod .

# Build with custom system timezone (baked into the image)
docker build --build-arg TZ=Europe/Minsk -t siomkin/8.5-fpm-alpine .

# Or override PHP timezone at runtime (sets date.timezone ini)
docker run -d -p 9000:9000 -e TZ=Europe/Minsk --name php-app siomkin/8.5-fpm-alpine

# Build with BuildKit for better caching (recommended)
DOCKER_BUILDKIT=1 docker build -t siomkin/8.5-fpm-alpine .
```

## PHP Extensions

The image includes the following PHP extensions:
- bcmath
- exif
- gd (with freetype, jpeg, webp, avif support)
- gmp
- intl
- mysqli
- opcache
- pcntl
- pdo_mysql
- pdo_pgsql
- redis
- sockets
- xsl
- zip
- xdebug (development images only)

## Configuration

### Build Arguments

- `TZ`: System timezone baked into the image (default: UTC). Sets `/etc/localtime` at build time.
- `INSTALL_XDEBUG`: Install Xdebug extension (default: true)
  - Set to `false` for production builds

### Environment Variables

- `TZ`: Overrides PHP's `date.timezone` at container startup (e.g. `-e TZ=Europe/Minsk`). Does not change the system timezone set at build time.

### Image Variants

**Development Image** (default, `:latest` tag):
- Includes Xdebug for debugging
- Ideal for local development
- Slightly larger image size

**Production Image** (`:latest-prod` tag):
- No Xdebug (better performance)
- Smaller image size
- Optimized for production workloads

## CI/CD Workflow

The GitHub Actions workflow builds and tests both image variants.

### Build Triggers

| Trigger | Build Type | Platforms |
|---------|------------|-----------|
| **Pull Request** | Test build | `linux/amd64` only (fast) |
| **Tag Push** | Full build + tests | `linux/amd64`, `linux/arm64` |
| **Schedule** (weekly) | Full rebuild | `linux/amd64`, `linux/arm64` |
| **Manual** | Full build | `linux/amd64`, `linux/arm64` |

### Features

- **Fast PR builds**: Only builds for Linux AMD64
- **Multi-platform releases**: ARM64 support for Apple Silicon and ARM servers
- **Separate images**: Production (no Xdebug) and Development (with Xdebug)
- **Security scanning**: Trivy vulnerability scanning on tag releases
- **Automated testing**: PHP extensions, Xdebug, FPM process, PHP 8.5 features verification

## Health Check

The image includes a health check that verifies PHP-FPM is running correctly:

```bash
docker ps  # Will show health status
```

## Security

- Runs as non-root user (www:1000)
- Minimal Alpine Linux base
- Regular security updates via automated builds
- Trivy vulnerability scanning in CI/CD

## PHP 8.5 Features

Learn about the new features and improvements in PHP 8.5 in our [PHP 8.5 Features Guide](./PHP-8.5-FEATURES.md).

## License

MIT License
