# Workflow Fix Summary

## Problem Statement
GitHub Actions workflow run [#18427055096](https://github.com/Siomkin/php-8.5-fpm-alpine/actions/runs/18427055096) failed with multiple job failures:
- `test-production (linux/amd64)` - Failed
- `test-development (linux/amd64)` - Failed
- `security-scan (production)` - Failed
- `security-scan (development)` - Failed

## Root Cause Analysis

### Initial Symptoms
All failing jobs showed the same error pattern:
```bash
docker: 'docker run' requires at least 1 argument
```

And for security scans:
```bash
Require at least 1 argument
```

### Investigation
The jobs were trying to extract image references from build job outputs:
```yaml
TAGS='${{ needs.build-production.outputs.image_tags }}'
IMAGE_REF=$(echo "$TAGS" | head -n1)
```

But `TAGS` was always empty!

### Root Cause Discovery
Analysis of the build job logs revealed:
```
##[warning]Skip output 'image_metadata' since it may contain secret.
##[warning]Skip output 'image_tags' since it may contain secret.
```

**GitHub Actions was masking the outputs** because it detected potential secrets (Docker registry credentials from `docker/login-action`). This is a known behavior when using Docker registry authentication.

## Solution

### Strategy
Instead of relying on masked build outputs, reconstruct image references directly from GitHub event context:
- `github.ref` - The full git ref (e.g., `refs/tags/v8.5.0.2RC`)
- `github.ref_name` - The short ref name (e.g., `v8.5.0.2RC`)
- `github.event_name` - The event type (e.g., `push`, `schedule`)

### Implementation

#### 1. Test Jobs (test-production, test-development)
Added logic to construct image references based on event type:

```yaml
- name: Extract image reference
  id: image-ref
  run: |
    if [ "${{ github.event_name }}" == "push" ] && [[ "${{ github.ref }}" == refs/tags/* ]]; then
      TAG_NAME="${{ github.ref_name }}"
      IMAGE_REF="${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${TAG_NAME}-prod"  # or without -prod for dev
    elif [ "${{ github.event_name }}" == "push" ] && [[ "${{ github.ref }}" == refs/heads/* ]]; then
      BRANCH_NAME="${{ github.ref_name }}"
      IMAGE_REF="${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${BRANCH_NAME}-prod"
    elif [ "${{ github.event_name }}" == "schedule" ]; then
      DATE_TAG=$(date +%Y%m%d)
      IMAGE_REF="${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${DATE_TAG}-prod"
    fi
```

Added explicit image pull step:
```yaml
- name: Pull production image
  run: |
    docker pull ${{ steps.image-ref.outputs.image-ref }}
```

#### 2. Security Scan Jobs
Similar reconstruction logic with matrix-based differentiation:
```yaml
if [ "${{ matrix.image_type }}" == "production" ]; then
  IMAGE_REF="${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${TAG_NAME}-prod"
else
  IMAGE_REF="${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${TAG_NAME}"
fi
```

#### 3. Benchmark Job
Simplified to use tag name directly:
```yaml
TAG_NAME="${{ github.ref_name }}"
IMAGE_REF="${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${TAG_NAME}-prod"
```

#### 4. Release Notification Job
Removed references to masked outputs and constructed tags directly:
```yaml
**Production (without Xdebug):**
```
${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }}-prod
```
```

## Image Tagging Pattern

The workflow now follows this consistent tagging pattern:

### For Tag Pushes (e.g., `v8.5.0.2RC`)
- **Production**: `docker.io/siomkin/8.5-fpm-alpine:v8.5.0.2RC-prod`
- **Development**: `docker.io/siomkin/8.5-fpm-alpine:v8.5.0.2RC`

### For Branch Pushes (e.g., `master`)
- **Production**: `docker.io/siomkin/8.5-fpm-alpine:master-prod`
- **Development**: `docker.io/siomkin/8.5-fpm-alpine:master`

### For Scheduled Builds
- **Production**: `docker.io/siomkin/8.5-fpm-alpine:YYYYMMDD-prod`
- **Development**: `docker.io/siomkin/8.5-fpm-alpine:YYYYMMDD`

## Changes Made

### Files Modified
- `.github/workflows/docker-image.yml`

### Commits
1. `Initial plan` - Analysis and planning
2. `Fix workflow: Add image validation and pull steps` - Added validation and pull steps
3. `Fix masked outputs: Reconstruct image refs from event context` - Main fix for test and security jobs
4. `Fix benchmark and release-notification jobs` - Fixed remaining jobs

## Verification

### Syntax Validation
```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/docker-image.yml'))"
✓ YAML syntax is valid
```

### Masked Output References
```bash
grep "needs.build-production.outputs.image_tags" .github/workflows/docker-image.yml
✓ No masked output references found
```

### Consistent Patterns
All image references follow the same construction pattern:
- Production images: `${TAG_NAME}-prod`
- Development images: `${TAG_NAME}` (no suffix)

## Expected Behavior

When the workflow runs again on tag `v8.5.0.2RC`:

1. ✅ **Build jobs** will push images to Docker Hub with predictable tags
2. ✅ **Test jobs** will reconstruct the correct image reference and pull it
3. ✅ **Security scan jobs** will scan the correct images
4. ✅ **Benchmark job** will run performance tests on the production image
5. ✅ **Release notification** will generate correct release notes

## Testing Recommendations

1. **Trigger workflow on existing tag**:
   ```bash
   git tag -f v8.5.0.2RC
   git push --force origin v8.5.0.2RC
   ```

2. **Monitor the workflow run** to ensure:
   - Build jobs complete successfully
   - Test jobs pull the correct images
   - Security scans run without errors
   - All jobs complete successfully

3. **Check Docker Hub** to verify images are pushed:
   - `docker.io/siomkin/8.5-fpm-alpine:v8.5.0.2RC-prod`
   - `docker.io/siomkin/8.5-fpm-alpine:v8.5.0.2RC`

## Conclusion

The workflow failures were caused by GitHub Actions masking sensitive outputs. The fix reconstructs image references from GitHub event context, ensuring jobs can correctly identify and pull the built images. All jobs have been updated to use this approach, eliminating dependency on masked outputs.
