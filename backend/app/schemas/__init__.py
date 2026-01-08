"""
API 数据模式包
"""
from .user import *
from .music import *

__all__ = [
    "UserCreate", "UserLogin", "UserResponse", "Token",
    "MusicCreate", "MusicResponse", "MusicList",
    "CollectionCreate", "CollectionResponse",
    "PlaylistCreate", "PlaylistResponse"
]