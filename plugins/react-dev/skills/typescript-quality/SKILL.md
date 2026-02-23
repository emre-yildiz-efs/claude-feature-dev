---
name: typescript-quality
description: TypeScript code quality standards including ESLint configuration, Prettier formatting, and strict TypeScript conventions.
---

# TypeScript/React Code Quality Standards

Enforced quality standards for TypeScript and React projects ensuring consistent, type-safe, and maintainable code.

## 1. ESLint

Use a flat config with TypeScript-aware rules, React hooks enforcement, and import ordering.

```js
// eslint.config.js
import js from "@eslint/js";
import tseslint from "typescript-eslint";
import reactHooks from "eslint-plugin-react-hooks";
import importPlugin from "eslint-plugin-import";

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.strictTypeChecked,
  {
    plugins: { "react-hooks": reactHooks, import: importPlugin },
    rules: {
      "@typescript-eslint/no-explicit-any": "error",
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      "@typescript-eslint/consistent-type-imports": ["error", { prefer: "type-imports" }],
      "react-hooks/rules-of-hooks": "error",
      "react-hooks/exhaustive-deps": "warn",
      "react/jsx-no-target-blank": "error",
      "import/order": ["error", {
        groups: ["builtin", "external", "internal", "parent", "sibling", "index"],
        "newlines-between": "always",
        alphabetize: { order: "asc" },
      }],
      "import/no-duplicates": "error",
    },
  },
);
```

## 2. Prettier

Configure Prettier for consistent formatting. Integrate with ESLint via `eslint-config-prettier` to avoid rule conflicts.

```json
{ "semi": true, "singleQuote": false, "trailingComma": "all", "printWidth": 100, "tabWidth": 2 }
```

## 3. TypeScript Strict Mode

Enable `strict` plus additional safety flags to catch errors at compile time.

```jsonc
{
  "compilerOptions": {
    "strict": true,                         // noImplicitAny, strictNullChecks, etc.
    "noUncheckedIndexedAccess": true,        // arr[0] is T | undefined
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true,
    "forceConsistentCasingInFileNames": true,
    "isolatedModules": true,
    "moduleResolution": "bundler",
    "jsx": "react-jsx"
  }
}
```

## 4. No-Any Policy

Never use `any`. Use `unknown` for uncertain shapes and narrow with type guards. Use generics when the type is caller-determined. Define explicit interfaces for external data.

```tsx
// BAD — any disables all type checking
function parseData(data: any) {
  return data.items.map((item: any) => item.name);
}

// GOOD — unknown forces validation before access
function parseData(data: unknown): string[] {
  if (!isProjectList(data)) throw new Error("Invalid response");
  return data.items.map((item) => item.name);
}

function isProjectList(val: unknown): val is { items: { name: string }[] } {
  return typeof val === "object" && val !== null && "items" in val;
}

// GOOD — generics let callers control the type
function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  return { data, loading: !data };
}
```

## 5. Utility Types

Leverage built-in utility types to derive types from existing ones, avoiding duplication.

```tsx
interface User {
  id: string; name: string; email: string;
  role: "admin" | "editor" | "viewer";
  createdAt: Date;
}

type UserPreview = Pick<User, "id" | "name" | "role">;
type CreateUserInput = Omit<User, "id" | "createdAt">;
type UpdateUserInput = Partial<Omit<User, "id">>;
type RolePermissions = Record<User["role"], string[]>;
type ActiveRole = Extract<User["role"], "admin" | "editor">;
type NonAdminRole = Exclude<User["role"], "admin">;

// Discriminated unions for exhaustive pattern matching
type ApiResult<T> =
  | { status: "success"; data: T }
  | { status: "error"; error: string }
  | { status: "loading" };

function renderResult(result: ApiResult<User>) {
  switch (result.status) {
    case "success": return <UserCard user={result.data} />;
    case "error":   return <ErrorBanner message={result.error} />;
    case "loading":  return <Spinner />;
  }
}
```

## 6. Import Conventions

Configure absolute imports via `tsconfig.json` paths. Use barrel exports to expose a feature's public API.

```jsonc
{ "compilerOptions": { "baseUrl": ".", "paths": { "@/*": ["src/*"] } } }
```

```tsx
// features/auth/index.ts — barrel export
export { LoginForm } from "./components/LoginForm";
export { useAuth } from "./hooks/useAuth";
export type { AuthState, LoginCredentials } from "./auth.types";
```

Import order: (1) React/built-ins, (2) third-party, (3) `@/` aliases, (4) relative, (5) type-only.

```tsx
import { useState, useCallback } from "react";

import { useQuery } from "@tanstack/react-query";

import { Button } from "@/components/Button";

import { ProjectCard } from "./ProjectCard";

import type { Project } from "@/types/project.types";
```
