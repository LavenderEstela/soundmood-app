"""
业务逻辑服务包
"""
from .auth_service import *
from .music_service import *
from .ai_service import *

__all__ = [
    "authenticate_user",
    "create_user",
    "get_current_user",
    "create_music",
    "get_user_musics",
    "AIService"
]