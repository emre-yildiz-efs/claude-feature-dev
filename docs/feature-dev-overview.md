# Feature-Dev: AI-Powered Development Workflow

**AlfaLabs Engineering** | February 2026

---

## The Problem

When AI assistants write code, they skip steps. No upfront analysis. No architecture review. No design approval. They jump straight to implementation, producing inconsistent quality across sessions and ignoring project conventions that the team spent months establishing.

**The result:** Developers spend more time reviewing and fixing AI-generated code than they save by using AI in the first place.

---

## The Solution

**Feature-Dev** is a plugin system for Claude Code that enforces a structured, 8-phase development workflow. It deploys specialized AI agents at each phase, embeds your team's best practices directly into the AI's context, and requires human approval at critical decision points.

Two plugins ship today:

| Plugin | Target Stack | Auto-Linting |
|--------|-------------|--------------|
| **fastapi-dev** | Python / FastAPI backends | ruff + black |
| **react-dev** | React / TypeScript frontends | eslint + prettier |

A single command launches the entire workflow:

```
/fastapi-dev:feature-dev Add user authentication with JWT
/react-dev:feature-dev Add dashboard page with data grid
```

---

## How It Works

### The 8-Phase Workflow

```
                    UNDERSTAND                          BUILD
     ┌──────────────────────────────────┐  ┌──────────────────────────┐
     │                                  │  │                          │
     │  ┌───────┐    ┌──────────────┐   │  │  ┌────────────────┐     │
     │  │Phase 1│───>│   Phase 2    │   │  │  │    Phase 6     │     │
     │  │Discov-│    │  Codebase    │   │  │  │ Implementation │     │
     │  │ery    │    │ Exploration  │   │  │  │                │     │
     │  └───────┘    │ ┌──┐┌──┐┌──┐│   │  │  │  Design doc    │     │
     │               │ │E1││E2││E3││   │  │  │  guides every   │     │
     │               │ └──┘└──┘└──┘│   │  │  │  line of code   │     │
     │               └──────┬───────┘   │  │  └───────┬────────┘     │
     │                      v           │  │          v              │
     │  ┌────────────────────────────┐  │  │  ┌────────────────┐     │
     │  │        Phase 3             │  │  │  │    Phase 7     │     │
     │  │  Clarifying Questions      │  │  │  │ Quality Review │     │
     │  │                            │  │  │  │ ┌──┐┌──┐┌──┐  │     │
     │  │  ██ HARD GATE ██           │  │  │  │ │R1││R2││R3│  │     │
     │  │  All ambiguities resolved  │  │  │  │ └──┘└──┘└──┘  │     │
     │  │  before proceeding         │  │  │  └───────┬────────┘     │
     │  └────────────┬───────────────┘  │  │          v              │
     │               v                  │  │  ┌────────────────┐     │
     │               │                  │  │  │    Phase 8     │     │
     │               │                  │  │  │    Summary     │     │
     │               │                  │  │  └────────────────┘     │
     └───────────────┼──────────────────┘  └──────────────────────────┘
                     v
              DESIGN & APPROVE
     ┌──────────────────────────────────┐
     │                                  │
     │  ┌────────────────────────────┐  │
     │  │        Phase 4             │  │
     │  │  Architecture Design       │  │
     │  │  ┌──┐┌──┐┌──┐             │  │
     │  │  │A1││A2││A3│  3 options   │  │
     │  │  └──┘└──┘└──┘  presented   │  │
     │  └────────────┬───────────────┘  │
     │               v                  │
     │  ┌────────────────────────────┐  │
     │  │        Phase 5             │  │
     │  │  Design Document           │  │
     │  │                            │  │
     │  │  ██ HARD GATE ██           │  │
     │  │  Written approval          │  │
     │  │  required before any       │  │
     │  │  code is written           │  │
     │  └────────────────────────────┘  │
     │                                  │
     └──────────────────────────────────┘

     E = Explorer Agent    A = Architect Agent    R = Reviewer Agent
```

### What Happens at Each Phase

| Phase | What Happens | Who Decides |
|-------|-------------|-------------|
| **1. Discovery** | AI clarifies the feature request, confirms scope | Developer confirms understanding |
| **2. Codebase Exploration** | 2-3 explorer agents analyze the existing codebase in parallel | AI identifies patterns and key files |
| **3. Clarifying Questions** | AI surfaces every ambiguity, edge case, and scope question | **Developer answers all questions** |
| **4. Architecture Design** | 2-3 architect agents propose different approaches with trade-offs | **Developer picks the approach** |
| **5. Design Document** | AI writes a full design doc (requirements, API contracts, test plan, rollback plan) | **Developer must approve** |
| **6. Implementation** | AI writes code following the approved design; hooks auto-lint every file | AI implements, hooks enforce quality |
| **7. Quality Review** | 3 reviewer agents inspect for bugs, security issues, and convention violations | **Developer decides what to fix** |
| **8. Summary** | AI documents what was built, decisions made, and next steps | Delivered to developer |

**Key insight:** The developer stays in control at every critical decision point. The AI never writes code without an approved design.

---

## The Agent System

Each plugin deploys **3 specialized AI agents** — each with its own expertise, tools, and embedded knowledge.

```
┌─────────────────────────────────────────────────────────────┐
│                    PLUGIN ARCHITECTURE                       │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                  COMMAND LAYER                       │    │
│  │          /feature-dev  (8-phase orchestrator)        │    │
│  └──────────────────────┬──────────────────────────────┘    │
│                         │                                   │
│           ┌─────────────┼─────────────┐                     │
│           v             v             v                     │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐        │
│  │   EXPLORER   │ │  ARCHITECT   │ │   REVIEWER   │        │
│  │   (yellow)   │ │   (green)    │ │    (red)     │        │
│  │              │ │              │ │              │        │
│  │  Traces code │ │  Designs     │ │  Reviews for │        │
│  │  execution   │ │  architecture│ │  bugs &      │        │
│  │  paths       │ │  blueprints  │ │  security    │        │
│  │              │ │              │ │              │        │
│  │  Phases 2    │ │  Phase 4     │ │  Phase 7     │        │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘        │
│         │                │                │                 │
│         v                v                v                 │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                   SKILLS LAYER                       │    │
│  │  Conventions  |  Testing Patterns  |  Quality Rules  │    │
│  │  (embedded best practices, loaded into each agent)   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                   HOOKS LAYER                        │    │
│  │  Auto-lint on every file write (ruff/black or        │    │
│  │  eslint/prettier) — zero manual intervention         │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Agent Capabilities

| Agent | Runs In | What It Does | Parallel Instances |
|-------|---------|-------------|-------------------|
| **Explorer** | Phase 2 | Traces execution paths through the codebase. Maps endpoints, services, models, migrations. Identifies 5-10 key files per focus area. | 2-3 simultaneous |
| **Architect** | Phase 4 | Proposes complete implementation blueprints. Specifies every file to create/modify, API contracts, data flow, and build sequence. | 2-3 simultaneous |
| **Reviewer** | Phase 7 | Scans for bugs, security vulnerabilities, and convention violations. Only reports issues with >= 80% confidence — no noise. | 3 simultaneous |

**Parallel execution is the key speed advantage.** Instead of one agent doing everything sequentially, multiple specialized agents work simultaneously and return consolidated results.

---

## Technical Showcase: What Each Agent Actually Produces

### Showcase 1: Explorer Agent Output

When an explorer agent analyzes an existing codebase, it produces structured analysis like:

```
### Entry Points
POST /api/v1/users/        app/api/v1/users.py:23    Create user
GET  /api/v1/users/{id}    app/api/v1/users.py:45    Get user by ID
PUT  /api/v1/users/{id}    app/api/v1/users.py:58    Update user

### Execution Flow
1. Request hits CORS middleware           (app/middleware/cors.py:12)
2. Auth dependency validates JWT          (app/dependencies/auth.py:34)
3. Route handler calls UserService        (app/services/user.py:67)
4. Service validates business rules       (app/services/user.py:78)
5. Repository executes SQL via SQLAlchemy (app/repositories/user.py:23)
6. Response serialized via Pydantic       (app/schemas/user.py:15)

### Essential Files
- app/api/v1/users.py          Router with all user endpoints
- app/services/user.py         Business logic layer
- app/repositories/user.py     Database query layer
- app/schemas/user.py          Request/response Pydantic models
- app/models/user.py           SQLAlchemy table definition
- alembic/versions/003_users   Migration that created the table
```

This gives the developer (and the AI) a complete map before any design work begins.

---

### Showcase 2: Architect Agent Trade-off Comparison

The architecture phase produces competing proposals:

```
┌──────────────────┬──────────────────┬──────────────────┐
│   APPROACH A     │   APPROACH B     │   APPROACH C     │
│   Minimal        │   Clean          │   Pragmatic      │
├──────────────────┼──────────────────┼──────────────────┤
│ Reuse existing   │ New service      │ New service      │
│ UserService,     │ layer, dedicated │ layer, reuse     │
│ add 2 methods    │ repository,      │ existing repo    │
│                  │ full separation  │ patterns         │
├──────────────────┼──────────────────┼──────────────────┤
│ Files changed: 3 │ Files changed: 8 │ Files changed: 5 │
│ New files: 1     │ New files: 5     │ New files: 3     │
├──────────────────┼──────────────────┼──────────────────┤
│ + Fast to build  │ + Most testable  │ + Good balance   │
│ + Low risk       │ + Clean layering │ + Follows exist- │
│ - Adds to exist- │ - More files     │   ing patterns   │
│   ing complexity │ - Longer to build│ - Minor refactor │
├──────────────────┼──────────────────┼──────────────────┤
│                  │                  │  * RECOMMENDED   │
└──────────────────┴──────────────────┴──────────────────┘
```

The developer picks. No surprises during implementation.

---

### Showcase 3: Design Document (Phase 5 Gate)

Before any code is written, the AI produces a formal design document:

```
# Design Document: User Authentication with JWT

Date: 2026-02-24
Author: Claude (with developer guidance)
Status: Pending Approval

## 1. Overview
Add JWT-based authentication to the API with login,
logout, token refresh, and role-based access control.

## 2. Requirements
- Functional: login endpoint, token refresh, role middleware
- Non-functional: tokens expire in 30 min, refresh in 7 days
- Out of scope: OAuth, social login, MFA

## 5. Detailed Design

  Files to Create
  ┌─────────────────────────────────┬──────────────────────┐
  │ File Path                       │ Purpose              │
  ├─────────────────────────────────┼──────────────────────┤
  │ app/api/v1/auth.py              │ Login/refresh routes │
  │ app/services/auth.py            │ Token generation     │
  │ app/dependencies/auth.py        │ JWT validation dep   │
  │ app/schemas/auth.py             │ Token schemas        │
  │ alembic/versions/004_add_roles  │ Role column migration│
  │ tests/api/test_auth.py          │ Auth endpoint tests  │
  └─────────────────────────────────┴──────────────────────┘

## 6. Test Plan
- Unit: token generation, validation, expiry
- Integration: login flow, refresh flow, invalid credentials
- Edge cases: expired tokens, revoked tokens, concurrent refresh

## 7. Rollback Plan
Revert migration 004, remove auth dependency from protected routes.
```

**The developer reviews and approves this before a single line of code is written.**

---

### Showcase 4: Reviewer Agent Confidence Scoring

The reviewer only surfaces issues it is highly confident about:

```
REVIEW: app/services/auth.py

CRITICAL (confidence: 95)
  app/services/auth.py:45 — JWT secret loaded from hardcoded string
  instead of environment variable. Credentials exposed in source.
  Fix: Use settings.jwt_secret from pydantic-settings.

IMPORTANT (confidence: 88)
  app/api/v1/auth.py:23 — Login endpoint missing rate limiting.
  Brute force attacks possible on /api/v1/auth/login.
  Fix: Add SlowAPI rate limiter dependency.

IMPORTANT (confidence: 82)
  app/services/auth.py:67 — Token refresh does not invalidate
  the old refresh token. Token replay attack possible.
  Fix: Store refresh tokens in DB, invalidate on use.

Summary: 3 issues found (1 critical, 2 important)
Recommendation: Fix critical issue before merge.
```

Issues below 80% confidence are not reported. No noise. No false positives.

---

### Showcase 5: Auto-Linting Hooks

Every time the AI writes or edits a file, linting runs automatically:

```
                  AI writes code
                       │
                       v
              ┌────────────────┐
              │  PostToolUse   │
              │  Hook Fires    │
              └───────┬────────┘
                      │
           ┌──────────┴──────────┐
           │                     │
    Python file?           React file?
    (.py)                  (.ts/.tsx/.jsx)
           │                     │
           v                     v
    ┌─────────────┐      ┌──────────────┐
    │ ruff check  │      │ eslint --fix │
    │   --fix     │      │              │
    │ black       │      │ prettier     │
    │   --quiet   │      │   --write    │
    └──────┬──────┘      └──────┬───────┘
           │                    │
           v                    v
    Code is formatted     Code is formatted
    and linted before     and linted before
    the developer ever    the developer ever
    sees it               sees it
```

**Zero manual intervention.** Code is always clean.

---

## Embedded Best Practices

Each plugin ships with **3 skills** — living documents that encode your team's conventions and are loaded into every agent automatically.

### FastAPI Plugin Skills

| Skill | What It Covers |
|-------|---------------|
| **fastapi-conventions** | Project structure, router patterns, service layer, repository pattern, schema conventions, error handling, auth patterns, configuration |
| **fastapi-testing** | Test structure, fixtures (httpx, database, auth), async testing, factory patterns, database isolation, API testing, mocking |
| **python-quality** | Ruff rules, Black config, Mypy strict mode, import ordering, type annotations, docstrings, logging |

### React Plugin Skills

| Skill | What It Covers |
|-------|---------------|
| **react-conventions** | Component patterns, folder structure, state management, API integration, routing, form handling, naming conventions |
| **react-testing** | Component tests, hook tests, MSW API mocking, integration tests, accessibility testing |
| **typescript-quality** | ESLint config, Prettier config, TypeScript strict mode, no-any policy, utility types, import conventions |

**These are editable.** Teams customize the skills to match their specific project conventions, and every agent picks up the changes immediately.

---

## Distribution & Team Adoption

```
┌─────────────────────────────────────────────────┐
│               GitHub Repository                  │
│     github.com/alfalabs/claude-feature-dev       │
│                                                  │
│  marketplace.json ──── Plugin registry           │
│  plugins/fastapi-dev/  ── FastAPI plugin         │
│  plugins/react-dev/    ── React plugin           │
└────────────────────┬────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        v            v            v
   Developer A  Developer B  Developer C

   claude /plugin marketplace add <repo-url>
   claude /plugin install fastapi-dev

   Done. Workflow active.
```

**Installation takes under 60 seconds.** One marketplace add, one plugin install, and the workflow is live.

---

## Key Differentiators

### vs. Raw AI Coding (no workflow)

| | Raw AI | Feature-Dev |
|---|---|---|
| Codebase understanding | Reads files on demand | Parallel agents map the entire relevant codebase |
| Architecture decisions | AI picks one approach silently | 3 competing proposals with trade-offs, developer decides |
| Design review | None | Formal design document, must be approved |
| Code quality | Varies per session | Enforced by skills + auto-linting hooks |
| Security review | Hope for the best | Dedicated reviewer agent with confidence scoring |
| Consistency | Every session is different | Same 8-phase process, every time |

### What This Means in Practice

- **No code without a plan.** The design document gate ensures every feature has a reviewed architecture before implementation begins.
- **Team conventions are enforced automatically.** Skills embed your patterns directly into the AI's context. The AI doesn't just know Python — it knows *your* Python.
- **Quality is built in, not bolted on.** Linting hooks run on every file write. Review agents scan for real bugs. False positives are filtered out.
- **Developers stay in control.** They answer questions, pick architectures, approve designs, and decide which review findings to address.

---

## What's Included (v1.0.0)

```
22 files across 2 plugins

  fastapi-dev/              react-dev/
  ├── plugin.json           ├── plugin.json
  ├── 3 agents              ├── 3 agents
  │   ├── explorer          │   ├── explorer
  │   ├── architect         │   ├── architect
  │   └── reviewer          │   └── reviewer
  ├── 3 skills              ├── 3 skills
  │   ├── conventions       │   ├── conventions
  │   ├── testing           │   ├── testing
  │   └── quality           │   └── quality
  ├── hooks.json            ├── hooks.json
  ├── lint script           ├── lint script
  └── feature-dev command   └── feature-dev command

  + marketplace.json
  + README.md
  + MIT License
```

---

*Built by AlfaLabs Engineering. Powered by Claude Code.*
