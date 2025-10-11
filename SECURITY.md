# Security Policy

## Supported Versions

This Docker image provides PHP 8.5 FPM on Alpine Linux. We follow PHP's official support lifecycle and security updates.

| Version | Supported          | Release Status |
| ------- | ------------------ | -------------- |
| 8.5.x   | :white_check_mark: | Current        |
| 8.4.x   | :white_check_mark: | Security       |
| 8.3.x   | :white_check_mark: | Security       |
| < 8.3   | :x:                | End of Life    |

## Security Updates

- Base Alpine Linux images are updated weekly through automated builds
- PHP security patches are applied as soon as they are available
- All installed packages are regularly scanned for vulnerabilities

## Reporting a Vulnerability

If you discover a security vulnerability in this Docker image, please report it to us privately before disclosing it publicly.

### How to Report

1. **Email**: Send a detailed report to security@siomkin.com
2. **GitHub Security**: Use GitHub's [Private Vulnerability Reporting](https://github.com/Siomkin/php-8.5-fpm-alpine/security/advisories) feature
3. **Include in your report**:
   - Steps to reproduce the vulnerability
   - Potential impact assessment
   - Any proof-of-concept code or screenshots

### Response Timeline

- **Initial Response**: Within 48 hours
- **Detailed Assessment**: Within 5 business days
- **Patch Release**: Based on severity, typically within 7-14 days
- **Public Disclosure**: After a fix is released, or as coordinated

### Security Measures

This image includes several security measures:

- Non-root user execution (www:1000)
- Minimal Alpine Linux base
- Regular security scanning with Trivy
- Automated vulnerability detection in CI/CD
- Health checks for monitoring

## Security Best Practices

When using this image in production:

1. **Regular Updates**: Pull updated images regularly
2. **Network Security**: Use proper network segmentation
3. **Resource Limits**: Set appropriate CPU and memory limits
4. **Monitoring**: Implement logging and monitoring
5. **Secrets Management**: Use proper secrets management, not environment variables for sensitive data

## Security Scanning

All images are automatically scanned for vulnerabilities using:
- Trivy vulnerability scanner
- GitHub Security Advisories database
- Alpine Linux security advisories

Scan results are available in:
- GitHub Security tab for each release
- Docker Hub security scanning
- CI/CD pipeline reports
