# Implementation Workflow Plugins for Claude Code

Structured, agent-driven feature development workflows for Python/FastAPI and React/TypeScript projects.

## What This Is

Two Claude Code plugins -- **fastapi-dev** and **react-dev** -- that provide a structured
8-phase feature development workflow. Each plugin ships with specialized agents for
codebase exploration, architecture design, and code review; embedded best-practice skills
for conventions, testing, and quality; and auto-linting hooks that run on every file write.

## Features

- **8-phase workflow** with discovery, exploration, clarification, architecture, design
  document, implementation, review, and summary phases
- **Design document approval gate** -- no code is written until the design is explicitly
  approved by the developer
- **Specialized agents** -- explorer (deep codebase understanding), architect (multiple
  design approaches with trade-offs), reviewer (multi-lens quality review)
- **Embedded best practices** -- conventions, testing patterns, and code quality standards
  loaded automatically as skills
- **Auto-linting hooks** -- ruff/black for Python, eslint/prettier for React -- triggered
  on every file write so code stays clean throughout implementation

## Quick Start

### Install from the plugin marketplace

```bash
# Add the marketplace (one-time)
claude /plugin marketplace add https://github.com/alfalabs/claude-implementation-workflow

# Install the plugin you need
claude /plugin install fastapi-dev
claude /plugin install react-dev
```

### Or run locally during development

```bash
claude --plugin-dir ./plugins/fastapi-dev
claude --plugin-dir ./plugins/react-dev
```

### Usage

```
/fastapi-dev:feature-dev Add user authentication with JWT
/react-dev:feature-dev Add dashboard page with data grid
```

The command accepts an optional feature description. If omitted, the workflow will ask
you to describe the feature in Phase 1.

## Plugin Overview

### fastapi-dev

Feature development workflow for Python/FastAPI brownfield projects.

| Component | Name | Purpose |
|-----------|------|---------|
| Command | `feature-dev` | Launches the 8-phase workflow |
| Agent | `fastapi-explorer` | Deep-dives into existing codebase patterns |
| Agent | `fastapi-architect` | Produces architecture proposals with trade-offs |
| Agent | `fastapi-reviewer` | Multi-focus code review (simplicity, correctness, conventions) |
| Skill | `fastapi-conventions` | FastAPI/Python project conventions |
| Skill | `fastapi-testing` | Testing patterns and standards |
| Skill | `python-quality` | Code quality guidelines |
| Hook | `lint-python.sh` | Runs ruff and black on every file write |

### react-dev

Feature development workflow for React/TypeScript brownfield projects.

| Component | Name | Purpose |
|-----------|------|---------|
| Command | `feature-dev` | Launches the 8-phase workflow |
| Agent | `react-explorer` | Deep-dives into existing codebase patterns |
| Agent | `react-architect` | Produces architecture proposals with trade-offs |
| Agent | `react-reviewer` | Multi-focus code review (simplicity, correctness, conventions) |
| Skill | `react-conventions` | React/TypeScript project conventions |
| Skill | `react-testing` | Testing patterns and standards |
| Skill | `typescript-quality` | Code quality guidelines |
| Hook | `lint-react.sh` | Runs eslint and prettier on every file write |

## Workflow Phases

1. **Discovery** -- Understand what needs to be built; clarify the feature request with the user.
2. **Codebase Exploration** -- Launch explorer agents to map existing patterns, architecture, and testing approaches.
3. **Clarifying Questions** -- Identify and resolve every ambiguity, edge case, and scope boundary. **HARD GATE: all questions must be answered before proceeding.**
4. **Architecture Design** -- Launch architect agents to produce multiple approaches with explicit trade-offs; user picks one.
5. **Design Document** -- Write a comprehensive design document covering requirements, detailed design, API contracts, and test plan. **HARD GATE: user must explicitly approve the document before any implementation begins.**
6. **Implementation** -- Build the feature following the approved design, with skills enforcing conventions and hooks auto-linting every file.
7. **Quality Review** -- Launch reviewer agents for multi-lens review (simplicity, correctness, conventions); user decides which findings to address.
8. **Summary** -- Document what was built, key decisions, files changed, tests added, and suggested next steps.

## Customization

The skills embedded in each plugin contain the default conventions, testing patterns, and
quality standards. To tailor them to your project:

1. Navigate to the skill you want to modify, e.g.
   `plugins/fastapi-dev/skills/fastapi-conventions/SKILL.md`
2. Edit the markdown to reflect your project-specific conventions (naming, patterns,
   directory structure, preferred libraries)
3. The updated skill will be loaded automatically on the next workflow run

Agent prompts (`agents/*.md`) and the command definition (`commands/feature-dev.md`) can
be customized the same way.

## Contributing

Contributions are welcome. To get started:

1. Fork the repository
2. Create a feature branch (`git checkout -b my-feature`)
3. Make your changes
4. Run the plugins locally with `claude --plugin-dir ./plugins/<plugin-name>` to verify
5. Commit your changes and open a pull request

Please keep changes focused and include a clear description of what you changed and why.

## License

This project is licensed under the [MIT License](LICENSE).
