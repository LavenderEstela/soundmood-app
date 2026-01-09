"""
音乐相关数据模型 - 完整修复版
"""
from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, Enum, ForeignKey, JSON, UniqueConstraint
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


class EmotionType(str, enum.Enum):
    happy = "happy"
    calm = "calm"
    sad = "sad"
    energetic = "energetic"
    nostalgic = "nostalgic"


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
    primary_emotion = Column(String(50), index=True)
    ai_analysis = Column(Text)
    
    # 音乐文件信息
    music_url = Column(String(500), nullable=False)
    cover_url = Column(String(500))
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
    favorites = relationship("Favorite", back_populates="music", cascade="all, delete-orphan")


class Collection(Base):
    """用户收藏夹/文件夹"""
    __tablename__ = "collections"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    music_id = Column(Integer, ForeignKey("musics.id", ondelete="CASCADE"), nullable=False)
    folder_name = Column(String(100), default="default")
    note = Column(Text)
    tags = Column(JSON)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    user = relationship("User", back_populates="collections")
    music = relationship("Music", back_populates="collections")


class Favorite(Base):
    """用户喜欢/收藏的音乐（简单收藏，不分文件夹）"""
    __tablename__ = "favorites"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    music_id = Column(Integer, ForeignKey("musics.id", ondelete="CASCADE"), nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 确保用户不能重复收藏同一首歌
    __table_args__ = (
        UniqueConstraint('user_id', 'music_id', name='unique_user_music_favorite'),
    )
    
    # 关系
    user = relationship("User", back_populates="favorites")
    music = relationship("Music", back_populates="favorites")


class Playlist(Base):
    __tablename__ = "playlists"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(255), nullable=False)
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
    playlist_id = Column(Integer, ForeignKey("playlists.id", ondelete="CASCADE"), nullable=False)
    music_id = Column(Integer, ForeignKey("musics.id", ondelete="CASCADE"), nullable=False)
    position = Column(Integer, default=0)
    added_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    playlist = relationship("Playlist", back_populates="items")
    music = relationship("Music")


class GenerationLog(Base):
    __tablename__ = "generation_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    music_id = Column(Integer, ForeignKey("musics.id", ondelete="CASCADE"), nullable=False)
    step = Column(String(100))
    status = Column(String(50))
    message = Column(Text)
    progress = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    music = relationship("Music")
