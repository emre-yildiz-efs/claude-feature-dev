---
description: Guided FastAPI feature development with codebase understanding, architecture focus, and design document approval
argument-hint: Optional feature description
---

# FastAPI Feature Development

You are helping a developer implement a new feature in a Python/FastAPI backend. Follow a systematic 8-phase approach: understand the codebase deeply, resolve all ambiguities, design the architecture, produce an approved design document, then implement.

## Core Principles

- **Ask clarifying questions**: Identify all ambiguities, edge cases, and underspecified behaviors. Wait for user answers before proceeding.
- **Understand before acting**: Read and comprehend existing code patterns first
- **Read files identified by agents**: When launching agents, ask them to return lists of the most important files to read. After agents complete, read those files.
- **Design before code**: Produce a design document and get explicit approval before any implementation
- **Simple and elegant**: Prioritize readable, maintainable, architecturally sound code
- **Use TodoWrite**: Track all progress throughout

---

## Phase 1: Discovery

**Goal**: Understand what needs to be built

Initial request: $ARGUMENTS

**Actions**:
1. Create todo list with all 8 phases
2. If feature unclear, ask user for: What problem? What should it do? Any constraints?
3. Summarize understanding and confirm with user

---

## Phase 2: Codebase Exploration

**Goal**: Understand relevant existing code and patterns

**Actions**:
1. Launch 2-3 fastapi-explorer agents in parallel. Each targets a different aspect:
   - Similar features and their implementations (endpoint patterns, service layer, repositories)
   - High-level architecture (middleware, auth, error handling, dependency injection)
   - Testing patterns, database models, migrations
   Each agent should include a list of 5-10 key files to read.
2. Once agents return, read all identified files to build deep understanding
3. Present comprehensive summary of findings and patterns

---

## Phase 3: Clarifying Questions

**Goal**: Fill in gaps and resolve ALL ambiguities before designing

**CRITICAL**: This is one of the most important phases. DO NOT SKIP.

**Actions**:
1. Review codebase findings and original feature request
2. Identify underspecified aspects:
   - Edge cases and error scenarios
   - Integration points with existing code
   - Scope boundaries (what's in/out)
   - Design preferences (naming, patterns)
   - Backward compatibility concerns
   - Performance requirements
   - Database migration strategy
3. Present all questions in a clear, organized list
4. **Wait for answers before proceeding**

---

## Phase 4: Architecture Design

**Goal**: Design multiple implementation approaches with different trade-offs

**Actions**:
1. Launch 2-3 fastapi-architect agents in parallel with different focuses:
   - Minimal changes: smallest change, maximum reuse of existing patterns
   - Clean architecture: maintainability, elegant abstractions
   - Pragmatic balance: speed + quality
2. Review all approaches
3. Present to user: summary of each approach, trade-offs comparison, your recommendation with reasoning
4. **Ask user which approach they prefer**

---

## Phase 5: Design Document

**Goal**: Produce a comprehensive design document for approval

**HARD GATE**: Must produce and get approval before any implementation begins.

**Actions**:
1. Write a design document using this template:

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

### API Contracts
Endpoint definitions with request/response schemas.

### Data Flow
Step-by-step flow from input to output.

### Database Changes (if applicable)
New tables/columns, migration strategy, data backfill plan.

## 6. Test Plan
- Unit tests to write
- Integration tests to write
- Edge cases to cover

## 7. Rollback Plan
How to revert if something goes wrong.

## 8. Open Questions
Any remaining uncertainties (should be empty before approval).
```

2. Present the design document to the user
3. **User must explicitly approve** before proceeding to Phase 6
4. If user requests changes, revise and re-present

---

## Phase 6: Implementation

**Goal**: Build the feature following the approved design

**DO NOT START WITHOUT EXPLICIT DESIGN DOCUMENT APPROVAL**

**Actions**:
1. Read all relevant files identified in previous phases
2. Implement following the approved design document exactly
3. Follow codebase conventions strictly (enforced by loaded skills)
4. Hooks auto-lint and format as files are written
5. Write tests alongside implementation
6. Update todos as you progress

---

## Phase 7: Quality Review

**Goal**: Ensure code quality, correctness, and convention adherence

**Actions**:
1. Launch 3 fastapi-reviewer agents in parallel with different focuses:
   - Simplicity / DRY / elegance
   - Bugs / functional correctness / security
   - Project conventions / abstractions / patterns
2. Consolidate findings and identify highest severity issues
3. **Present findings to user and ask what they want to do** (fix now, fix later, or proceed as-is)
4. Address issues based on user decision

---

## Phase 8: Summary

**Goal**: Document what was accomplished

**Actions**:
1. Mark all todos complete
2. Summarize:
   - What was built
   - Key decisions made
   - Files created/modified
   - Tests added
   - Suggested next steps
