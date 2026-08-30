#!/usr/bin/env bash
# test-fixer-refact-async Installer - Unix/Linux/macOS
# Verifies prerequisites for fixing failing async tests and refactoring

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CHECK="✓"
CROSS="✗"
WARN="!"
INFO="i"

print_header() {
    echo -e "\n${BLUE}========================================"
    echo "$1"
    echo -e "========================================${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECK}${NC} $1"
}

print_error() {
    echo -e "${RED}${CROSS}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}${WARN}${NC} $1"
}

print_info() {
    echo -e "${BLUE}${INFO}${NC} $1"
}

check_git() {
    if command -v git &> /dev/null; then
        print_success "Git found: $(git --version)"
        return 0
    else
        print_error "Git is not installed or not in PATH"
        print_info "Please install Git: https://git-scm.com/"
        return 1
    fi
}

check_git_repo() {
    if git rev-parse --git-dir &> /dev/null; then
        print_success "Inside a Git repository"
        return 0
    else
        print_error "Current directory is not a Git repository"
        print_info "Run this installer from the root of your Git repository"
        return 1
    fi
}

check_dotnet() {
    if command -v dotnet &> /dev/null; then
        VERSION=$(dotnet --version)
        print_success ".NET SDK found: $VERSION"

        # Check major version
        MAJOR=$(echo "$VERSION" | cut -d. -f1)
        if [ "$MAJOR" -lt 8 ]; then
            print_warning ".NET SDK version is $VERSION, recommended 8.0+"
        fi
        return 0
    else
        print_error ".NET SDK is not installed or not in PATH"
        print_info "Please install .NET SDK 8.0+: https://dotnet.microsoft.com/download"
        return 1
    fi
}

check_test_projects() {
    echo ""
    echo "Checking for test projects..."

    # Find .csproj files with test framework references
    TEST_PROJECTS=$(find . -name "*.csproj" -exec grep -l -E "xunit|NUnit|MSTest|TUnit|FluentAssertions|Moq" {} \; 2>/dev/null || true)

    if [ -z "$TEST_PROJECTS" ]; then
        print_info "No test project found with common testing packages"
        print_info "Expected packages: xunit, NUnit, MSTest, TUnit, FluentAssertions, Moq"
    else
        print_success "Found test project(s):"
        echo "$TEST_PROJECTS" | while read -r proj; do
            echo "   $proj"
        done
    fi
}

verify_skill_structure() {
    local skill_dir="$1"

    REQUIRED_FILES=(
        "SKILL.md"
        "README.md"
        "references/Context.md"
        "scripts/install.sh"
        "scripts/install.ps1"
        "scripts/install.py"
    )

    ALL_PRESENT=true

    echo ""
    echo "Verifying skill structure..."

    for file in "${REQUIRED_FILES[@]}"; do
        if [ -f "$skill_dir/$file" ]; then
            print_success "$file"
        else
            print_error "Missing: $file"
            ALL_PRESENT=false
        fi
    done

    if [ "$ALL_PRESENT" = true ]; then
        return 0
    else
        return 1
    fi
}

main() {
    print_header "test-fixer-refact-async Installer (Unix/Linux/macOS)"

    ALL_CHECKS_PASS=true

    # Check Git
    if ! check_git; then
        ALL_CHECKS_PASS=false
    fi

    # Check Git repository
    if ! check_git_repo; then
        ALL_CHECKS_PASS=false
    fi

    # Check .NET SDK
    if ! check_dotnet; then
        ALL_CHECKS_PASS=false
    fi

    # Check for test projects
    check_test_projects

    # Verify skill structure
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    SKILL_DIR="$(dirname "$SCRIPT_DIR")"

    if ! verify_skill_structure "$SKILL_DIR"; then
        ALL_CHECKS_PASS=false
    fi

    # Summary
    print_header "Installation Verification Complete"
    if [ "$ALL_CHECKS_PASS" = true ]; then
        print_success "All checks passed!"
    else
        print_warning "Some checks failed - see above"
        exit 1
    fi

    echo ""
    echo "Next steps:"
    echo "1. Ensure your test project references a test framework (xUnit, NUnit, MSTest, TUnit)"
    echo "2. Add FluentAssertions and Moq for better assertions and mocking"
    echo "3. Follow the async test fixing workflow in SKILL.md"
    echo "4. Run failing tests with: dotnet test --filter \"FullyQualifiedName~TestName\""
    echo ""
}

main "$@"