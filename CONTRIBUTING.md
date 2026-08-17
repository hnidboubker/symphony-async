# Contributing to Symphony Async

Thank you for your interest in contributing to Symphony Async! This document outlines the guidelines and workflow for contributing to this project.

## Code of Conduct

By participating in this project, you agree to abide by our commitment to fostering an open, inclusive, and respectful community. Please be considerate in your interactions with other contributors.

## How to Contribute

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/<your-username>/symphony-orchestrator.git
cd symphony-orchestrator

# Add upstream remote to stay in sync
git remote add upstream https://github.com/original-owner/symphony-orchestrator.git
```

### 2. Create a Branch

Create a new branch for each logical change:

```bash
# Feature branch
git checkout -b feat/your-feature-name

# Bug fix branch
git checkout -b fix/your-bug-description

# Documentation branch
git checkout -b docs/your-documentation-update

# Refactor branch
git checkout -b refactor/your-refactor-description
```

### 3. Make Changes

Follow these guidelines when making changes:

#### Code Quality
- Write clean, readable, and well-structured code
- Follow the existing code style and patterns in each skill
- Keep functions small and focused on a single responsibility
- Add comments only when the "why" is non-obvious

#### Commit Messages
Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat:` — New feature
- `fix:` — Bug fix
- `docs:` — Documentation only changes
- `style:` — Code style changes (formatting, etc.)
- `refactor:` — Code refactoring (no behavior change)
- `perf:` — Performance improvement
- `test:` — Adding or updating tests
- `chore:` — Maintenance tasks (dependencies, build, etc.)

**Examples:**
```
feat(commit-async): add support for signed commits
fix(auto-release): handle pre-release version tags correctly
docs(readme-async): update installation instructions
refactor(tests-async): simplify test strategy selection logic
```

### 4. Test Your Changes

Before submitting, verify your changes work correctly:

```bash
# Run the installer to verify environment
bash symphony-orchestrator/scripts/install.sh

# Test individual skills
bash commit-async/scripts/install.sh
python auto-release/scripts/release.py --dry-run

# If working with .NET skills
dotnet build tdd-async
dotnet test tdd-async
```

### 5. Submit a Pull Request

Before creating a Pull Request, ensure:

- [ ] The project builds/works correctly
- [ ] Your changes are complete and focused
- [ ] You have tested your changes
- [ ] Commit messages follow Conventional Commits format
- [ ] You have clearly explained what you changed and why
- [ ] Documentation is updated if needed (README, skill READMEs, etc.)

**Pull Request Template:**

```markdown
## Summary
Brief description of the changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement
- [ ] Other (please describe)

## Testing
Describe how you tested your changes:
- [ ] Manual testing
- [ ] Automated tests pass
- [ ] Integration testing

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
```

## Development Workflow

### Skill Structure

Each skill follows a consistent structure:

```
skill-name/
├── scripts/           # Installation/verification scripts
│   ├── install.sh     # Linux/macOS
│   ├── install.ps1    # Windows PowerShell
│   └── install.py     # Cross-platform Python
├── references/        # Reference documentation
│   └── Context.md     # Operational context
├── SKILL.md           # Skill definition (required)
├── README.md          # Skill documentation
└── CONTRIBUTING.md    # Optional: skill-specific guidelines
```

### Adding a New Skill

1. Create the skill directory under the project root
2. Follow the standard structure above
3. Create a `SKILL.md` with:
   - `name` and `description` frontmatter
   - Clear purpose and workflow
   - Integration points with Symphony
   - Security constraints
4. Add installation scripts that verify prerequisites
5. Update the main `symphony-orchestrator/SKILL.md` to include the new skill in the orchestration
6. Update this CONTRIBUTING.md if needed

### Modifying Existing Skills

1. Read the skill's `SKILL.md` and `README.md` thoroughly
2. Understand the skill's contract (input/output states)
3. Make minimal, focused changes
4. Update documentation if behavior changes
5. Ensure the skill still returns proper machine-readable states

## Testing Guidelines

### For C#/.NET Skills (tdd-async, bdd-async, tests-async)

- Use **TUnit** exclusively (no xUnit, NUnit, MSTest, SpecFlow, Cucumber)
- Preferred command: `dotnet test`
- Use TUnit-native assertions: `await Assert.That(...)`
- Follow Red-Green-Refactor for TDD
- Follow Given-When-Then for BDD

### For Python Skills (auto-release)

- Use standard library only (no external dependencies)
- Python 3.8+ compatibility
- Follow PEP 8 style guide

### For Shell Scripts (all install scripts)

- Use `set -euo pipefail` for robustness
- POSIX-compliant where possible
- Provide clear success/error output
- Exit with appropriate codes (0 = success, non-zero = failure)

### General Testing Principles

- **Never delete failing tests** — fix the implementation instead
- **Never weaken assertions** to make tests pass
- **Never skip tests** without justification
- **Never hide failures** — a failing test is a signal that must be reported
- Test both success and failure paths

## Documentation Standards

- Keep documentation synchronized with implementation
- Update README.md when adding/removing/changing features
- Use clear, concise language
- Include practical examples
- Document all configuration options
- Never expose real secrets in examples (use placeholders)

## Security Considerations

When contributing, ensure your changes:

- Do not introduce commands that could delete user data
- Do not bypass approval mechanisms
- Do not execute destructive Git operations
- Do not expose sensitive information
- Follow the principle of least privilege
- Validate all inputs

See [SECURITY.md](SECURITY.md) for detailed security policies.

## Release Process

Releases are managed by `auto-release` based on Conventional Commits:

1. Changes are committed via `commit-async` (with approval)
2. Tests pass via `tests-async`
3. `auto-release` analyzes commits since last release
4. Semantic version determined (MAJOR/MINOR/PATCH)
5. CHANGELOG.md updated
6. Git tag created
7. `readme-async` synchronizes documentation

**You don't need to manually create releases** — the pipeline handles it automatically when commits meet the criteria.

## Getting Help

- Check existing issues and PRs for similar questions
- Review skill documentation (each skill has its own README.md)
- Read the main `symphony-orchestrator/SKILL.md` for orchestration details
- Open a new issue for bugs or feature requests

## Recognition

Contributors are recognized in the project. Thank you for making Symphony Async better!

---

**Questions?** Open an issue or start a discussion. We're here to help!