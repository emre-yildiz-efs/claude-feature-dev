---
name: react-testing
description: React/TypeScript testing patterns and conventions. Loaded by agents to understand component testing, hook testing, API mocking, and accessibility testing.
---

# React/TypeScript Testing Patterns

Standard testing conventions for React projects using Testing Library, Vitest/Jest, and MSW. Follow these patterns for reliable, maintainable tests.

## 1. Test File Organization

Co-locate tests next to source files using `__tests__/` directories or `*.test.tsx` siblings. Create a shared test utilities module that wraps `render` with application providers so every test gets routing, theme, and query context automatically.

```tsx
// test/utils.tsx — Custom render with all providers
import { render, type RenderOptions } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { MemoryRouter } from "react-router-dom";
import { ThemeProvider } from "@/components/ThemeProvider";

const createTestQueryClient = () =>
  new QueryClient({ defaultOptions: { queries: { retry: false } } });

export function renderWithProviders(
  ui: React.ReactElement,
  options?: RenderOptions & { route?: string },
) {
  const queryClient = createTestQueryClient();
  return render(ui, {
    wrapper: ({ children }) => (
      <QueryClientProvider client={queryClient}>
        <MemoryRouter initialEntries={[options?.route ?? "/"]}>
          <ThemeProvider>{children}</ThemeProvider>
        </MemoryRouter>
      </QueryClientProvider>
    ),
    ...options,
  });
}

export { screen, waitFor, within } from "@testing-library/react";
export { default as userEvent } from "@testing-library/user-event";
```

## 2. Component Tests

Render the component, query the DOM with `screen`, simulate interactions with `userEvent`, and assert on visible output. Prefer `getByRole` and `getByLabelText` over `getByTestId` to keep tests grounded in accessibility semantics. Always use `userEvent` instead of `fireEvent` for realistic browser behavior.

```tsx
import { renderWithProviders, screen, userEvent } from "@/test/utils";
import { Counter } from "../Counter";

describe("Counter", () => {
  it("increments the count on button click", async () => {
    const user = userEvent.setup();
    renderWithProviders(<Counter initialCount={0} />);

    expect(screen.getByRole("heading")).toHaveTextContent("Count: 0");

    await user.click(screen.getByRole("button", { name: /increment/i }));

    expect(screen.getByRole("heading")).toHaveTextContent("Count: 1");
  });

  it("disables the button when max is reached", () => {
    renderWithProviders(<Counter initialCount={10} max={10} />);
    expect(screen.getByRole("button", { name: /increment/i })).toBeDisabled();
  });
});
```

## 3. Hook Tests

Use `renderHook` to test custom hooks in isolation. Wrap state updates in `act()` and use `waitFor` when the hook performs async operations. Pass a `wrapper` when the hook depends on context providers.

```tsx
import { renderHook, act, waitFor } from "@testing-library/react";
import { useCounter } from "../useCounter";
import { useProjects } from "../useProjects";
import { createQueryWrapper } from "@/test/utils";

describe("useCounter", () => {
  it("increments and resets", () => {
    const { result } = renderHook(() => useCounter(0));

    act(() => result.current.increment());
    expect(result.current.count).toBe(1);

    act(() => result.current.reset());
    expect(result.current.count).toBe(0);
  });
});

describe("useProjects", () => {
  it("returns project data after fetch", async () => {
    const { result } = renderHook(() => useProjects(), {
      wrapper: createQueryWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(3);
  });
});
```

## 4. API Mocking with MSW

Use Mock Service Worker to intercept network requests at the service-worker level. Define handlers that mirror your real API, start the server before all tests, reset handlers between tests, and close the server when done.

```tsx
// test/mocks/handlers.ts
import { http, HttpResponse } from "msw";
import type { Project } from "@/types/project.types";

const mockProjects: Project[] = [
  { id: "1", name: "Alpha", status: "active" },
  { id: "2", name: "Beta", status: "archived" },
];

export const handlers = [
  http.get("/api/projects", () => HttpResponse.json(mockProjects)),
  http.post("/api/projects", async ({ request }) => {
    const body = (await request.json()) as Partial<Project>;
    return HttpResponse.json({ id: "3", ...body }, { status: 201 });
  }),
  http.delete("/api/projects/:id", () => new HttpResponse(null, { status: 204 })),
];

// test/mocks/server.ts
import { setupServer } from "msw/node";
import { handlers } from "./handlers";

export const server = setupServer(...handlers);

// test/setup.ts — Vitest or Jest global setup
beforeAll(() => server.listen({ onUnhandledRequest: "error" }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## 5. Integration Tests

Test multi-component flows that span routing, form submission, and data fetching. Use `MemoryRouter` to control navigation and assert on the resulting UI after user-driven workflows complete.

```tsx
import { renderWithProviders, screen, userEvent, waitFor } from "@/test/utils";
import { App } from "@/App";
import { server } from "@/test/mocks/server";
import { http, HttpResponse } from "msw";

describe("project creation flow", () => {
  it("navigates to form, submits, and shows new project in list", async () => {
    const user = userEvent.setup();
    renderWithProviders(<App />, { route: "/projects" });

    await user.click(screen.getByRole("link", { name: /new project/i }));
    expect(screen.getByRole("heading", { name: /create project/i })).toBeInTheDocument();

    await user.type(screen.getByLabelText(/project name/i), "Gamma");
    await user.click(screen.getByRole("button", { name: /submit/i }));

    await waitFor(() =>
      expect(screen.getByText("Gamma")).toBeInTheDocument(),
    );
  });

  it("shows validation error for empty name", async () => {
    const user = userEvent.setup();
    renderWithProviders(<App />, { route: "/projects/new" });

    await user.click(screen.getByRole("button", { name: /submit/i }));

    expect(screen.getByText(/name is required/i)).toBeInTheDocument();
  });
});
```

## 6. Accessibility Testing

Integrate automated a11y checks with `jest-axe` or `vitest-axe` to catch WCAG violations. Combine axe scans with manual ARIA queries and keyboard navigation tests for thorough coverage.

```tsx
import { axe, toHaveNoViolations } from "jest-axe";
import { renderWithProviders, screen, userEvent } from "@/test/utils";
import { LoginForm } from "../LoginForm";

expect.extend(toHaveNoViolations);

describe("LoginForm accessibility", () => {
  it("has no axe violations", async () => {
    const { container } = renderWithProviders(<LoginForm onSubmit={vi.fn()} />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  it("associates error messages with inputs via aria-describedby", async () => {
    const user = userEvent.setup();
    renderWithProviders(<LoginForm onSubmit={vi.fn()} />);

    await user.click(screen.getByRole("button", { name: /log in/i }));

    const emailInput = screen.getByLabelText(/email/i);
    const errorId = emailInput.getAttribute("aria-describedby");
    expect(document.getElementById(errorId!)).toHaveTextContent(/invalid email/i);
  });

  it("supports keyboard-only form submission", async () => {
    const onSubmit = vi.fn();
    const user = userEvent.setup();
    renderWithProviders(<LoginForm onSubmit={onSubmit} />);

    await user.tab();
    await user.keyboard("user@example.com");
    await user.tab();
    await user.keyboard("securepassword");
    await user.tab();
    await user.keyboard("{Enter}");

    await waitFor(() => expect(onSubmit).toHaveBeenCalledOnce());
  });
});
```
