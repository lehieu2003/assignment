from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api import deps
from app.core.database import get_db
from app.models.user import User
from app.schemas.todo import TodoCreate, TodoUpdate, TodoResponse
from app.schemas.response import MessageResponse
from app.services.todo_service import TodoService

router = APIRouter()


@router.get("/", response_model=List[TodoResponse])
def get_todos(
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_user),
    skip: int = Query(0, ge=0, description="Offset"),
    limit: int = Query(100, ge=1, le=100, description="Limit"),
    is_completed: Optional[bool] = Query(None, description="Filter by completion status"),
    search: Optional[str] = Query(None, description="Search in title or description"),
) -> Any:
    """
    Retrieve current user's todos with pagination, completion filter, and search.
    """
    todos = TodoService.get_multi_by_owner(
        db,
        owner_id=current_user.id,
        skip=skip,
        limit=limit,
        is_completed=is_completed,
        search=search,
    )
    return todos


@router.post("/", response_model=TodoResponse, status_code=status.HTTP_201_CREATED)
def create_todo(
    *,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_user),
    todo_in: TodoCreate,
) -> Any:
    """
    Create a new todo for the current user.
    """
    todo = TodoService.create(db, obj_in=todo_in, owner_id=current_user.id)
    return todo


@router.get("/{id}", response_model=TodoResponse)
def get_todo_by_id(
    *,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_user),
    id: int,
) -> Any:
    """
    Get a specific todo by ID.
    """
    todo = TodoService.get_by_id(db, todo_id=id, owner_id=current_user.id)
    if not todo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Todo not found",
        )
    return todo


@router.put("/{id}", response_model=TodoResponse)
def update_todo(
    *,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_user),
    id: int,
    todo_in: TodoUpdate,
) -> Any:
    """
    Update an existing todo.
    """
    todo = TodoService.get_by_id(db, todo_id=id, owner_id=current_user.id)
    if not todo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Todo not found",
        )
    todo = TodoService.update(db, db_obj=todo, obj_in=todo_in)
    return todo


@router.delete("/{id}", response_model=MessageResponse)
def delete_todo(
    *,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_user),
    id: int,
) -> Any:
    """
    Delete a todo by ID.
    """
    todo = TodoService.get_by_id(db, todo_id=id, owner_id=current_user.id)
    if not todo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Todo not found",
        )
    TodoService.delete(db, db_obj=todo)
    return MessageResponse(message="Todo deleted successfully")
