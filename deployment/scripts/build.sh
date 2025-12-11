#!/bin/bash
# =============================================================================
# Build Script - Flutter Web Docker Image
# Usage: ./build.sh [version] [push]
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DOCKER_DIR="$SCRIPT_DIR/../docker"

# Default values
IMAGE_NAME="${IMAGE_NAME:-flutter-base-2025}"
REGISTRY="${REGISTRY:-ghcr.io}"
REGISTRY_OWNER="${REGISTRY_OWNER:-}"

# Get version from pubspec.yaml if not provided
VERSION="${1:-$(grep 'version:' "$PROJECT_ROOT/pubspec.yaml" | head -1 | awk '{print $2}')}"
PUSH="${2:-false}"

# Build metadata
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_REF=$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")
VCS_BRANCH=$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

# Functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Pre-flight checks
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed or not in PATH"
    exit 1
fi

if ! docker info &> /dev/null; then
    log_error "Docker daemon is not running"
    exit 1
fi

# Validate
if [[ -z "$VERSION" ]]; then
    log_error "Version not found. Provide as argument or ensure pubspec.yaml exists."
    exit 1
fi

log_info "Building Flutter Web Docker Image"
log_info "  Version:    $VERSION"
log_info "  VCS Ref:    $VCS_REF"
log_info "  VCS Branch: $VCS_BRANCH"
log_info "  Build Date: $BUILD_DATE"

# Determine full image name
if [[ -n "$REGISTRY_OWNER" ]]; then
    FULL_IMAGE_NAME="$REGISTRY/$REGISTRY_OWNER/$IMAGE_NAME"
else
    FULL_IMAGE_NAME="$IMAGE_NAME"
fi

# Build image
log_info "Building image: $FULL_IMAGE_NAME:$VERSION"

docker build \
    --file "$DOCKER_DIR/Dockerfile" \
    --build-arg BUILD_VERSION="$VERSION" \
    --build-arg BUILD_NUMBER="${BUILD_NUMBER:-0}" \
    --build-arg BUILD_DATE="$BUILD_DATE" \
    --build-arg VCS_REF="$VCS_REF" \
    --tag "$FULL_IMAGE_NAME:$VERSION" \
    --tag "$FULL_IMAGE_NAME:latest" \
    "$PROJECT_ROOT"

log_info "Build completed successfully!"

# Tag with branch name for non-main branches
if [[ "$VCS_BRANCH" != "main" && "$VCS_BRANCH" != "master" ]]; then
    BRANCH_TAG=$(echo "$VCS_BRANCH" | sed 's/[^a-zA-Z0-9]/-/g')
    docker tag "$FULL_IMAGE_NAME:$VERSION" "$FULL_IMAGE_NAME:$BRANCH_TAG"
    log_info "Tagged: $FULL_IMAGE_NAME:$BRANCH_TAG"
fi

# Push if requested
if [[ "$PUSH" == "push" || "$PUSH" == "true" ]]; then
    log_info "Pushing images to registry..."
    
    docker push "$FULL_IMAGE_NAME:$VERSION"
    docker push "$FULL_IMAGE_NAME:latest"
    
    if [[ "$VCS_BRANCH" != "main" && "$VCS_BRANCH" != "master" ]]; then
        docker push "$FULL_IMAGE_NAME:$BRANCH_TAG"
    fi
    
    log_info "Push completed!"
fi

# Print summary
echo ""
log_info "=== Build Summary ==="
echo "  Image:   $FULL_IMAGE_NAME"
echo "  Tags:    $VERSION, latest"
echo "  Size:    $(docker images --format '{{.Size}}' "$FULL_IMAGE_NAME:$VERSION")"
echo ""

# Cleanup dangling images
log_info "Cleaning up dangling images..."
docker image prune -f --filter "dangling=true" 2>/dev/null || true

# Security scan suggestion
log_warn "Run security scan: docker run --rm aquasec/trivy image $FULL_IMAGE_NAME:$VERSION"
