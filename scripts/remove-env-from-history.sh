#!/bin/bash

# =============================================================================
# Remove .env files from Git history - CVE-001 Remediation
# =============================================================================
# SECURITY: This script removes accidentally committed .env files from git history
# CVSS Score: 9.8 (Critical) - Potential exposure of credentials
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "==============================================================================="
echo "  Git History Cleanup: Remove .env files"
echo "==============================================================================="
echo ""
echo -e "${YELLOW}⚠️  WARNING: This operation rewrites Git history${NC}"
echo ""
echo "This will:"
echo "  1. Remove .env.development from all commits"
echo "  2. Remove .env.staging from all commits"
echo "  3. Remove .env.production from all commits"
echo "  4. Preserve .env.example (safe template)"
echo ""
echo "Prerequisites:"
echo "  ✓ All team members must be notified"
echo "  ✓ All team members must re-clone after push"
echo "  ✓ Active pull requests will be affected"
echo "  ✓ Create backup branch before proceeding"
echo ""
read -p "Do you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}✗ Aborted by user${NC}"
    exit 1
fi

# Create backup branch
BACKUP_BRANCH="backup-before-env-removal-$(date +%Y%m%d-%H%M%S)"
echo ""
echo -e "${YELLOW}Creating backup branch: $BACKUP_BRANCH${NC}"
git branch "$BACKUP_BRANCH"
echo -e "${GREEN}✓ Backup created${NC}"

# Check if git-filter-repo is installed
if ! command -v git-filter-repo &> /dev/null; then
    echo ""
    echo -e "${RED}✗ git-filter-repo not found${NC}"
    echo ""
    echo "Install with:"
    echo "  pip3 install git-filter-repo"
    echo "  OR brew install git-filter-repo (macOS)"
    echo "  OR download from: https://github.com/newren/git-filter-repo"
    exit 1
fi

# Remove .env files from history
echo ""
echo -e "${YELLOW}Removing .env files from Git history...${NC}"
git filter-repo --invert-paths \
    --path .env.development \
    --path .env.staging \
    --path .env.production \
    --force

echo -e "${GREEN}✓ Files removed from Git history${NC}"

# Verify .gitignore
echo ""
echo -e "${YELLOW}Verifying .gitignore...${NC}"
if grep -q "^\.env\.development$" .gitignore && \
   grep -q "^\.env\.staging$" .gitignore && \
   grep -q "^\.env\.production$" .gitignore; then
    echo -e "${GREEN}✓ .gitignore properly configured${NC}"
else
    echo -e "${RED}✗ .gitignore needs updating${NC}"
    echo ""
    echo "Add these lines to .gitignore:"
    echo ".env.development"
    echo ".env.staging"
    echo ".env.production"
    exit 1
fi

# Final instructions
echo ""
echo "==============================================================================="
echo -e "${GREEN}✓ SUCCESS: .env files removed from Git history${NC}"
echo "==============================================================================="
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. Review changes:"
echo "   git log --all --oneline -- .env.development .env.staging .env.production"
echo "   (should return nothing)"
echo ""
echo "2. Force push to remote (DESTRUCTIVE):"
echo "   git push origin --force --all"
echo "   git push origin --force --tags"
echo ""
echo "3. Notify team to re-clone:"
echo "   cd .."
echo "   rm -rf flutter-base"
echo "   git clone <repository-url>"
echo ""
echo "4. CRITICAL - Rotate all credentials that were in these files"
echo "   Even though current .env files contain no secrets,"
echo "   verify old commits and rotate any exposed credentials"
echo ""
echo "5. Configure CI/CD secrets:"
echo "   - GitHub: Settings → Secrets and variables → Actions"
echo "   - GitLab: Settings → CI/CD → Variables"
echo "   - Jenkins: Credentials → Add"
echo ""
echo "Backup branch available at: $BACKUP_BRANCH"
echo ""
echo -e "${YELLOW}⚠️  Remember: All developers must RE-CLONE the repository${NC}"
echo ""
