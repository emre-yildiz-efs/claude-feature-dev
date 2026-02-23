# Implementation Workflow Plugin — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build two Claude Code plugins (fastapi-dev, react-dev) that provide an 8-phase feature development workflow with specialized agents, best practice skills, and auto-linting hooks, distributed as a GitHub plugin marketplace.

**Architecture:** Two self-contained plugins in a single repo, each with 3 agents (explorer, architect, reviewer), 3 skills (conventions, testing, code quality), hooks (PostToolUse lint/format), and 1 orchestration command. Modeled after Anthropic's feature-dev plugin.

**Tech Stack:** Claude Code plugins (Markdown + YAML frontmatter), Bash scripts (hooks), JSON (plugin manifests, hooks config, marketplace)

**Design Document:** `docs/plans/2026-02-23-implementation-workflow-plugin-design.md`

---

### Task 1: Scaffold Directory Structure

**Files:**
- Create: all directories for both plugins

**Step 1: Create all directories**

```bash
mkdir -p plugins/fastapi-dev/.claude-plugin
mkdir -p plugins/fastapi-dev/agents
mkdir -p plugins/fastapi-dev/commands
mkdir -p plugins/fastapi-dev/skills/fastapi-conventions
mkdir -p plugins/fastapi-dev/skills/fastapi-testing
mkdir -p plugins/fastapi-dev/skills/python-quality
mkdir -p plugins/fastapi-dev/hooks
mkdir -p plugins/fastapi-dev/scripts
mkdir -p plugins/react-dev/.claude-plugin
mkdir -p plugins/react-dev/agents
mkdir -p plugins/react-dev/commands
mkdir -p plugins/react-dev/skills/react-conventions
mkdir -p plugins/react-dev/skills/react-testing
mkdir -p plugins/react-dev/skills/typescript-quality
mkdir -p plugins/react-dev/hooks
mkdir -p plugins/react-dev/scripts
```

**Step 2: Verify structure**

Run: `find plugins -type d | sort`
Expected: All 16+ directories listed

**Step 3: Commit**

```bash
git add plugins/
git commit -m "scaffold: create directory structure for fastapi-dev and react-dev plugins"
```

---

### Task 2: Plugin Manifests & Marketplace

**Files:**
- Create: `plugins/fastapi-dev/.claude-plugin/plugin.json`
- Create: `plugins/react-dev/.claude-plugin/plugin.json`
- Create: `marketplace.json`

**Step 1: Create fastapi-dev plugin.json**

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

**Step 2: Create react-dev plugin.json**

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

**Step 3: Create marketplace.json**

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

**Step 4: Commit**

```bash
git add plugins/fastapi-dev/.claude-plugin/plugin.json plugins/react-dev/.claude-plugin/plugin.json marketplace.json
git commit -m "feat: add plugin manifests and marketplace configuration"
```

---

### Task 3: FastAPI Explorer Agent

**Files:**
- Create: `plugins/fastapi-dev/agents/fastapi-explorer.md`

**Step 1: Write the agent file**

The agent frontmatter defines: name, description, model (sonnet), color (yellow), tools (read-only + BashOutput), skills to preload (fastapi-conventions, python-quality).

The system prompt body instructs the agent to:
- Trace HTTP request flow: endpoint → router → dependency injection → service → repository → ORM model → DB
- Identify Pydantic schemas, SQLAlchemy/SQLModel models, Alembic migrations
- Map middleware chain, exception handlers, background tasks, event handlers
- Document auth patterns, pagination, filtering, sorting, CORS config
- Output format: entry points with file:line, execution flow, key components, architecture insights, 5-10 essential files list

Reference the feature-dev code-explorer.md for structure. Adapt the system prompt to FastAPI domain expertise.

**Step 2: Commit**

```bash
git add plugins/fastapi-dev/agents/fastapi-explorer.md
git commit -m "feat: add fastapi-explorer agent with domain-specific system prompt"
```

---

### Task 4: FastAPI Architect Agent

**Files:**
- Create: `plugins/fastapi-dev/agents/fastapi-architect.md`

**Step 1: Write the agent file**

Frontmatter: name fastapi-architect, model sonnet, color green, same tools, skills: fastapi-conventions, fastapi-testing, python-quality.

System prompt instructs the agent to:
- Extract existing patterns: router structure, service layer, repository pattern, schema conventions
- Design new endpoints, Pydantic schemas, service methods, repository queries
- Plan Alembic migrations, dependency injection, background tasks
- Make confident, decisive architectural choices (not wishy-washy)
- Output format: patterns found (with file:line), architecture decision, component design, implementation map, data flow, build sequence as checklist

Reference feature-dev code-architect.md for structure.

**Step 2: Commit**

```bash
git add plugins/fastapi-dev/agents/fastapi-architect.md
git commit -m "feat: add fastapi-architect agent with implementation blueprint capabilities"
```

---

### Task 5: FastAPI Reviewer Agent

**Files:**
- Create: `plugins/fastapi-dev/agents/fastapi-reviewer.md`

**Step 1: Write the agent file**

Frontmatter: name fastapi-reviewer, model sonnet, color red, same tools, skills: fastapi-conventions, fastapi-testing, python-quality.

System prompt instructs the agent to:
- Check ruff compliance, type annotations, Pydantic v2 patterns, async correctness
- Detect SQL injection, N+1 queries, sync-in-async, missing response models, unvalidated input
- Evaluate error handling, test coverage, dependency injection usage
- Use confidence scoring system (0-100, only report >= 80):
  - 0: false positive
  - 25: might be real
  - 50: real but nitpick
  - 75: highly confident, verified
  - 100: absolutely certain
- Output format: issues grouped by severity (Critical/Important) with file:line, confidence score, fix suggestions

Reference feature-dev code-reviewer.md for structure.

**Step 2: Commit**

```bash
git add plugins/fastapi-dev/agents/fastapi-reviewer.md
git commit -m "feat: add fastapi-reviewer agent with confidence-based issue filtering"
```

---

### Task 6: React Explorer Agent

**Files:**
- Create: `plugins/react-dev/agents/react-explorer.md`

**Step 1: Write the agent file**

Same structure as fastapi-explorer but React-focused. Frontmatter: name react-explorer, model sonnet, color yellow, same tools, skills: react-conventions, typescript-quality.

System prompt focuses on:
- Trace UI component → hooks → state management → API calls → response handling
- Identify component hierarchy, shared hooks, context providers, routing, lazy loading
- Map state flow, prop drilling vs context, API integration patterns
- Document form handling, error boundaries, accessibility patterns
- Output: same structured format with file:line references

**Step 2: Commit**

```bash
git add plugins/react-dev/agents/react-explorer.md
git commit -m "feat: add react-explorer agent with component tracing capabilities"
```

---

### Task 7: React Architect Agent

**Files:**
- Create: `plugins/react-dev/agents/react-architect.md`

**Step 1: Write the agent file**

Frontmatter: name react-architect, model sonnet, color green, skills: react-conventions, react-testing, typescript-quality.

System prompt focuses on:
- Design component composition, custom hooks, state management approach
- Plan route structure, code splitting, API integration, form handling
- Consider bundle size, accessibility, responsive design, error boundaries
- Same decisive, blueprint-style output as fastapi-architect

**Step 2: Commit**

```bash
git add plugins/react-dev/agents/react-architect.md
git commit -m "feat: add react-architect agent with component architecture design"
```

---

### Task 8: React Reviewer Agent

**Files:**
- Create: `plugins/react-dev/agents/react-reviewer.md`

**Step 1: Write the agent file**

Frontmatter: name react-reviewer, model sonnet, color red, skills: react-conventions, react-testing, typescript-quality.

System prompt focuses on:
- Check ESLint compliance, TypeScript strict mode, React best practices
- Detect unnecessary re-renders, missing cleanup in useEffect, XSS, missing keys
- Evaluate accessibility, error handling, component composition, test coverage
- Same confidence scoring system as fastapi-reviewer

**Step 2: Commit**

```bash
git add plugins/react-dev/agents/react-reviewer.md
git commit -m "feat: add react-reviewer agent with React-specific quality checks"
```

---

### Task 9: FastAPI Conventions Skill

**Files:**
- Create: `plugins/fastapi-dev/skills/fastapi-conventions/SKILL.md`

**Step 1: Write the skill**

YAML frontmatter with name and description. Body covers:
- Project structure patterns (`app/api/v1/`, `app/services/`, `app/repositories/`, `app/models/`, `app/schemas/`)
- Router patterns with code examples (versioned routes, dependency injection, response models)
- Service layer pattern with code examples (business logic separation, transaction management)
- Repository pattern with code examples (database queries, pagination, filtering)
- Schema conventions with code examples (request/response Pydantic models, validators)
- Error handling patterns (custom exceptions, exception handlers, error response format)
- Auth patterns (JWT middleware, permission dependencies)
- Configuration (pydantic-settings, env vars)

Each section should include a short code example showing the pattern.

**Step 2: Commit**

```bash
git add plugins/fastapi-dev/skills/fastapi-conventions/SKILL.md
git commit -m "feat: add fastapi-conventions skill with project patterns and code examples"
```

---

### Task 10: FastAPI Testing Skill

**Files:**
- Create: `plugins/fastapi-dev/skills/fastapi-testing/SKILL.md`

**Step 1: Write the skill**

YAML frontmatter. Body covers with code examples:
- Fixtures (httpx.AsyncClient test client, test database, auth fixtures)
- Test structure (arrange-act-assert, naming: `test_<action>_<condition>_<expected>`)
- Async testing (pytest-asyncio config, async fixtures)
- Factory patterns (factory_boy or dataclass factories)
- Database isolation (transaction rollback strategy)
- API endpoint testing (status codes, response validation, error cases)
- Mocking (FastAPI dependency overrides, external service mocks)

**Step 2: Commit**

```bash
git add plugins/fastapi-dev/skills/fastapi-testing/SKILL.md
git commit -m "feat: add fastapi-testing skill with pytest patterns and fixtures"
```

---

### Task 11: Python Quality Skill

**Files:**
- Create: `plugins/fastapi-dev/skills/python-quality/SKILL.md`

**Step 1: Write the skill**

YAML frontmatter. Body covers:
- Ruff rules and configuration (enabled rule sets, common ignores)
- Black formatting (line length 88, target version)
- Mypy strict mode (settings, plugin config for Pydantic)
- Import ordering (isort via ruff, sections)
- Type annotations (function signatures, variables, generics, Optional vs `| None`)
- Docstrings (Google style, when required)
- Logging conventions (structlog or stdlib, levels, context)

**Step 2: Commit**

```bash
git add plugins/fastapi-dev/skills/python-quality/SKILL.md
git commit -m "feat: add python-quality skill with linting and type checking standards"
```

---

### Task 12: React Conventions Skill

**Files:**
- Create: `plugins/react-dev/skills/react-conventions/SKILL.md`

**Step 1: Write the skill**

YAML frontmatter. Body covers with code examples:
- Component patterns (functional only, composition, render props)
- Folder structure (feature-based organization)
- State management (local state, Zustand/Redux Toolkit, React Query)
- API integration (custom hooks with error/loading states)
- Routing (React Router, protected routes, lazy loading)
- Form handling (React Hook Form + Zod)
- Naming conventions (PascalCase components, use* hooks, camelCase utils)

**Step 2: Commit**

```bash
git add plugins/react-dev/skills/react-conventions/SKILL.md
git commit -m "feat: add react-conventions skill with component patterns and code examples"
```

---

### Task 13: React Testing Skill

**Files:**
- Create: `plugins/react-dev/skills/react-testing/SKILL.md`

**Step 1: Write the skill**

YAML frontmatter. Body covers with code examples:
- Component tests (render, user events, assertions with @testing-library/react)
- Hook tests (renderHook patterns)
- API mocking (MSW setup, request handlers, server lifecycle)
- Integration tests (multi-component flows, routing tests)
- Accessibility testing (axe-core, aria queries)
- Test file naming and organization

**Step 2: Commit**

```bash
git add plugins/react-dev/skills/react-testing/SKILL.md
git commit -m "feat: add react-testing skill with Testing Library and MSW patterns"
```

---

### Task 14: TypeScript Quality Skill

**Files:**
- Create: `plugins/react-dev/skills/typescript-quality/SKILL.md`

**Step 1: Write the skill**

YAML frontmatter. Body covers:
- ESLint config (enabled rules, React-specific rules, import rules)
- Prettier config (semi, singleQuote, trailingComma, printWidth)
- TypeScript strict mode (noImplicitAny, strictNullChecks, strict)
- No-any policy (use `unknown`, generics, or specific types)
- Utility types (Pick, Omit, Partial, Record, discriminated unions)
- Import conventions (absolute paths via tsconfig paths, barrel exports)

**Step 2: Commit**

```bash
git add plugins/react-dev/skills/typescript-quality/SKILL.md
git commit -m "feat: add typescript-quality skill with ESLint and strict TypeScript standards"
```

---

### Task 15: FastAPI Hooks & Lint Script

**Files:**
- Create: `plugins/fastapi-dev/hooks/hooks.json`
- Create: `plugins/fastapi-dev/scripts/lint-python.sh`

**Step 1: Write hooks.json**

PostToolUse hook matching Write|Edit, running lint-python.sh via `${CLAUDE_PLUGIN_ROOT}/scripts/lint-python.sh`, 30s timeout, status message "Linting Python..."

Content exactly as specified in design doc Section 7.1.

**Step 2: Write lint-python.sh**

Bash script that:
1. Reads JSON from stdin
2. Extracts file_path from tool_input or tool_response
3. Exits 0 if not a .py file or file doesn't exist
4. Runs `ruff check --fix` on the file
5. Runs `black --quiet` on the file
6. If ruff fails, outputs errors to stderr and exits 2 (feeds back to Claude)
7. Otherwise exits 0

Content exactly as specified in design doc Section 7.1.

**Step 3: Make script executable**

Run: `chmod +x plugins/fastapi-dev/scripts/lint-python.sh`

**Step 4: Commit**

```bash
git add plugins/fastapi-dev/hooks/hooks.json plugins/fastapi-dev/scripts/lint-python.sh
git commit -m "feat: add PostToolUse hook for auto-linting Python files with ruff and black"
```

---

### Task 16: React Hooks & Lint Script

**Files:**
- Create: `plugins/react-dev/hooks/hooks.json`
- Create: `plugins/react-dev/scripts/lint-react.sh`

**Step 1: Write hooks.json**

Same structure as fastapi-dev but running lint-react.sh. Status message "Linting React..."

Content exactly as specified in design doc Section 7.2.

**Step 2: Write lint-react.sh**

Bash script that:
1. Reads JSON from stdin
2. Extracts file_path
3. Exits 0 if not .ts/.tsx/.jsx or file doesn't exist
4. Runs `npx eslint --fix`
5. Runs `npx prettier --write`
6. If eslint fails, outputs errors to stderr and exits 2
7. Otherwise exits 0

Content exactly as specified in design doc Section 7.2.

**Step 3: Make script executable**

Run: `chmod +x plugins/react-dev/scripts/lint-react.sh`

**Step 4: Commit**

```bash
git add plugins/react-dev/hooks/hooks.json plugins/react-dev/scripts/lint-react.sh
git commit -m "feat: add PostToolUse hook for auto-linting React files with ESLint and Prettier"
```

---

### Task 17: FastAPI Workflow Command

**Files:**
- Create: `plugins/fastapi-dev/commands/feature-dev.md`

**Step 1: Write the command file**

This is the main orchestration command invoked via `/fastapi-dev:feature-dev`.

Structure it with:
- Description at top (what it does, when to use)
- Core principles (ask first, understand patterns, design before code)
- 8-phase workflow with detailed instructions per phase
- Phase 1 (Discovery): create todo list, ask clarifying questions, confirm requirements
- Phase 2 (Codebase Exploration): launch 2-3 fastapi-explorer agents in parallel, each targeting different aspects, read identified files
- Phase 3 (Clarifying Questions): HARD GATE, identify underspecified aspects, wait for answers
- Phase 4 (Architecture Design): launch 2-3 fastapi-architect agents in parallel (minimal/clean/pragmatic), present comparison, user picks
- Phase 5 (Design Document): HARD GATE, write design doc using template, present for approval
- Phase 6 (Implementation): ONLY after approval, follow design doc, hooks auto-lint
- Phase 7 (Quality Review): launch 3 fastapi-reviewer agents in parallel, consolidate findings
- Phase 8 (Summary): document what was built

Include the Design Document Template inline in the command so agents have it available.

Model after the feature-dev plugin's `commands/feature-dev.md` structure but with 8 phases instead of 7.

**Step 2: Commit**

```bash
git add plugins/fastapi-dev/commands/feature-dev.md
git commit -m "feat: add 8-phase feature-dev workflow command for FastAPI plugin"
```

---

### Task 18: React Workflow Command

**Files:**
- Create: `plugins/react-dev/commands/feature-dev.md`

**Step 1: Write the command file**

Same 8-phase structure as fastapi-dev but:
- Phase 2 uses react-explorer agents (trace components, hooks, state)
- Phase 4 uses react-architect agents (component architecture)
- Phase 5 design doc template uses "Component Hierarchy" instead of "API Contracts"
- Phase 7 uses react-reviewer agents (React-specific checks)
- All agent references use react-* names

**Step 2: Commit**

```bash
git add plugins/react-dev/commands/feature-dev.md
git commit -m "feat: add 8-phase feature-dev workflow command for React plugin"
```

---

### Task 19: README

**Files:**
- Create: `README.md`

**Step 1: Write comprehensive README**

Sections:
- Project title and one-line description
- What this is (two Claude Code plugins for implementation workflows)
- Features (8-phase workflow, specialized agents, best practices, auto-linting)
- Quick Start (install from marketplace or --plugin-dir)
- Plugin overview (fastapi-dev and react-dev with what each includes)
- Workflow phases (brief description of all 8 phases)
- Customization (how to edit skills for your project)
- Contributing
- License

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add comprehensive README with installation and usage guide"
```

---

### Task 20: Smoke Test — FastAPI Plugin

**Step 1: Load fastapi-dev plugin and verify**

Run: `claude --plugin-dir ./plugins/fastapi-dev`

In the Claude session:
- Run `/help` and verify `/fastapi-dev:feature-dev` appears
- Run `/agents` and verify fastapi-explorer, fastapi-architect, fastapi-reviewer appear
- Type `/fastapi-dev:feature-dev` and verify the workflow starts

**Step 2: Fix any issues found**

If skills don't load, check SKILL.md naming and frontmatter.
If agents don't appear, check agent file frontmatter fields.
If hooks error, check hooks.json path references.

**Step 3: Commit any fixes**

```bash
git add -A
git commit -m "fix: resolve issues found during fastapi-dev plugin smoke test"
```

---

### Task 21: Smoke Test — React Plugin

**Step 1: Load react-dev plugin and verify**

Run: `claude --plugin-dir ./plugins/react-dev`

Same verification as Task 20 but for react-dev:
- `/react-dev:feature-dev` appears in help
- react-explorer, react-architect, react-reviewer in agents
- Workflow starts correctly

**Step 2: Fix any issues**

**Step 3: Commit any fixes**

```bash
git add -A
git commit -m "fix: resolve issues found during react-dev plugin smoke test"
```

---

### Task 22: Final Commit & Summary

**Step 1: Review all files**

Run: `find plugins -type f | sort` to verify complete file list matches design doc.

**Step 2: Run git log to verify commit history**

Run: `git log --oneline`

Expected: ~15-20 clean commits, each one focused on a single component.

**Step 3: Tag the release**

```bash
git tag -a v1.0.0 -m "Initial release: fastapi-dev and react-dev plugins"
```

---

## Build Sequence Summary

| Task | Component | Plugin | Depends On |
|------|-----------|--------|------------|
| 1 | Directory scaffold | Both | — |
| 2 | Plugin manifests + marketplace | Both | 1 |
| 3-5 | FastAPI agents (explorer, architect, reviewer) | fastapi-dev | 1 |
| 6-8 | React agents (explorer, architect, reviewer) | react-dev | 1 |
| 9-11 | FastAPI skills (conventions, testing, quality) | fastapi-dev | 1 |
| 12-14 | React skills (conventions, testing, quality) | react-dev | 1 |
| 15 | FastAPI hooks + lint script | fastapi-dev | 1 |
| 16 | React hooks + lint script | react-dev | 1 |
| 17 | FastAPI workflow command | fastapi-dev | 3-5, 9-11, 15 |
| 18 | React workflow command | react-dev | 6-8, 12-14, 16 |
| 19 | README | Both | 17, 18 |
| 20 | Smoke test FastAPI | fastapi-dev | 17 |
| 21 | Smoke test React | react-dev | 18 |
| 22 | Final review + tag | Both | 20, 21 |

**Parallelization opportunities:**
- Tasks 3-5 and 6-8 can run in parallel (agents for both plugins)
- Tasks 9-11 and 12-14 can run in parallel (skills for both plugins)
- Tasks 15 and 16 can run in parallel (hooks for both plugins)
- Tasks 17 and 18 can run in parallel (workflow commands)
- Tasks 20 and 21 can run in parallel (smoke tests)
