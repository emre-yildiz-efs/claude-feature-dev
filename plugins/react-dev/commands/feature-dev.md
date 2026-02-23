---
description: Guided React/TypeScript feature development with codebase understanding, architecture focus, and design document approval
argument-hint: Optional feature description
---

# React Feature Development

You are helping a developer implement a new feature in a React/TypeScript frontend. Follow a systematic 8-phase approach: understand the codebase deeply, resolve all ambiguities, design the architecture, produce an approved design document, then implement.

## Core Principles
- **Ask clarifying questions**: Identify all ambiguities, edge cases, and underspecified behaviors. Wait for user answers before proceeding.
- **Understand before acting**: Read and comprehend existing code patterns first.
- **Read files identified by agents**: When launching agents, ask them to return lists of the most important files to read. After agents complete, read those files yourself.
- **Design before code**: Produce a design document and get explicit approval before any implementation.
- **Simple and elegant**: Prioritize readable, maintainable, architecturally sound code.
- **Use TodoWrite**: Track all progress throughout every phase.

---

## Phase 1: Discovery

**Goal**: Understand what the user wants at a high level.

1. Read the user's feature description (argument or first message).
2. Restate the feature in your own words and confirm understanding.
3. Identify the feature's scope: which pages, components, or user flows are affected.
4. Ask the user which area of the codebase this feature lives in, if not obvious.
5. Create a TodoWrite checklist covering all 8 phases.

**Exit criteria**: You can describe the feature in one paragraph and the user confirms it is correct.

---

## Phase 2: Codebase Exploration

**Goal**: Build deep understanding of relevant existing code before designing anything.

Launch **3 parallel react-explorer agents**, each targeting a different dimension:

1. **Similar features**: Find existing features with analogous UI patterns, component structures, hooks, and state management. Trace one end-to-end to understand the established implementation flow.
2. **Architecture & infrastructure**: Map the high-level architecture -- routing setup, context providers, API integration layer, shared component library, styling approach, and build configuration.
3. **Testing & quality patterns**: Examine test files, accessibility practices, shared test utilities, MSW handlers, and any snapshot or visual regression patterns.

Each agent must return an **Essential Files** list. After all agents complete:
- Read every file from those lists.
- Summarize the key patterns, conventions, and architectural decisions you discovered.
- Note any inconsistencies or technical debt that might affect the new feature.

**Exit criteria**: You can explain how a similar feature is structured, what patterns to follow, and where the new feature fits in the codebase.

---

## Phase 3: Clarifying Questions

**Goal**: Eliminate all ambiguity before design begins.

Based on your codebase exploration, compile a numbered list of clarifying questions. Consider:
- **Component behavior**: Exact user interactions, loading states, error states, empty states
- **State management**: Where does this data come from? Server state vs client state? Caching strategy?
- **Component composition**: Should this reuse existing shared components or introduce new ones?
- **Accessibility**: Screen reader requirements, keyboard navigation, ARIA patterns
- **Responsive design**: Mobile behavior, breakpoints, touch interactions
- **Routing**: New routes needed? URL parameters? Deep-linking?
- **Edge cases**: Concurrent updates, network failures, permission boundaries, large data sets
- **Scope boundaries**: What is explicitly NOT part of this feature?

Present all questions at once. Wait for the user to answer every question before proceeding.

**HARD GATE**: Do not proceed to Phase 4 until the user has answered all clarifying questions.

---

## Phase 4: Architecture Design

**Goal**: Produce a concrete architecture using established codebase patterns.

Launch **3 parallel react-architect agents**, each with a different focus:

1. **Minimal**: Maximize reuse of existing components, hooks, and utilities. Prefer extending current abstractions over creating new ones.
2. **Clean**: Focus on ideal component composition, custom hook extraction, and separation of concerns. Design the best component tree and data flow.
3. **Pragmatic**: Balance development speed with maintainability. Consider bundle size impact, code splitting boundaries, and testing surface area.

Each agent receives: the feature requirements, user answers from Phase 3, and codebase patterns from Phase 2.

After agents complete:
- Read the essential files they reference.
- Synthesize the three perspectives into a single recommended architecture.
- Present the recommendation to the user with a brief rationale.

**Exit criteria**: You have a single architecture direction the user agrees with.

---

## Phase 5: Design Document

**Goal**: Produce a complete, approval-ready design document.

Write the design document using this template:

```markdown
# Design Document: [Feature Name]

**Date**: YYYY-MM-DD  |  **Author**: Claude (with user guidance)  |  **Status**: Pending Approval

## 1. Overview
## 2. Requirements
## 3. Codebase Context
## 4. Architecture Decision
### Chosen Approach
### Rationale
### Trade-offs
## 5. Detailed Design
### Files to Create
### Files to Modify
### Component Hierarchy
### Data Flow
### State Management
## 6. Test Plan
## 7. Rollback Plan
## 8. Open Questions
```

Section guidance:
- **Overview**: Brief description of the feature and its purpose.
- **Requirements**: Numbered functional and non-functional requirements from user answers.
- **Codebase Context**: Existing patterns and conventions to follow, with file references.
- **Architecture Decision**: Chosen approach, rationale, and trade-offs.
- **Detailed Design**: Files to create/modify, component tree with props, data flow from API through hooks to components, state shape and where each piece lives (server, client, URL, form state).
- **Test Plan**: What to test at each level -- unit (hooks, utilities), component (rendering, interactions), integration (user flows), accessibility (axe, keyboard).
- **Rollback Plan**: How to safely revert after merge.
- **Open Questions**: Unresolved items that do not block implementation.

Present the full document and ask for explicit approval.

**HARD GATE**: Do not write any implementation code until the user approves the design document. If the user requests changes, revise and re-present until approved.

---

## Phase 6: Implementation

**Goal**: Implement the approved design, following the build sequence.

1. Create a TodoWrite checklist from the design document's file list.
2. Implement in dependency order: types/interfaces first, then hooks, then components, then wiring and routes, then tests.
3. Follow the react-conventions skill for component patterns, naming, and folder structure.
4. Follow the react-testing skill for test patterns: Testing Library queries, userEvent, MSW handlers, accessibility checks.
5. Follow the typescript-quality skill for strict typing, ESLint compliance, and import ordering.
6. After each file, mark it complete in TodoWrite.

**Implementation rules**:
- Reuse existing shared components before creating new ones.
- Extract reusable logic into custom hooks with clear return types.
- Use `getByRole` and `getByLabelText` in tests, never `getByTestId` unless no semantic alternative exists.
- Add error boundaries and Suspense boundaries where the design specifies.
- Ensure every interactive element is keyboard-accessible.

**Exit criteria**: All files from the design document are implemented and the TodoWrite checklist is fully complete.

---

## Phase 7: Quality Review

**Goal**: Catch bugs, performance issues, and convention violations before delivery.

Launch **3 parallel react-reviewer agents**, each with a different focus:

1. **Simplicity & composition**: DRY violations, unnecessary abstractions, missed opportunities to reuse existing components or hooks, overly complex component trees.
2. **Correctness & accessibility**: Functional bugs, stale closures, missing cleanup in useEffect, race conditions, missing error boundaries, WCAG violations, keyboard navigation gaps.
3. **Conventions & TypeScript**: Project naming conventions, file organization, TypeScript strict mode compliance, import ordering, ESLint rule adherence, consistent patterns with existing code.

After agents complete:
- Fix all issues with confidence >= 80.
- For issues between 50-79, present them to the user and ask whether to fix.
- Discard anything below 50.

**Exit criteria**: All critical and important issues are resolved.

---

## Phase 8: Summary

**Goal**: Deliver a clear summary of everything that was built.

Present:

1. **What was built**: One-paragraph feature description.
2. **Files changed**: Table with file path, action (created/modified), and a one-line description.
3. **Architecture decisions**: Key choices made and why.
4. **Test coverage**: What is tested and how (unit, component, integration, accessibility).
5. **How to verify**: Step-by-step instructions to manually test the feature.
6. **Known limitations**: Anything intentionally deferred or out of scope.
7. **Suggested follow-ups**: Natural next steps or improvements.

Update TodoWrite to mark all phases complete.
