#!/bin/bash

# Performance and Optimization Test Script
# This script verifies that the Docker image optimizations are working correctly

set -e

echo "========================================="
echo "Docker Image Optimization Test Suite"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
pass() {
    echo -e "${GREEN}✓ PASS:${NC} $1"
    ((TESTS_PASSED++))
}

fail() {
    echo -e "${RED}✗ FAIL:${NC} $1"
    ((TESTS_FAILED++))
}

info() {
    echo -e "${YELLOW}ℹ INFO:${NC} $1"
}

# Test 1: Verify multi-stage build syntax
echo "Test 1: Verify multi-stage build structure"
if grep -q "FROM.*AS builder" Dockerfile && grep -q "FROM.*alpine$" Dockerfile && grep -q "COPY --from=builder" Dockerfile; then
    pass "Dockerfile uses multi-stage build"
else
    fail "Dockerfile does not use multi-stage build correctly"
fi
echo ""

# Test 2: Verify INSTALL_XDEBUG build argument exists
echo "Test 2: Verify INSTALL_XDEBUG build argument"
if grep -q "ARG INSTALL_XDEBUG" Dockerfile; then
    pass "INSTALL_XDEBUG build argument is defined"
else
    fail "INSTALL_XDEBUG build argument is missing"
fi
echo ""

# Test 3: Verify conditional Xdebug installation
echo "Test 3: Verify conditional Xdebug installation"
if grep -q 'if \[ "\$INSTALL_XDEBUG" = "true" \]' Dockerfile; then
    pass "Xdebug installation is conditional"
else
    fail "Xdebug installation is not conditional"
fi
echo ""

# Test 4: Verify pinned install-php-extensions version
echo "Test 4: Verify install-php-extensions version is pinned"
if grep -q "install-php-extensions/releases/download/2.7.0" Dockerfile; then
    pass "install-php-extensions is pinned to version 2.7.0"
else
    fail "install-php-extensions version is not pinned"
fi
echo ""

# Test 5: Verify parallel compilation for Xdebug
echo "Test 5: Verify parallel compilation"
if grep -q "make -j\$(nproc)" Dockerfile; then
    pass "Xdebug uses parallel compilation"
else
    fail "Xdebug does not use parallel compilation"
fi
echo ""

# Test 6: Verify no redundant chmod
echo "Test 6: Verify redundant chmod is removed"
CHMOD_COUNT=$(grep -c "chmod +x /usr/local/bin/install-php-extensions" Dockerfile || true)
if [ "$CHMOD_COUNT" -eq 1 ]; then
    pass "Only one chmod for install-php-extensions (redundant removed)"
else
    fail "Found $CHMOD_COUNT chmod commands for install-php-extensions (expected 1)"
fi
echo ""

# Test 7: Verify workflow has DOCKER_BUILDKIT enabled
echo "Test 7: Verify BuildKit is enabled in workflow"
if [ -f .github/workflows/docker-image.yml ]; then
    if grep -q "DOCKER_BUILDKIT.*1" .github/workflows/docker-image.yml; then
        pass "DOCKER_BUILDKIT is enabled in workflow"
    else
        fail "DOCKER_BUILDKIT is not enabled in workflow"
    fi
else
    fail "Workflow file not found"
fi
echo ""

# Test 8: Verify separate production and development builds
echo "Test 8: Verify separate production and development builds"
if [ -f .github/workflows/docker-image.yml ]; then
    if grep -q "build-production:" .github/workflows/docker-image.yml && grep -q "build-development:" .github/workflows/docker-image.yml; then
        pass "Workflow has separate production and development builds"
    else
        fail "Workflow does not have separate production and development builds"
    fi
else
    fail "Workflow file not found"
fi
echo ""

# Test 9: Verify timeout limits are set
echo "Test 9: Verify timeout limits in workflow"
if [ -f .github/workflows/docker-image.yml ]; then
    if grep -q "timeout-minutes:" .github/workflows/docker-image.yml; then
        pass "Workflow has timeout limits configured"
    else
        fail "Workflow does not have timeout limits"
    fi
else
    fail "Workflow file not found"
fi
echo ""

# Test 10: Verify cache scopes are different for prod and dev
echo "Test 10: Verify separate cache scopes"
if [ -f .github/workflows/docker-image.yml ]; then
    if grep -q "scope=prod" .github/workflows/docker-image.yml && grep -q "scope=dev" .github/workflows/docker-image.yml; then
        pass "Workflow uses separate cache scopes for production and development"
    else
        fail "Workflow does not use separate cache scopes"
    fi
else
    fail "Workflow file not found"
fi
echo ""

# Test 11: Build production image (without Xdebug)
echo "Test 11: Build production image (without Xdebug)"
info "Building production image... (this may take a few minutes)"
if DOCKER_BUILDKIT=1 docker build --build-arg INSTALL_XDEBUG=false -t test-image-prod . > /tmp/build-prod.log 2>&1; then
    pass "Production image builds successfully"
    
    # Verify Xdebug is not installed
    if docker run --rm test-image-prod php -m | grep -q xdebug; then
        fail "Production image should not have Xdebug"
    else
        pass "Production image correctly excludes Xdebug"
    fi
    
    # Get image size
    PROD_SIZE=$(docker images test-image-prod --format "{{.Size}}")
    info "Production image size: $PROD_SIZE"
    
    # Cleanup
    docker rmi test-image-prod > /dev/null 2>&1 || true
else
    fail "Production image build failed (see /tmp/build-prod.log)"
fi
echo ""

# Test 12: Build development image (with Xdebug)
echo "Test 12: Build development image (with Xdebug)"
info "Building development image... (this may take a few minutes)"
if DOCKER_BUILDKIT=1 docker build --build-arg INSTALL_XDEBUG=true -t test-image-dev . > /tmp/build-dev.log 2>&1; then
    pass "Development image builds successfully"
    
    # Verify Xdebug is installed
    if docker run --rm test-image-dev php -m | grep -q xdebug; then
        pass "Development image includes Xdebug"
    else
        fail "Development image should have Xdebug"
    fi
    
    # Get image size
    DEV_SIZE=$(docker images test-image-dev --format "{{.Size}}")
    info "Development image size: $DEV_SIZE"
    
    # Cleanup
    docker rmi test-image-dev > /dev/null 2>&1 || true
else
    fail "Development image build failed (see /tmp/build-dev.log)"
fi
echo ""

# Test 13: Verify documentation updates
echo "Test 13: Verify documentation is updated"
if grep -q "OPTIMIZATION-GUIDE" README.md || [ -f OPTIMIZATION-GUIDE.md ]; then
    pass "Optimization documentation exists"
else
    fail "Optimization documentation is missing"
fi
echo ""

# Summary
echo "========================================="
echo "Test Summary"
echo "========================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Please review the output above.${NC}"
    exit 1
fi
