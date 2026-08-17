# tdd-async

Test-Driven Development skill for C#/.NET using TUnit.

## Purpose

This skill enforces a strict TDD workflow (Red → Green → Refactor) when implementing functionality in C#/.NET projects. It ensures tests are written before production code and follows TUnit conventions.

## Usage

The skill is typically invoked by the `symphony-orchestrator` orchestrator as part of the development pipeline:

```text
symphony-orchestrator
      ↓
tdd-async (this skill)
      ↓
commit-async
      ↓
tests-async (validation)
      ↓
auto-release
      ↓
readme-async
```

## Workflow

1. **RED** - Write a failing test expressing the desired behavior
2. **GREEN** - Implement minimum production code to make the test pass
3. **REFACTOR** - Improve code structure while keeping tests passing

## Requirements

- .NET SDK 8.0+
- TUnit testing framework

## Integration

This skill integrates with the Symphony Async workflow. When used independently, it returns one of the following states:

- `TDD_RED` - Test written, failing as expected
- `TDD_GREEN` - Test passing after implementation
- `TDD_REFACTOR` - Refactoring in progress
- `TDD_COMPLETED` - Full cycle complete, all tests passing
- `TDD_PASSED` - Final success state
- `TDD_FAILED` - Failure state

## Files

- `SKILL.md` - Full skill definition and workflow
- `references/Context.md` - TUnit reference documentation
- `scripts/install.sh` - Linux/macOS installer
- `scripts/install.ps1` - Windows installer
- `scripts/install.py` - Cross-platform installer