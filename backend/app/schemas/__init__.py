"""
API Schema 包
"""
from .user import (
    UserCreate,
    UserLogin,
    UserResponse,
    Token,
    UserSettingsResponse,
    UserSettingsUpdate,
    UserProfileUpdate,
)
from .music import (
    InputType,
    MusicStatus,
    MusicCreate,
    MusicResponse,
    MusicWithFavorite,
    MusicListResponse,
    MusicList,
    CollectionCreate,
    CollectionUpdate,
    CollectionResponse,
    JournalEntry,
    JournalResponse,
    UserStatsResponse,
    MusicStatusResponse,
    TextGenerateRequest,
    GenerateResponse,
)

__all__ = [
    # User schemas
    "UserCreate",
    "UserLogin",
    "UserResponse",
    "Token",
    "UserSettingsResponse",
    "UserSettingsUpdate",
    "UserProfileUpdate",
    # Music schemas
    "InputType",
    "MusicStatus",
    "MusicCreate",
    "MusicResponse",
    "MusicWithFavorite",
    "MusicListResponse",
    "MusicList",
    "CollectionCreate",
    "CollectionUpdate",
    "CollectionResponse",
    "JournalEntry",
    "JournalResponse",
    "UserStatsResponse",
    "MusicStatusResponse",
    "TextGenerateRequest",
    "GenerateResponse",
]
