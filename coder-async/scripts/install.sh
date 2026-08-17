#!/usr/bin/env bash
# install.sh — Install coder-async skill

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default target is current directory
TARGET_DIR="${1:-.}"

echo -e "${BLUE}Installing coder-async skill...${NC}"

# Verify Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: Git is not installed${NC}"
    exit 1
fi

# Verify we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a Git repository${NC}"
    exit 1
fi

# Get the source directory (where this script lives)
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Target skill directory
SKILL_DIR="${TARGET_DIR}/.claude/skills/coder-async"

# Create target directory
mkdir -p "${SKILL_DIR}"

# Copy skill files
echo -e "${YELLOW}Copying skill files...${NC}"
cp -r "${SOURCE_DIR}/"* "${SKILL_DIR}/"

# Verify installation
if [[ -f "${SKILL_DIR}/SKILL.md" && -f "${SKILL_DIR}/README.md" ]]; then
    echo -e "${GREEN}✓ coder-async skill installed successfully at ${SKILL_DIR}${NC}"
else
    echo -e "${RED}Error: Installation verification failed${NC}"
    exit 1
fi

echo -e "${BLUE}Installation complete.${NC}"