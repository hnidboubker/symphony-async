# bdd-async

Behavior-Driven Development skill for C#/.NET projects using TUnit.

Transforms business requirements into executable behavior-oriented tests using Given → When → Then.

## Structure

```
bdd-async/
├── references/
│   └── Context.md
├── scripts/
│   ├── install.sh
│   ├── install.ps1
│   └── install.py
├── SKILL.md
└── README.md
```

## Usage

```bash
/bdd-async
```

## Test Level Selection

Choose the smallest appropriate test level for each scenario:

| Level | Description |
|-------|-------------|
| Domain behavior | TUnit unit test |
| Application behavior | TUnit integration test |
| API behavior | TUnit API/integration test |
| Critical user journey | TUnit end-to-end test |

## Core Principle

Test business behavior, not implementation.