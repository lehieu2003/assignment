from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import or_
from app.models.todo import Todo
from app.schemas.todo import TodoCreate, TodoUpdate


class TodoService:
    @staticmethod
    def get_by_id(db: Session, todo_id: int, owner_id: int) -> Optional[Todo]:
        return (
            db.query(Todo)
            .filter(Todo.id == todo_id, Todo.owner_id == owner_id)
            .first()
        )

    @staticmethod
    def get_multi_by_owner(
        db: Session,
        owner_id: int,
        skip: int = 0,
        limit: int = 100,
        is_completed: Optional[bool] = None,
        search: Optional[str] = None,
    ) -> List[Todo]:
        query = db.query(Todo).filter(Todo.owner_id == owner_id)
        if is_completed is not None:
            query = query.filter(Todo.is_completed == is_completed)
        if search:
            query = query.filter(
                or_(
                    Todo.title.ilike(f"%{search}%"),
                    Todo.description.ilike(f"%{search}%"),
                )
            )
        return query.order_by(Todo.created_at.desc()).offset(skip).limit(limit).all()

    @staticmethod
    def create(db: Session, obj_in: TodoCreate, owner_id: int) -> Todo:
        db_obj = Todo(
            title=obj_in.title,
            description=obj_in.description,
            is_completed=obj_in.is_completed if obj_in.is_completed is not None else False,
            owner_id=owner_id,
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    @staticmethod
    def update(db: Session, db_obj: Todo, obj_in: TodoUpdate) -> Todo:
        if obj_in.title is not None:
            db_obj.title = obj_in.title
        if obj_in.description is not None:
            db_obj.description = obj_in.description
        if obj_in.is_completed is not None:
            db_obj.is_completed = obj_in.is_completed
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    @staticmethod
    def delete(db: Session, db_obj: Todo) -> None:
        db.delete(db_obj)
        db.commit()
