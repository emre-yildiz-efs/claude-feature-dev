# Implementation Workflow Plugin — Design Document

**Date**: 2026-02-23
**Author**: Emre / AlfaLabs
**Status**: Draft

## 1. Problem Statement

When Claude Code implements features in Python FastAPI or ReactJS brownfield projects, it:
- Skips important steps (testing, edge cases, documentation)
- Follows no consistent process — quality varies across sessions
- Does poor upfront planning before writing code
- Has no embedded knowledge of project-specific best practices and conventions

## 2. Solution Overview

Two Claude Code **plugins** distributed via a GitHub repo as a plugin marketplace:

1. **fastapi-dev** — Implementation workflow for Python/FastAPI backends
2. **react-dev** — Implementation workflow for ReactJS/TypeScript frontends

Each plugin provides:
- **3 specialized agents** (explorer, architect, reviewer) with domain expertise
- **Skills** (best practices reference material) preloaded into agents
- **Hooks** (auto-lint/format on file edits)
- **1 orchestration command** (`/feature-dev`) driving an 8-phase workflow

Modeled after Anthropic's [feature-dev plugin](https://github.com/anthropics/claude-code/tree/main/plugins/feature-dev).

## 3. Repository Structure

```
alfalabs-claude-workflow/
├── plugins/
│   ├── fastapi-dev/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── agents/
│   │   │   ├── fastapi-explorer.md
│   │   │   ├── fastapi-architect.md
│   │   │   └── fastapi-reviewer.md
│   │   ├── commands/
│   │   │   └── feature-dev.md
│   │   ├── skills/
│   │   │   ├── fastapi-conventions/
│   │   │   │   └── SKILL.md
│   │   │   ├── fastapi-testing/
│   │   │   │   └── SKILL.md
│   │   │   └── python-quality/
│   │   │       └── SKILL.md
│   │   ├── hooks/
│   │   │   └── hooks.json
│   │   └── scripts/
│   │       └── lint-python.sh
│   └── react-dev/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── agents/
│       │   ├── react-explorer.md
│       │   ├── react-architect.md
│       │   └── react-reviewer.md
│       ├── commands/
│       │   └── feature-dev.md
│       ├── skills/
│       │   ├── react-conventions/
│       │   │   └── SKILL.md
│       │   ├── react-testing/
│       │   │   └── SKILL.md
│       │   └── typescript-quality/
│       │       └── SKILL.md
│       ├── hooks/
│       │   └── hooks.json
│       └── scripts/
│           └── lint-react.sh
├── marketplace.json
└── README.md
```

## 4. Plugin Manifests

### fastapi-dev/plugin.json

```json
{
  "name": "fastapi-dev",
  "version": "1.0.0",
  "description": "Feature development workflow for Python/FastAPI brownfield projects with embedded best practices, specialized agents, and auto-linting",
  "author": {
    "name": "AlfaLabs"
  }
}
```

### react-dev/plugin.json

```json
{
  "name": "react-dev",
  "version": "1.0.0",
  "description": "Feature development workflow for ReactJS/TypeScript brownfield projects with embedded best practices, specialized agents, and auto-linting",
  "author": {
    "name": "AlfaLabs"
  }
}
```

## 5. Agents

### 5.1 FastAPI Agents

#### fastapi-explorer.md

```yaml
name: fastapi-explorer
description: Deeply analyzes existing FastAPI codebase features by tracing execution paths from HTTP endpoints through routers, services, repositories, and models. Maps architecture layers, identifies patterns, and documents dependencies.
model: sonnet
color: yellow
tools: Glob, Grep, LS, Read, NotebookRead, WebFetch, TodoWrite, WebSearch, KillShell, BashOutput
skills:
  - fastapi-conventions
  - python-quality
```

System prompt focuses on:
- Tracing HTTP request flow: endpoint -> router -> dependency injection -> service -> repository -> ORM model -> DB
- Identifying: Pydantic schemas (request/response), SQLAlchemy/SQLModel models, Alembic migrations
- Mapping: middleware chain, exception handlers, background tasks, event handlers
- Documenting: auth patterns, pagination, filtering, sorting, CORS config
- Output: entry points with file:line, execution flow, key components, architecture insights, essential files list

#### fastapi-architect.md

```yaml
name: fastapi-architect
description: Designs FastAPI feature architectures by analyzing existing codebase patterns and conventions, then providing implementation blueprints with specific files to create/modify, endpoint designs, schema definitions, and migration strategies.
model: sonnet
color: green
tools: Glob, Grep, LS, Read, NotebookRead, WebFetch, TodoWrite, WebSearch, KillShell, BashOutput
skills:
  - fastapi-conventions
  - fastapi-testing
  - python-quality
```

System prompt focuses on:
- Extracting existing patterns: router structure, service layer, repository pattern, schema conventions
- Designing: new endpoints, Pydantic schemas, service methods, repository queries
- Planning: Alembic migrations, dependency injection, background tasks
- Output: patterns found, architecture decision, component design, implementation map, data flow, build sequence

#### fastapi-reviewer.md

```yaml
name: fastapi-reviewer
description: Reviews FastAPI code for bugs, security vulnerabilities, performance issues, and adherence to project conventions. Uses confidence-based filtering to report only high-priority issues.
model: sonnet
color: red
tools: Glob, Grep, LS, Read, NotebookRead, WebFetch, TodoWrite, WebSearch, KillShell, BashOutput
skills:
  - fastapi-conventions
  - fastapi-testing
  - python-quality
```

System prompt focuses on:
- Checking: ruff compliance, type annotations, Pydantic v2 patterns, async correctness
- Detecting: SQL injection, N+1 queries, sync-in-async, missing response models, unvalidated input
- Evaluating: error handling, test coverage, dependency injection usage
- Confidence scoring: only report issues >= 80 confidence
- Output: issues grouped by severity (Critical/Important) with file:line, confidence score, fix suggestions

### 5.2 React Agents

#### react-explorer.md

Same structure as fastapi-explorer but focused on:
- Tracing: UI component -> hooks -> state management -> API calls -> response handling
- Identifying: component hierarchy, shared hooks, context providers, routing, lazy loading
- Mapping: state flow, prop drilling vs context, API integration patterns
- Documenting: form handling, error boundaries, accessibility patterns

#### react-architect.md

Same structure as fastapi-architect but focused on:
- Designing: component composition, custom hooks, state management approach
- Planning: route structure, code splitting, API integration, form handling
- Considering: bundle size, accessibility, responsive design, error boundaries

#### react-reviewer.md

Same structure as fastapi-reviewer but focused on:
- Checking: ESLint compliance, TypeScript strict mode, React best practices
- Detecting: unnecessary re-renders, missing cleanup in useEffect, XSS vulnerabilities, missing keys
- Evaluating: accessibility, error handling, component composition, test coverage

## 6. Skills (Best Practices Reference)

### 6.1 FastAPI Skills

#### fastapi-conventions/SKILL.md

```yaml
name: fastapi-conventions
description: FastAPI project conventions and patterns. Loaded by agents to understand project structure, router organization, service patterns, and schema conventions.
```

Content covers:
- **Project structure**: `app/api/v1/`, `app/services/`, `app/repositories/`, `app/models/`, `app/schemas/`
- **Router patterns**: versioned routes, dependency injection, response models
- **Service layer**: business logic separation, transaction management
- **Repository pattern**: database queries, pagination, filtering
- **Schema conventions**: request/response models, validators, serialization
- **Error handling**: custom exceptions, exception handlers, error response format
- **Auth patterns**: JWT middleware, permission dependencies, role-based access
- **Configuration**: pydantic-settings, environment variables

#### fastapi-testing/SKILL.md

```yaml
name: fastapi-testing
description: FastAPI testing patterns and conventions. Loaded by agents to understand test structure, fixtures, and testing best practices.
```

Content covers:
- **Fixtures**: test client (httpx.AsyncClient), test database, auth fixtures
- **Test structure**: arrange-act-assert, naming conventions
- **Async testing**: pytest-asyncio configuration, async fixtures
- **Factory patterns**: factory_boy or custom factories for test data
- **Database isolation**: transaction rollback, test database setup/teardown
- **API testing**: endpoint tests, validation tests, auth tests
- **Mocking**: external service mocks, dependency overrides

#### python-quality/SKILL.md

```yaml
name: python-quality
description: Python code quality standards including linting, formatting, and type checking conventions.
```

Content covers:
- **Ruff**: enabled rules, ignored rules, per-file overrides
- **Black**: line length, target version
- **Mypy**: strict mode settings, plugin configuration
- **Import ordering**: isort conventions (handled by ruff)
- **Type annotations**: function signatures, variable annotations, generic types
- **Docstrings**: Google style, required for public APIs
- **Logging**: structured logging, log levels, context

### 6.2 React Skills

#### react-conventions/SKILL.md

Content covers:
- **Component patterns**: functional only, composition, render props, compound components
- **Folder structure**: feature-based organization
- **State management**: local state, Zustand/Redux Toolkit, React Query for server state
- **API integration**: custom hooks, error handling, loading states
- **Routing**: React Router conventions, protected routes, lazy loading
- **Form handling**: React Hook Form, Zod validation
- **Naming conventions**: components PascalCase, hooks use* prefix, utils camelCase

#### react-testing/SKILL.md

Content covers:
- **Component tests**: render, user events, assertions with Testing Library
- **Hook tests**: renderHook patterns
- **API mocking**: MSW setup, handlers, server lifecycle
- **Integration tests**: multi-component flows, routing tests
- **Accessibility**: axe-core integration, aria testing

#### typescript-quality/SKILL.md

Content covers:
- **ESLint**: enabled rules, React-specific rules, import rules
- **Prettier**: configuration
- **TypeScript**: strict mode, no-any policy, utility types, discriminated unions
- **Import conventions**: absolute paths, barrel exports

## 7. Hooks

### 7.1 FastAPI Hooks (hooks/hooks.json)

```json
{
  "description": "Auto-lint and format Python files after edits",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/lint-python.sh",
            "timeout": 30,
            "statusMessage": "Linting Python..."
          }
        ]
      }
    ]
  }
}
```

### scripts/lint-python.sh

```bash
#!/bin/bash
# Auto-lint Python files after Claude edits them

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')

# Only process Python files
if [[ "$FILE_PATH" != *.py ]]; then
  exit 0
fi

# Check if file exists
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Run ruff check with auto-fix
RUFF_OUTPUT=$(ruff check --fix "$FILE_PATH" 2>&1)
RUFF_EXIT=$?

# Run black formatting
BLACK_OUTPUT=$(black --quiet "$FILE_PATH" 2>&1)
BLACK_EXIT=$?

# Report issues back to Claude
if [[ $RUFF_EXIT -ne 0 ]]; then
  echo "Ruff found issues in $FILE_PATH:" >&2
  echo "$RUFF_OUTPUT" >&2
  exit 2
fi

exit 0
```

### 7.2 React Hooks (hooks/hooks.json)

```json
{
  "description": "Auto-lint and format TypeScript/React files after edits",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/lint-react.sh",
            "timeout": 30,
            "statusMessage": "Linting React..."
          }
        ]
      }
    ]
  }
}
```

### scripts/lint-react.sh

```bash
#!/bin/bash
# Auto-lint TypeScript/React files after Claude edits them

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')

# Only process TS/TSX/JSX files
if [[ "$FILE_PATH" != *.ts && "$FILE_PATH" != *.tsx && "$FILE_PATH" != *.jsx ]]; then
  exit 0
fi

if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Run eslint with auto-fix
ESLINT_OUTPUT=$(npx eslint --fix "$FILE_PATH" 2>&1)
ESLINT_EXIT=$?

# Run prettier
PRETTIER_OUTPUT=$(npx prettier --write "$FILE_PATH" 2>&1)

if [[ $ESLINT_EXIT -ne 0 ]]; then
  echo "ESLint found issues in $FILE_PATH:" >&2
  echo "$ESLINT_OUTPUT" >&2
  exit 2
fi

exit 0
```

## 8. Workflow Command (8-Phase Orchestration)

The command file (`commands/feature-dev.md`) defines the `/fastapi-dev:feature-dev` (or `/react-dev:feature-dev`) slash command.

### 8-Phase Workflow

#### Phase 1: Discovery
- Create todo list with all 8 phases
- If feature description is vague, ask clarifying questions
- Summarize understanding and confirm with user
- **Output**: Confirmed feature requirements

#### Phase 2: Codebase Exploration
- Launch **2-3 explorer agents in parallel**
- Each targets different aspects:
  - Similar features and their implementations
  - High-level architecture and relevant abstractions
  - Testing patterns, extension points, integration opportunities
- Each agent identifies **5-10 key files** to read
- Read all identified files to build full context
- Present comprehensive findings and patterns to user
- **Output**: Codebase understanding with key files identified

#### Phase 3: Clarifying Questions
- **HARD GATE**: Do not skip this phase
- Review findings and original requirements
- Identify underspecified aspects:
  - Edge cases and error scenarios
  - Integration points with existing code
  - Scope boundaries (what's in/out)
  - Design preferences
  - Backward compatibility concerns
  - Performance requirements
- Present organized list of questions
- **Wait for user answers** before proceeding
- **Output**: All ambiguities resolved

#### Phase 4: Architecture Design
- Launch **2-3 architect agents in parallel** with different focuses:
  - Minimal changes: smallest change, maximum reuse
  - Clean architecture: maintainability, elegant abstractions
  - Pragmatic balance: speed + quality
- Review all approaches
- Present to user:
  - Brief summary of each approach
  - Trade-offs comparison table
  - Recommendation with reasoning
  - Concrete implementation differences
- **Ask user which approach they prefer**
- **Output**: Chosen architecture approach

#### Phase 5: Design Document
- **HARD GATE**: Must produce and get approval before implementation
- Write a comprehensive design document using the **Design Document Template** (see Section 9)
- Covers:
  - Feature overview and requirements
  - Codebase context (findings from Phase 2)
  - Chosen architecture and rationale
  - Detailed file changes (create/modify/delete)
  - API contracts / Component hierarchy
  - Data flow
  - Migration strategy (if applicable)
  - Test plan
  - Rollback plan
- Present to user for review
- **User must explicitly approve** before Phase 6
- **Output**: Approved design document

#### Phase 6: Implementation
- **ONLY starts after design document approval**
- Follow the approved design document exactly
- Read all relevant files before modifying
- Implement following project conventions (enforced by skills)
- Hooks auto-lint/format as files are written
- Update todos as you progress
- **Output**: Working implementation

#### Phase 7: Quality Review
- Launch **3 reviewer agents in parallel** with focuses on:
  - Simplicity / DRY / elegance
  - Bugs / functional correctness / security
  - Project conventions / abstractions / patterns
- Consolidate findings
- Identify highest-severity issues
- Present findings to user
- Ask what they want to do:
  - Fix critical issues now
  - Fix later (create TODO comments)
  - Proceed as-is
- **Output**: Reviewed, approved code

#### Phase 8: Summary
- Mark all todos complete
- Summarize:
  - What was built
  - Key decisions made
  - Files created/modified
  - Tests added
  - Suggested next steps
- **Output**: Implementation summary

## 9. Design Document Template

The Design Document produced in Phase 5 follows this consistent template:

```markdown
# Design Document: [Feature Name]

**Date**: YYYY-MM-DD
**Author**: Claude (with user guidance)
**Status**: Pending Approval

## 1. Overview
Brief description of the feature and its purpose.

## 2. Requirements
- Functional requirements (from Phase 1 & 3)
- Non-functional requirements (performance, security, etc.)
- Out of scope

## 3. Codebase Context
Key findings from codebase exploration:
- Relevant existing patterns
- Similar features found
- Integration points identified

## 4. Architecture Decision

### Chosen Approach
Description of the selected architecture.

### Rationale
Why this approach was chosen over alternatives.

### Trade-offs
What we gain and what we accept.

## 5. Detailed Design

### Files to Create
| File Path | Purpose |
|-----------|---------|
| `path/to/file.py` | Description |

### Files to Modify
| File Path | Changes |
|-----------|---------|
| `path/to/existing.py` | Description of changes |

### API Contracts (for backend)
- Endpoint definitions with request/response schemas
- Or component hierarchy (for frontend)

### Data Flow
Step-by-step flow from input to output.

### Database Changes (if applicable)
- New tables/columns
- Migration strategy
- Data backfill plan

## 6. Test Plan
- Unit tests to write
- Integration tests to write
- Edge cases to cover

## 7. Rollback Plan
How to revert if something goes wrong.

## 8. Open Questions
Any remaining uncertainties (should be empty before approval).
```

## 10. Plugin Marketplace

### marketplace.json

```json
{
  "plugins": [
    {
      "name": "fastapi-dev",
      "description": "Feature development workflow for Python/FastAPI projects",
      "directory": "plugins/fastapi-dev"
    },
    {
      "name": "react-dev",
      "description": "Feature development workflow for ReactJS/TypeScript projects",
      "directory": "plugins/react-dev"
    }
  ]
}
```

### Installation

Team members install via:
```bash
# Add the marketplace (one-time)
claude /plugin marketplace add https://github.com/alfalabs/claude-implementation-workflow

# Install plugins
claude /plugin install fastapi-dev
claude /plugin install react-dev
```

## 11. Customization

### Adding project-specific rules

Teams can customize the skills by editing the SKILL.md files in each skill folder. Common customizations:
- Add project-specific folder structure conventions
- Add company-specific naming conventions
- Add custom linting rules
- Add project-specific testing patterns

### Adding new hooks

Add entries to `hooks/hooks.json` in the relevant plugin. Common additions:
- Run type checker (mypy/tsc) after edits
- Run security scanner after implementation
- Notify team channel on completion

## 12. Success Criteria

- Consistent 8-phase workflow followed for every feature
- No implementation starts without an approved design document
- Auto-linting catches formatting issues before review
- Explorer agents identify relevant patterns in existing code
- Architect agents propose multiple approaches with trade-offs
- Reviewer agents catch real issues (>= 80 confidence threshold)
- Team members can install and use within 5 minutes
