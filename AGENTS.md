## Cursor Cloud specific instructions

This repository is a **Docker image project** (not an application). It produces PHP 8.5 FPM Alpine Docker images in two variants: development (with Xdebug) and production (without Xdebug).

### Building and testing

The only build artifact is the `Dockerfile`. All development work revolves around Docker:

- **Lint:** `hadolint Dockerfile` — only warnings are expected (unpinned `apk` versions); no errors.
- **Build dev image:** `DOCKER_BUILDKIT=1 docker build -t php85:dev .`
- **Build prod image:** `DOCKER_BUILDKIT=1 docker build --build-arg INSTALL_XDEBUG=false -t php85:prod .`
- **Test:** run containers and verify PHP version, extensions, Xdebug presence/absence, and PHP-FPM config. See the CI workflow at `.github/workflows/docker-image.yml` for the full test matrix.

### Gotchas

- The dev image build compiles Xdebug from source (~2 min); the prod image skips this step.
- The container runs as non-root user `www` (UID 1000). Use `-u root` if you need to write files inside the container for testing.
- Docker must be running with `fuse-overlayfs` storage driver and `iptables-legacy` in the Cloud Agent VM (already configured by the environment snapshot).
- There are no application-level dependencies, package managers, or test frameworks — Docker is the sole toolchain.
