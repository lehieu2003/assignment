from fastapi import APIRouter
from app.api.v1.endpoints import health, auth, todos

api_router = APIRouter()
api_router.include_router(health.router, prefix="/health", tags=["Health"])
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(todos.router, prefix="/todos", tags=["Todos"])

