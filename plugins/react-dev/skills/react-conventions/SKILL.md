---
name: react-conventions
description: React/TypeScript project conventions and patterns. Loaded by agents to understand component structure, state management, API integration, and naming conventions.
---

# React/TypeScript Conventions

Standard conventions for React projects using TypeScript. Follow these patterns for consistency across the codebase.

## 1. Component Patterns

Use functional components exclusively. Prefer composition over inheritance, render props for cross-cutting logic, and compound components for related UI groups.

```tsx
// Compound component pattern with context
function Tabs({ children, defaultIndex = 0 }: TabsProps) {
  const [activeIndex, setActiveIndex] = useState(defaultIndex);
  return (
    <TabsContext.Provider value={{ activeIndex, setActiveIndex }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

Tabs.Panel = function TabPanel({ index, children }: TabPanelProps) {
  const { activeIndex } = useTabsContext();
  return activeIndex === index ? <div>{children}</div> : null;
};
```

## 2. Folder Structure

Organize code by feature. Shared utilities, components, and hooks live at the top level.

```
src/
  features/
    auth/
      components/
      hooks/
      auth.types.ts
      index.ts
    dashboard/
      components/
      hooks/
      dashboard.types.ts
      index.ts
  components/       # Shared UI components (Button, Modal, etc.)
  hooks/            # Shared hooks (useDebounce, useLocalStorage, etc.)
  api/              # API client, interceptors, endpoint definitions
  types/            # Global type definitions and shared interfaces
  utils/            # Pure helper functions (formatDate, cn, etc.)
```

Each feature folder re-exports its public API through `index.ts`. Never import from a feature's internal files directly.

## 3. State Management

Use `useState` for component-local state, Zustand or Redux Toolkit for global client state, and TanStack Query for server state. Keep server and client state separate.

```tsx
// Custom hook with TanStack Query for server state
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { fetchProjects, createProject } from "@/api/projects";
import type { Project, CreateProjectInput } from "@/types/project.types";

export function useProjects() {
  return useQuery<Project[]>({
    queryKey: ["projects"],
    queryFn: fetchProjects,
    staleTime: 5 * 60 * 1000,
  });
}

export function useCreateProject() {
  const queryClient = useQueryClient();
  return useMutation<Project, Error, CreateProjectInput>({
    mutationFn: createProject,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["projects"] }),
  });
}
```

## 4. API Integration

Wrap all API calls in custom hooks. Use a centralized API client with typed request and response objects. Never call fetch or axios directly from components.

```tsx
// api/client.ts — Centralized axios instance with auth error handling
export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  headers: { "Content-Type": "application/json" },
});

apiClient.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) window.location.href = "/login";
    return Promise.reject(err);
  }
);

// api/projects.ts — Typed endpoint functions
export async function fetchProjects(): Promise<Project[]> {
  const { data } = await apiClient.get<Project[]>("/projects");
  return data;
}
```

## 5. Routing

Use React Router with a centralized route config. Protect authenticated routes with a guard component. Lazy-load feature routes with `React.lazy` and wrap them in `Suspense`.

```tsx
import { lazy, Suspense } from "react";
import { createBrowserRouter, Navigate, Outlet } from "react-router-dom";
import { useAuth } from "@/features/auth/hooks/useAuth";
import { Spinner } from "@/components/Spinner";

const Dashboard = lazy(() => import("@/features/dashboard/DashboardPage"));
const Settings = lazy(() => import("@/features/settings/SettingsPage"));

function ProtectedRoute() {
  const { isAuthenticated } = useAuth();
  return isAuthenticated ? <Outlet /> : <Navigate to="/login" replace />;
}

export const router = createBrowserRouter([
  {
    element: <ProtectedRoute />,
    children: [
      { path: "/dashboard", element: <Suspense fallback={<Spinner />}><Dashboard /></Suspense> },
      { path: "/settings", element: <Suspense fallback={<Spinner />}><Settings /></Suspense> },
    ],
  },
]);
```

## 6. Form Handling

Use React Hook Form for form state and Zod for schema validation. Co-locate the schema with the form component. Keep forms as controlled components through the `useForm` hook.

```tsx
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";

const loginSchema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(8, "Password must be at least 8 characters"),
});

type LoginFormData = z.infer<typeof loginSchema>;

export function LoginForm({ onSubmit }: { onSubmit: (data: LoginFormData) => void }) {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register("email")} placeholder="Email" />
      {errors.email && <span>{errors.email.message}</span>}
      <input {...register("password")} type="password" placeholder="Password" />
      {errors.password && <span>{errors.password.message}</span>}
      <button type="submit" disabled={isSubmitting}>Log in</button>
    </form>
  );
}
```

## 7. Naming Conventions

Consistent naming makes the codebase searchable and predictable.

| Category | Convention | Example |
|---|---|---|
| Components | PascalCase | `UserProfile.tsx` |
| Hooks | `use*` prefix, camelCase | `useAuth.ts`, `useDebounce.ts` |
| Utilities | camelCase | `formatDate.ts`, `cn.ts` |
| Type files | `*.types.ts` suffix | `project.types.ts` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRIES`, `API_BASE_URL` |
| Context | `*Context` suffix | `AuthContext`, `ThemeContext` |
| Enums | PascalCase members | `UserRole.Admin` |

```tsx
// Example: hook following use* convention with typed generics
export function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    const item = localStorage.getItem(key);
    return item ? (JSON.parse(item) as T) : initialValue;
  });

  const setValue = (value: T) => {
    setStoredValue(value);
    localStorage.setItem(key, JSON.stringify(value));
  };

  return [storedValue, setValue] as const;
}
```
