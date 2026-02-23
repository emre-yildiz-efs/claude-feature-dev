---
name: python-quality
description: Python code quality standards including linting, formatting, and type checking conventions.
---

# Python Code Quality Standards

## Ruff

Ruff replaces flake8, isort, pyupgrade, and several other tools in a single fast linter. Enable a broad rule set and suppress only rules that conflict with the formatter.

```toml
# pyproject.toml
[tool.ruff]
target-version = "py312"
line-length = 88

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "B", "SIM", "A", "C4", "DTZ", "T20", "RUF"]
ignore = ["E501", "B008"]  # line length (formatter), Depends() calls

[tool.ruff.lint.per-file-ignores]
"tests/**/*.py" = ["S101"]
"alembic/**/*.py" = ["UP", "I"]

[tool.ruff.lint.isort]
known-first-party = ["app"]
```

## Black

Black is the canonical formatter. Keep defaults (88-char lines) and set the target version. When using ruff's built-in formatter instead, configure it to match.

```toml
[tool.black]
target-version = ["py312"]
line-length = 88

[tool.ruff.format]       # alternative: ruff formatter
quote-style = "double"
indent-style = "space"
```

## Mypy

Enable strict mode with the Pydantic plugin. Add per-module overrides for libraries that lack stubs.

```toml
[tool.mypy]
python_version = "3.12"
strict = true
plugins = ["pydantic.mypy"]
warn_return_any = true
warn_unused_configs = true

[[tool.mypy.overrides]]
module = ["alembic.*", "celery.*", "redis.*"]
ignore_missing_imports = true

[tool.pydantic-mypy]
init_forbid_extra = true
init_typed = true
warn_required_dynamic_aliases = true
```

## Import Ordering

Import sorting is handled by ruff's isort rules. Group into stdlib, third-party, first-party, and local-folder sections.

```python
from __future__ import annotations       # future
import os                                # stdlib
from collections.abc import Sequence
from fastapi import APIRouter, Depends   # third-party
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.config import settings     # first-party
from app.schemas.item import ItemRead
from .dependencies import get_db         # local-folder
```

## Type Annotations

Annotate all function signatures and variable assignments where the type is not obvious. Use modern union syntax and built-in generics.

```python
# Always annotate parameters and return types.
async def get_item(item_id: int, db: AsyncSession) -> Item | None:
    return await db.get(Item, item_id)

# Use X | None instead of Optional[X]. Use built-in generics (list, dict, set).
def get_ids(items: list[Item]) -> set[int]:
    return {item.id for item in items}

# TypeVar for generic helpers.
from typing import TypeVar
T = TypeVar("T")

async def get_or_404(db: AsyncSession, model: type[T], pk: int) -> T:
    obj = await db.get(model, pk)
    if not obj:
        raise HTTPException(status_code=404)
    return obj

# Annotate when type is non-obvious; skip when self-evident.
items: list[Item] = []
name = "example"  # clearly str -- no annotation needed
```

## Docstrings

Use Google-style docstrings on all public API functions and classes. Private helpers and test functions do not need docstrings when the logic is self-explanatory.

```python
class ItemService:
    """Handles business logic for item management."""

    async def transfer_ownership(self, item_id: int, new_owner_id: int) -> Item:
        """Transfer item ownership to another user.

        Args:
            item_id: The ID of the item to transfer.
            new_owner_id: The user ID of the new owner.

        Returns:
            The updated item with new ownership.

        Raises:
            NotFoundError: If the item does not exist.
        """
        item = await self._get_or_raise(item_id)
        item.owner_id = new_owner_id
        return await self.repo.save(item)

    def _build_filter(self, status: str) -> dict:
        # Private helper -- no docstring needed.
        return {"status": status, "deleted_at": None}
```

## Logging

Use `structlog` for structured, JSON-friendly output. Attach contextual key-value pairs rather than interpolating values into message strings.

```python
import structlog
logger = structlog.get_logger()

async def create_item(data: ItemCreate, owner_id: int) -> Item:
    logger.info("creating_item", owner_id=owner_id, title=data.title)
    item = await repo.create({**data.model_dump(), "owner_id": owner_id})
    logger.info("item_created", item_id=item.id)
    return item

async def process_payment(order_id: int, amount: float) -> None:
    log = logger.bind(order_id=order_id)  # bind context for all calls
    log.info("payment_started", amount=amount)
    try:
        result = await gateway.charge(amount)
        log.info("payment_succeeded", transaction_id=result.id)
    except PaymentError:
        log.error("payment_failed", amount=amount)
        raise
```

Log levels: **DEBUG** for dev diagnostics, **INFO** for normal operations, **WARNING** for recoverable issues (retries, slow queries), **ERROR** for failures needing attention, **CRITICAL** for system-unusable states.
