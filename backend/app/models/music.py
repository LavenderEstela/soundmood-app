"""
音乐相关数据模型
"""
from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, Enum, ForeignKey, JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base
import enum

class InputType(str, enum.Enum):
    voice = "voice"
    text = "text"
    image = "image"

class MusicStatus(str, enum.Enum):
    generating = "generating"
    completed = "completed"
    failed = "failed"

class Music(Base):
    __tablename__ = "musics"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text)
    
    # 输入信息
    input_type = Column(Enum(InputType), nullable=False)
    input_content = Column(Text)
    emotion_tags = Column(JSON)
    ai_analysis = Column(Text)
    
    # 音乐文件信息
    music_url = Column(String(500), nullable=False)
    music_format = Column(String(10), default="mp3")
    duration = Column(Integer, default=0)
    file_size = Column(Integer, default=0)
    
    # 音乐参数
    bpm = Column(Integer, default=120)
    genre = Column(String(100))
    instruments = Column(JSON)
    
    # 状态
    status = Column(Enum(MusicStatus), default=MusicStatus.generating, index=True)
    is_public = Column(Boolean, default=False)
    play_count = Column(Integer, default=0)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 关系
    user = relationship("User", back_populates="musics")
    collections = relationship("Collection", back_populates="music", cascade="all, delete-orphan")
    playlist_items = relationship("PlaylistItem", back_populates="music", cascade="all, delete-orphan")
    generation_logs = relationship("GenerationLog", back_populates="music", cascade="all, delete-orphan")

class Collection(Base):
    __tablename__ = "collections"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    music_id = Column(Integer, ForeignKey("musics.id", ondelete="CASCADE"), nullable=False)
    folder_name = Column(String(100), default="default")
    note = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    user = relationship("User", back_populates="collections")
    music = relationship("Music", back_populates="collections")

class Playlist(Base):
    __tablename__ = "playlists"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(200), nullable=False)
    description = Column(Text)
    cover_url = Column(String(500))
    is_public = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 关系
    user = relationship("User", back_populates="playlists")
    items = relationship("PlaylistItem", back_populates="playlist", cascade="all, delete-orphan")

class PlaylistItem(Base):
    __tablename__ = "playlist_items"
    
    id = Column(Integer, primary_key=True, index=True)
    playlist_id = Column(Integer, ForeignKey("playlists.id", ondelete="CASCADE"), nullable=False, index=True)
    music_id = Column(Integer, ForeignKey("musics.id", ondelete="CASCADE"), nullable=False)
    order_index = Column(Integer, default=0)
    added_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    playlist = relationship("Playlist", back_populates="items")
    music = relationship("Music", back_populates="playlist_items")

class GenerationLog(Base):
    __tablename__ = "generation_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    music_id = Column(Integer, ForeignKey("musics.id", ondelete="CASCADE"), nullable=False)
    
    # 耗时统计
    asr_time = Column(Integer, default=0)
    analysis_time = Column(Integer, default=0)
    generation_time = Column(Integer, default=0)
    total_time = Column(Integer, default=0)
    
    # 模型信息
    asr_model = Column(String(100))
    llm_model = Column(String(100))
    music_model = Column(String(100))
    
    # 调试信息
    raw_prompt = Column(Text)
    raw_response = Column(Text)
    error_message = Column(Text)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    music = relationship("Music", back_populates="generation_logs")