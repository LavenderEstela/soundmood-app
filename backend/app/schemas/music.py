"""
音乐相关 API 模式 - 完整版
"""
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime, date
from enum import Enum


class InputType(str, Enum):
    voice = "voice"
    text = "text"
    image = "image"


class MusicStatus(str, Enum):
    generating = "generating"
    completed = "completed"
    failed = "failed"


# 音乐创建请求
class MusicCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    input_type: InputType
    input_content: Optional[str] = None
    duration: int = Field(default=30, ge=15, le=120)


# 音乐基础响应
class MusicResponse(BaseModel):
    id: int
    user_id: int
    title: str
    description: Optional[str]
    input_type: InputType
    input_content: Optional[str]
    emotion_tags: Optional[List[str]]
    primary_emotion: Optional[str]
    ai_analysis: Optional[str]
    music_url: str
    cover_url: Optional[str]
    music_format: str
    duration: int
    file_size: int
    bpm: int
    genre: Optional[str]
    instruments: Optional[List[str]]
    status: MusicStatus
    is_public: bool
    play_count: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# 带收藏状态的音乐响应
class MusicWithFavorite(MusicResponse):
    is_favorite: bool = False


# 音乐列表响应
class MusicListResponse(BaseModel):
    items: List[MusicWithFavorite]
    total: int
    skip: int
    limit: int


# 为兼容性添加别名
MusicList = MusicListResponse


# 收藏创建请求
class CollectionCreate(BaseModel):
    music_id: int
    folder_name: Optional[str] = "default"
    note: Optional[str] = None
    tags: Optional[List[str]] = None


# 收藏更新请求
class CollectionUpdate(BaseModel):
    folder_name: Optional[str] = None
    note: Optional[str] = None
    tags: Optional[List[str]] = None


# 收藏响应
class CollectionResponse(BaseModel):
    id: int
    user_id: int
    music_id: int
    folder_name: str
    note: Optional[str]
    tags: Optional[List[str]]
    created_at: datetime
    music: Optional[MusicResponse] = None
    
    class Config:
        from_attributes = True


# 日记条目
class JournalEntry(BaseModel):
    date: date
    items: List[MusicWithFavorite]
    count: int


# 日记列表响应
class JournalResponse(BaseModel):
    entries: List[JournalEntry]
    total: int


# 用户统计信息
class UserStatsResponse(BaseModel):
    total_count: int
    monthly_count: int
    total_duration: int
    favorite_count: int
    emotion_distribution: Dict[str, int]


# 音乐状态响应
class MusicStatusResponse(BaseModel):
    id: int
    status: MusicStatus
    progress: Optional[int] = None
    error_message: Optional[str] = None
    music_url: Optional[str] = None


# 文本生成请求
class TextGenerateRequest(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    text: str = Field(..., min_length=1)
    duration: int = Field(default=30, ge=15, le=120)


# 生成响应
class GenerateResponse(BaseModel):
    id: int
    status: MusicStatus
    message: str
