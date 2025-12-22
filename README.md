[![8.5-fpm-alpine Docker Image CI](https://github.com/Siomkin/php-8.5-fpm-alpine/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Siomkin/php-8.5-fpm-alpine/actions/workflows/docker-image.yml)

# PHP 8.5 FPM Alpine Docker Image

A lightweight Docker image based on Alpine Linux that includes PHP 8.5 FPM with common extensions and development tools.

## Features

- **PHP 8.5.1** with FPM
- Alpine Linux based for minimal size
- Common PHP extensions pre-installed
- **Xdebug support** (optional, enabled by default in development images)
- **Multi-stage build** for optimized image size
- **Separate production and development images** available
- Non-root user for security
- Health check endpoint
- **Optimized build performance** with parallel compilation

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

# Run with custom timezone
docker run -d -p 9000:9000 --build-arg TZ=Europe/Moscow --name php-app siomkin/8.5-fpm-alpine

# Build with BuildKit for better caching (recommended)
DOCKER_BUILDKIT=1 docker build -t siomkin/8.5-fpm-alpine .
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
  - Set to `false` for production builds (25-40% faster build time)
  - Production images are automatically built with this set to `false`

### Environment Variables

- `TZ`: Set from build argument, affects container timezone

### Image Variants

**Development Image** (default, `:latest` tag):
- Includes Xdebug for debugging
- Ideal for local development
- Slightly larger image size

**Production Image** (`:latest-prod` tag):
- No Xdebug (better performance)
- Smaller image size
- Optimized for production workloads
- 10-15% smaller than development image

## Performance Optimizations

This image uses several optimization techniques:

- **Multi-stage build**: Separates build dependencies from runtime, reducing final image size by 10-15%
- **Parallel compilation**: Uses all CPU cores (`make -j$(nproc)`) for faster builds
- **Conditional Xdebug**: Production images skip Xdebug entirely, saving 25-40% build time
- **Layer caching**: Optimized layer ordering for better Docker cache utilization
- **Pinned dependencies**: Uses specific versions (e.g., install-php-extensions v2.7.0) for reproducible builds

## CI/CD Workflow

The GitHub Actions workflow is optimized for fast builds:

### Build Triggers

| Trigger | Build Type | Platforms |
|---------|------------|-----------|
| **Pull Request** | Test build | `linux/amd64` only (fast) |
| **Tag Push** | Full build + tests | `linux/amd64`, `linux/arm64` |
| **Schedule** (weekly) | Full rebuild | `linux/amd64`, `linux/arm64` |
| **Manual** | Full build | `linux/amd64`, `linux/arm64` |

### Features

- **Fast PR builds**: Only builds for Linux AMD64 (~5-7 min vs ~15-20 min)
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

## License

MIT License

## PHP 8.5 Features

Learn about the new features and improvements in PHP 8.5 in our [PHP 8.5 Features Guide](./PHP-8.5-FEATURES.md).

## Additional Documentation

- [OPTIMIZATION-GUIDE.md](./OPTIMIZATION-GUIDE.md) - Detailed performance optimization documentation
- [MIGRATION-GUIDE.md](./MIGRATION-GUIDE.md) - Guide for upgrading from previous versions
- [SECURITY.md](./SECURITY.md) - Security policy and reporting guidelines
