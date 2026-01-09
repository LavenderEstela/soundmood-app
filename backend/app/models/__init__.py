"""
数据库模型包
"""
from .user import User, UserSettings
from .music import Music, Collection, Favorite

__all__ = [
    "User",
    "UserSettings",
    "Music",
    "Collection",
    "Favorite",
]
