"""
音乐相关 API 模式
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from app.models.music import InputType, MusicStatus

class MusicCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    input_type: InputType
    input_content: Optional[str] = None
    duration: int = Field(default=30, ge=15, le=120)

class MusicResponse(BaseModel):
    id: int
    user_id: int
    title: str
    description: Optional[str] = None
    input_type: InputType
    input_content: Optional[str] = None
    emotion_tags: Optional[List[str]] = None
    ai_analysis: Optional[str] = None
    music_url: str
    music_format: str
    duration: int
    file_size: int
    bpm: int
    genre: Optional[str] = None
    instruments: Optional[List[str]] = None
    status: MusicStatus
    is_public: bool
    play_count: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class MusicList(BaseModel):
    total: int
    items: List[MusicResponse]

class CollectionCreate(BaseModel):
    music_id: int
    folder_name: str = "default"
    note: Optional[str] = None

class CollectionResponse(BaseModel):
    id: int
    user_id: int
    music_id: int
    folder_name: str
    note: Optional[str] = None
    created_at: datetime
    music: Optional[MusicResponse] = None
    
    class Config:
        from_attributes = True

class PlaylistCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    is_public: bool = False

class PlaylistResponse(BaseModel):
    id: int
    user_id: int
    name: str
    description: Optional[str] = None
    cover_url: Optional[str] = None
    is_public: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True