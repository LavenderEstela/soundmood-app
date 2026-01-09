"""
API 路由包
"""
from .auth import router as auth_router
from .music import router as music_router
from .generate import router as generate_router
from .user import router as user_router

__all__ = [
    "auth_router",
    "music_router",
    "generate_router",
    "user_router",
]
