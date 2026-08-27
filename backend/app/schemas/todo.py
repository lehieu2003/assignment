from typing import Optional
from datetime import datetime
from pydantic import BaseModel, ConfigDict


class TodoBase(BaseModel):
    title: str
    description: Optional[str] = None
    is_completed: Optional[bool] = False


class TodoCreate(TodoBase):
    pass


class TodoUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    is_completed: Optional[bool] = None


class TodoResponse(TodoBase):
    id: int
    owner_id: int
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
