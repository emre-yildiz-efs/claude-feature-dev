---
name: fastapi-testing
description: FastAPI testing patterns and conventions. Loaded by agents to understand test structure, fixtures, and testing best practices.
---

# FastAPI Testing Patterns & Fixtures

## Test Structure

Follow Arrange-Act-Assert and name tests `test_<action>_<condition>_<expected>`. Organize files by layer to mirror the application structure.

```
tests/
  conftest.py              # Shared fixtures (client, db, auth)
  api/
    test_items.py          # Router / endpoint tests
    test_auth.py
  services/
    test_item_service.py   # Business logic tests
  repositories/
    test_item_repo.py      # Data access tests
```

```python
async def test_create_item_with_valid_data_returns_201(client, auth_headers):
    # Arrange
    payload = {"title": "New Item", "description": "Details"}
    # Act
    resp = await client.post("/api/v1/items", json=payload, headers=auth_headers)
    # Assert
    assert resp.status_code == 201
    assert resp.json()["title"] == "New Item"
```

## Fixtures

Define reusable fixtures in `conftest.py`. The async test client uses `httpx.AsyncClient` with `ASGITransport` so requests never hit the network.

```python
# tests/conftest.py
import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from app.main import app
from app.dependencies.db import get_db

engine = create_async_engine("sqlite+aiosqlite:///./test.db")
TestSession = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

@pytest.fixture
async def db_session():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with TestSession() as session:
        yield session
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest.fixture
async def client(db_session):
    app.dependency_overrides[get_db] = lambda: db_session
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
    app.dependency_overrides.clear()

@pytest.fixture
def auth_headers():
    token = create_access_token(data={"sub": "1"})
    return {"Authorization": f"Bearer {token}"}

@pytest.fixture
async def admin_user(db_session):
    user = User(email="admin@test.com", roles=["admin"])
    db_session.add(user)
    await db_session.commit()
    return user
```

## Async Testing

Configure pytest-asyncio to auto-mode so every `async def test_*` runs in an event loop without manual decorators.

```ini
# pyproject.toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
```

```python
# No decorator needed -- asyncio_mode = "auto" handles it.
async def test_list_items_returns_empty_list(client):
    resp = await client.get("/api/v1/items")
    assert resp.status_code == 200
    assert resp.json() == []

# Async fixtures work the same way.
@pytest.fixture
async def seeded_item(db_session):
    item = Item(title="Seed", owner_id=1)
    db_session.add(item)
    await db_session.commit()
    return item
```

## Factory Patterns

Use dataclass-based factories to generate test data with sensible defaults. Override only the fields relevant to each test.

```python
from dataclasses import dataclass

@dataclass
class ItemFactory:
    title: str = "Test Item"
    description: str | None = "Default description"
    owner_id: int = 1

    def build(self, **overrides) -> dict:
        return {**self.__dict__, **overrides}

    async def create(self, db, **overrides) -> "Item":
        item = Item(**self.build(**overrides))
        db.add(item)
        await db.commit()
        return item

# Usage: factory.build(title="Custom") or await factory.create(db, owner_id=42)
factory = ItemFactory()
```

## Database Isolation

Wrap each test in a transaction that rolls back after completion. This keeps the database clean without the cost of re-creating tables for every test.

```python
@pytest.fixture
async def db_session():
    async with engine.connect() as conn:
        transaction = await conn.begin()
        session = AsyncSession(bind=conn, expire_on_commit=False)
        try:
            yield session
        finally:
            await session.close()
            await transaction.rollback()
```

For integration suites that need committed data, use a separate test database (`DATABASE_URL` in `.env.test`) and reset between test modules.

## API Endpoint Testing

Test each endpoint for the happy path, validation errors, not-found cases, and authorization. Always verify both the status code and the response body.

```python
async def test_create_item_missing_title_returns_422(client, auth_headers):
    resp = await client.post("/api/v1/items", json={}, headers=auth_headers)
    assert resp.status_code == 422
    assert "title" in resp.json()["detail"][0]["loc"]

async def test_get_item_not_found_returns_404(client):
    resp = await client.get("/api/v1/items/9999")
    assert resp.status_code == 404
    assert resp.json()["detail"] == "Item not found"

async def test_update_item_returns_updated_fields(client, auth_headers, seeded_item):
    resp = await client.patch(
        f"/api/v1/items/{seeded_item.id}", json={"title": "Updated"}, headers=auth_headers)
    assert resp.status_code == 200
    assert resp.json()["title"] == "Updated"

async def test_delete_item_without_auth_returns_401(client):
    resp = await client.delete("/api/v1/items/1")
    assert resp.status_code == 401
```

## Mocking

Use FastAPI dependency overrides to swap real dependencies with test doubles. For external services, combine overrides with `unittest.mock.AsyncMock`.

```python
from unittest.mock import AsyncMock, patch

# Override a dependency with a mock for the test client.
@pytest.fixture
async def client_with_mock_email(db_session):
    mock_email = AsyncMock()
    app.dependency_overrides[get_db] = lambda: db_session
    app.dependency_overrides[get_email_service] = lambda: mock_email
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac, mock_email
    app.dependency_overrides.clear()

async def test_create_user_sends_welcome_email(client_with_mock_email):
    client, mock_email = client_with_mock_email
    resp = await client.post("/api/v1/users", json={"email": "a@b.com", "password": "s3cret"})
    assert resp.status_code == 201
    mock_email.send_welcome.assert_awaited_once_with("a@b.com")

# Patch an external call inside a service.
async def test_service_handles_payment_failure(db_session):
    with patch("app.services.payment.stripe.charge", new_callable=AsyncMock) as mock:
        mock.side_effect = PaymentError("Card declined")
        with pytest.raises(PaymentError, match="Card declined"):
            await PaymentService(db_session).process(amount=100, token="tok_test")
```
