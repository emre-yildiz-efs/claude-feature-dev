---
name: fastapi-conventions
description: FastAPI project conventions and patterns. Loaded by agents to understand project structure, router organization, service patterns, and schema conventions.
---

# FastAPI Conventions & Patterns

## Project Structure

Organize code by layer, not by feature. Each layer has a single responsibility.

```
app/
  api/v1/          # Versioned route definitions (routers)
  services/        # Business logic, orchestration
  repositories/    # Database queries and data access
  models/          # SQLAlchemy / SQLModel table definitions
  schemas/         # Pydantic request/response models
  core/            # Config, security, database engine, constants
  dependencies/    # Reusable Depends() callables
  main.py          # App factory, middleware, router includes
```

## Router Patterns

Routers live in `app/api/v1/` and handle HTTP concerns only -- parsing requests, calling services, returning responses. No business logic in route handlers.

```python
from fastapi import APIRouter, Depends, status
from app.schemas.item import ItemCreate, ItemRead, ItemUpdate
from app.services.item import ItemService
from app.dependencies.auth import get_current_user
from app.dependencies.db import get_db

router = APIRouter(prefix="/items", tags=["items"])

@router.get("/", response_model=list[ItemRead])
async def list_items(skip: int = 0, limit: int = 20, db=Depends(get_db)):
    return await ItemService(db).list(skip=skip, limit=limit)

@router.post("/", response_model=ItemRead, status_code=status.HTTP_201_CREATED)
async def create_item(body: ItemCreate, db=Depends(get_db), user=Depends(get_current_user)):
    return await ItemService(db).create(body, owner_id=user.id)

@router.patch("/{item_id}", response_model=ItemRead)
async def update_item(item_id: int, body: ItemUpdate, db=Depends(get_db)):
    return await ItemService(db).update(item_id, body)
```

## Service Layer

Services contain business logic, enforce rules, and manage transactions. They receive a database session and call repositories for data access.

```python
from fastapi import HTTPException, status
from app.repositories.item import ItemRepository

class ItemService:
    def __init__(self, db):
        self.repo = ItemRepository(db)

    async def get_or_404(self, item_id: int):
        item = await self.repo.get_by_id(item_id)
        if not item:
            raise HTTPException(status_code=404, detail="Item not found")
        return item

    async def create(self, data, owner_id: int):
        return await self.repo.create({**data.model_dump(), "owner_id": owner_id})

    async def update(self, item_id: int, data):
        item = await self.get_or_404(item_id)
        return await self.repo.update(item, data.model_dump(exclude_unset=True))
```

## Repository Pattern

Repositories encapsulate all database queries. They accept and return ORM models, never raw SQL or Pydantic schemas.

```python
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

class ItemRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_id(self, item_id: int):
        return await self.db.get(Item, item_id)

    async def list(self, *, skip: int = 0, limit: int = 20):
        stmt = select(Item).offset(skip).limit(limit).order_by(Item.created_at.desc())
        return list((await self.db.execute(stmt)).scalars().all())

    async def create(self, data: dict):
        item = Item(**data)
        self.db.add(item)
        await self.db.commit()
        await self.db.refresh(item)
        return item
```

## Schema Conventions

Use Pydantic v2 with the Create/Update/Read pattern. Shared fields go in a base class. Use `model_config` instead of inner `Config`.

```python
from pydantic import BaseModel, ConfigDict, field_validator
from datetime import datetime

class ItemBase(BaseModel):
    title: str
    description: str | None = None

class ItemCreate(ItemBase):
    @field_validator("title")
    @classmethod
    def title_not_blank(cls, v: str) -> str:
        if not v.strip(): raise ValueError("Title cannot be blank")
        return v.strip()

class ItemUpdate(BaseModel):          # all fields optional for partial updates
    title: str | None = None
    description: str | None = None

class ItemRead(ItemBase):
    id: int
    owner_id: int
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)
```

## Error Handling

Define custom exceptions and register global handlers for consistent error responses across the application.

```python
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

class AppError(Exception):
    def __init__(self, message: str, code: str, status_code: int = 400):
        self.message, self.code, self.status_code = message, code, status_code

class NotFoundError(AppError):
    def __init__(self, resource: str, id: int | str):
        super().__init__(f"{resource} {id} not found", "not_found", 404)

def register_exception_handlers(app: FastAPI):
    @app.exception_handler(AppError)
    async def handle(request: Request, exc: AppError):
        return JSONResponse(status_code=exc.status_code,
            content={"error": {"code": exc.code, "message": exc.message}})
```

## Auth Patterns

Use a `get_current_user` dependency that decodes a JWT from the `Authorization` header. Layer permission checks as additional dependencies.

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt

bearer_scheme = HTTPBearer()

async def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(bearer_scheme), db=Depends(get_db),
):
    try:
        payload = jwt.decode(creds.credentials, settings.secret_key, algorithms=["HS256"])
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    user = await db.get(User, payload["sub"])
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user

def require_role(role: str):
    async def checker(user=Depends(get_current_user)):
        if role not in user.roles:
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        return user
    return checker
```

## Configuration

Use `pydantic-settings` to load environment variables into a typed `Settings` object. Access settings via a cached dependency or module-level instance.

```python
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    app_name: str = "my-api"
    debug: bool = False
    database_url: str
    secret_key: str
    allowed_origins: list[str] = ["http://localhost:3000"]

@lru_cache
def get_settings() -> Settings:
    return Settings()

settings = get_settings()
```
