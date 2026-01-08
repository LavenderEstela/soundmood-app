# SoundMood 后端代码 - 完整修复版

> ⚠️ **重要说明**: 此文档修复了原文档中的所有问题，包括：
> - 缺失的 `config.py` 配置文件
> - 缺失的 `ai_service.py` AI服务文件
> - `auth.py` 中缺少 `get_current_user` 导入
> - `music.py` 中缺少 `Music` 模型导入

---

## 📁 完整目录结构

```
backend/
├── app/
│   ├── __init__.py
│   ├── config.py           ← 【新增】配置文件
│   ├── database.py
│   ├── main.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── music.py
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── music.py
│   ├── services/
│   │   ├── __init__.py
│   │   ├── auth_service.py
│   │   ├── music_service.py
│   │   └── ai_service.py   ← 【新增】AI服务
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── auth.py         ← 【已修复】
│   │   ├── music.py        ← 【已修复】
│   │   └── generate.py
│   └── utils/
│       ├── __init__.py
│       └── security.py
├── uploads/                 ← 自动创建
│   ├── music/
│   ├── images/
│   └── temp/
├── run.py
├── requirements.txt
└── .env
```

---

## 1. 配置文件 【新增】

### 文件: `backend/app/config.py`

```python
"""
应用配置管理
"""
from pydantic_settings import BaseSettings
from pathlib import Path
from typing import Optional

class Settings(BaseSettings):
    """
    应用配置（从环境变量或 .env 文件加载）
    """
    # 应用基本信息
    APP_NAME: str = "SoundMood"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    
    # 服务器配置
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    
    # 数据库配置
    DATABASE_URL: str = "sqlite:///./soundmood.db"
    
    # JWT 配置
    SECRET_KEY: str = "your-super-secret-key-change-in-production-min-32-chars"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7天
    
    # AI 服务配置
    OPENAI_API_KEY: Optional[str] = None
    OPENAI_BASE_URL: Optional[str] = None
    SUNO_API_KEY: Optional[str] = None
    SUNO_API_URL: str = "https://api.suno.ai"
    
    # 文件存储配置
    BASE_DIR: Path = Path(__file__).resolve().parent.parent
    UPLOAD_DIR: Path = BASE_DIR / "uploads"
    MUSIC_DIR: Path = UPLOAD_DIR / "music"
    IMAGE_DIR: Path = UPLOAD_DIR / "images"
    TEMP_DIR: Path = UPLOAD_DIR / "temp"
    
    # 音乐生成配置
    DEFAULT_MUSIC_DURATION: int = 30
    MAX_MUSIC_DURATION: int = 120
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        extra = "ignore"
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # 确保上传目录存在
        self.UPLOAD_DIR.mkdir(exist_ok=True)
        self.MUSIC_DIR.mkdir(exist_ok=True)
        self.IMAGE_DIR.mkdir(exist_ok=True)
        self.TEMP_DIR.mkdir(exist_ok=True)

# 全局配置实例
settings = Settings()
```

### 文件: `backend/.env` (示例)

```env
# 应用配置
APP_NAME=SoundMood
DEBUG=True

# 数据库（SQLite 用于开发，生产环境用 PostgreSQL）
DATABASE_URL=sqlite:///./soundmood.db

# JWT 密钥（生产环境必须更换！）
SECRET_KEY=your-super-secret-key-change-in-production-min-32-chars

# AI 服务 API 密钥
OPENAI_API_KEY=sk-your-openai-key
OPENAI_BASE_URL=https://api.openai.com/v1

# Suno API（如果使用）
SUNO_API_KEY=your-suno-api-key
```

---

## 2. 数据库连接

### 文件: `backend/app/database.py`

```python
"""
数据库连接和会话管理
"""
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from app.config import settings

# 创建数据库引擎
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=3600,
    echo=settings.DEBUG,
    connect_args={"check_same_thread": False} if "sqlite" in settings.DATABASE_URL else {}
)

# 会话工厂
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 模型基类
Base = declarative_base()

def get_db():
    """
    依赖注入函数：为每个请求提供数据库会话
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    """
    初始化数据库（创建所有表）
    """
    from app.models import user, music
    Base.metadata.create_all(bind=engine)
    print("✅ 数据库表创建完成！")
```

---

## 3. 数据模型

### 文件: `backend/app/models/__init__.py`

```python
"""
数据模型包
"""
from .user import User, UserSettings
from .music import Music, Collection, Playlist, PlaylistItem, GenerationLog, InputType, MusicStatus

__all__ = [
    "User",
    "UserSettings", 
    "Music",
    "Collection",
    "Playlist",
    "PlaylistItem",
    "GenerationLog",
    "InputType",
    "MusicStatus"
]
```

### 文件: `backend/app/models/user.py`

```python
"""
用户相关数据模型
"""
from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    username = Column(String(100), nullable=False)
    hashed_password = Column(String(255), nullable=False)
    avatar_url = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 关系
    musics = relationship("Music", back_populates="user", cascade="all, delete-orphan")
    collections = relationship("Collection", back_populates="user", cascade="all, delete-orphan")
    playlists = relationship("Playlist", back_populates="user", cascade="all, delete-orphan")
    settings = relationship("UserSettings", back_populates="user", uselist=False, cascade="all, delete-orphan")

class UserSettings(Base):
    __tablename__ = "user_settings"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True)
    preferred_language = Column(String(10), default="zh")
    default_duration = Column(Integer, default=30)
    default_genre = Column(String(100), default="pop")
    notify_on_complete = Column(Boolean, default=True)
    public_profile = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 关系
    user = relationship("User", back_populates="settings")
```

### 文件: `backend/app/models/music.py`

```python
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
    music_url = Column(String(500), nullable=False, default="")
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
```

---

## 4. Pydantic 模式

### 文件: `backend/app/schemas/__init__.py`

```python
"""
API 数据模式包
"""
from .user import UserCreate, UserLogin, UserResponse, Token, TokenData
from .music import (
    MusicCreate, MusicResponse, MusicList,
    CollectionCreate, CollectionResponse,
    PlaylistCreate, PlaylistResponse
)

__all__ = [
    "UserCreate", "UserLogin", "UserResponse", "Token", "TokenData",
    "MusicCreate", "MusicResponse", "MusicList",
    "CollectionCreate", "CollectionResponse",
    "PlaylistCreate", "PlaylistResponse"
]
```

### 文件: `backend/app/schemas/user.py`

```python
"""
用户相关 API 模式
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    username: str = Field(..., min_length=2, max_length=100)

class UserCreate(UserBase):
    password: str = Field(..., min_length=6, max_length=50)

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(UserBase):
    id: int
    avatar_url: Optional[str] = None
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse

class TokenData(BaseModel):
    email: Optional[str] = None
```

### 文件: `backend/app/schemas/music.py`

```python
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
```

---

## 5. 工具函数

### 文件: `backend/app/utils/__init__.py`

```python
"""
工具函数包
"""
from .security import (
    get_password_hash,
    verify_password,
    create_access_token,
    verify_token
)

__all__ = [
    "get_password_hash",
    "verify_password",
    "create_access_token",
    "verify_token"
]
```

### 文件: `backend/app/utils/security.py`

```python
"""
安全相关工具函数：密码加密、JWT 令牌
"""
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.config import settings

# 密码加密上下文
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str:
    """
    将明文密码转换为哈希值
    """
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    验证密码是否匹配
    """
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    创建 JWT 访问令牌
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt

def verify_token(token: str) -> Optional[str]:
    """
    验证 JWT 令牌并返回用户邮箱
    """
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            return None
        return email
    except JWTError:
        return None
```

---

## 6. 业务服务层

### 文件: `backend/app/services/__init__.py`

```python
"""
业务逻辑服务包
"""
from .auth_service import authenticate_user, create_user, get_current_user
from .music_service import create_music, get_user_musics, get_music_by_id, add_to_collection, get_user_collections
from .ai_service import AIService

__all__ = [
    "authenticate_user",
    "create_user",
    "get_current_user",
    "create_music",
    "get_user_musics",
    "get_music_by_id",
    "add_to_collection",
    "get_user_collections",
    "AIService"
]
```

### 文件: `backend/app/services/auth_service.py`

```python
"""
用户认证服务
"""
from sqlalchemy.orm import Session
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from app.models.user import User, UserSettings
from app.schemas.user import UserCreate
from app.utils.security import get_password_hash, verify_password, verify_token
from app.database import get_db

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")

def create_user(db: Session, user_data: UserCreate) -> User:
    """
    创建新用户
    """
    # 检查邮箱是否已存在
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="该邮箱已被注册"
        )
    
    # 创建用户
    hashed_password = get_password_hash(user_data.password)
    db_user = User(
        email=user_data.email,
        username=user_data.username,
        hashed_password=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    # 创建默认设置
    user_settings = UserSettings(user_id=db_user.id)
    db.add(user_settings)
    db.commit()
    
    return db_user

def authenticate_user(db: Session, email: str, password: str) -> User:
    """
    验证用户凭据
    """
    user = db.query(User).filter(User.email == email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="邮箱或密码错误"
        )
    if not verify_password(password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="邮箱或密码错误"
        )
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="账户已被禁用"
        )
    return user

def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> User:
    """
    从令牌获取当前用户
    """
    email = verify_token(token)
    if email is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="无效的认证凭据",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="用户不存在"
        )
    
    return user
```

### 文件: `backend/app/services/music_service.py`

```python
"""
音乐管理服务
"""
from sqlalchemy.orm import Session
from sqlalchemy import desc
from typing import List, Optional
from app.models.music import Music, Collection, Playlist, PlaylistItem, MusicStatus
from app.models.user import User
from app.schemas.music import MusicCreate
from fastapi import HTTPException, status

def create_music(db: Session, user: User, music_data: MusicCreate) -> Music:
    """
    创建音乐记录（生成前）
    """
    db_music = Music(
        user_id=user.id,
        title=music_data.title,
        description=music_data.description,
        input_type=music_data.input_type,
        input_content=music_data.input_content,
        duration=music_data.duration,
        music_url="",
        status=MusicStatus.generating
    )
    db.add(db_music)
    db.commit()
    db.refresh(db_music)
    return db_music

def get_user_musics(
    db: Session,
    user_id: int,
    skip: int = 0,
    limit: int = 20,
    status_filter: Optional[str] = None
) -> List[Music]:
    """
    获取用户的音乐列表
    """
    query = db.query(Music).filter(Music.user_id == user_id)
    
    if status_filter:
        query = query.filter(Music.status == status_filter)
    
    musics = query.order_by(desc(Music.created_at)).offset(skip).limit(limit).all()
    return musics

def get_music_by_id(db: Session, music_id: int, user_id: Optional[int] = None) -> Music:
    """
    根据 ID 获取音乐
    """
    query = db.query(Music).filter(Music.id == music_id)
    
    if user_id:
        query = query.filter(Music.user_id == user_id)
    
    music = query.first()
    if not music:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="音乐不存在"
        )
    
    return music

def update_music_status(
    db: Session, 
    music_id: int, 
    status: MusicStatus,
    music_url: str = None,
    emotion_tags: List[str] = None,
    ai_analysis: str = None,
    genre: str = None,
    bpm: int = None
) -> Music:
    """
    更新音乐状态和信息
    """
    music = db.query(Music).filter(Music.id == music_id).first()
    if music:
        music.status = status
        if music_url:
            music.music_url = music_url
        if emotion_tags:
            music.emotion_tags = emotion_tags
        if ai_analysis:
            music.ai_analysis = ai_analysis
        if genre:
            music.genre = genre
        if bpm:
            music.bpm = bpm
        db.commit()
        db.refresh(music)
    return music

def add_to_collection(db: Session, user_id: int, music_id: int, folder_name: str = "default") -> Collection:
    """
    添加到收藏
    """
    # 检查是否已收藏
    existing = db.query(Collection).filter(
        Collection.user_id == user_id,
        Collection.music_id == music_id
    ).first()
    
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="已收藏该音乐"
        )
    
    collection = Collection(
        user_id=user_id,
        music_id=music_id,
        folder_name=folder_name
    )
    db.add(collection)
    db.commit()
    db.refresh(collection)
    return collection

def get_user_collections(db: Session, user_id: int, folder_name: Optional[str] = None) -> List[Collection]:
    """
    获取用户收藏列表
    """
    query = db.query(Collection).filter(Collection.user_id == user_id)
    
    if folder_name:
        query = query.filter(Collection.folder_name == folder_name)
    
    collections = query.order_by(desc(Collection.created_at)).all()
    return collections
```

### 文件: `backend/app/services/ai_service.py` 【新增 - 关键文件！】

```python
"""
AI 服务：情感分析 + 音乐生成
"""
import json
import time
import uuid
import httpx
from pathlib import Path
from typing import Optional, Dict, Any, List
from sqlalchemy.orm import Session

from app.config import settings
from app.models.music import Music, MusicStatus, GenerationLog

class AIService:
    """
    AI 服务类，负责：
    1. 语音转文字 (ASR)
    2. 情感分析 (LLM)
    3. 图像理解 (Vision)
    4. 音乐生成 (Music API)
    """
    
    def __init__(self):
        self.openai_api_key = settings.OPENAI_API_KEY
        self.openai_base_url = settings.OPENAI_BASE_URL or "https://api.openai.com/v1"
        self.suno_api_key = settings.SUNO_API_KEY
        self.suno_api_url = settings.SUNO_API_URL
    
    async def analyze_text_emotion(self, text: str) -> Dict[str, Any]:
        """
        分析文本情感，返回音乐生成参数
        """
        prompt = f"""分析以下文本的情感，并给出适合的音乐参数。

文本内容：
{text}

请返回 JSON 格式（不要包含其他内容）：
{{
    "emotions": ["主要情感1", "主要情感2"],
    "mood": "整体心情描述",
    "energy_level": "high/medium/low",
    "suggested_genre": "建议的音乐风格",
    "suggested_bpm": 120,
    "suggested_instruments": ["乐器1", "乐器2"],
    "music_prompt": "用于AI音乐生成的英文提示词"
}}
"""
        
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    f"{self.openai_base_url}/chat/completions",
                    headers={
                        "Authorization": f"Bearer {self.openai_api_key}",
                        "Content-Type": "application/json"
                    },
                    json={
                        "model": "gpt-3.5-turbo",
                        "messages": [
                            {"role": "system", "content": "你是一个情感分析和音乐推荐专家。请只返回JSON格式，不要包含其他文字。"},
                            {"role": "user", "content": prompt}
                        ],
                        "temperature": 0.7
                    }
                )
                
                if response.status_code == 200:
                    result = response.json()
                    content = result["choices"][0]["message"]["content"]
                    # 清理可能的 markdown 格式
                    content = content.strip()
                    if content.startswith("```"):
                        content = content.split("```")[1]
                        if content.startswith("json"):
                            content = content[4:]
                    return json.loads(content)
                else:
                    print(f"API 错误: {response.text}")
                    return self._get_default_analysis()
                    
        except Exception as e:
            print(f"情感分析失败: {e}")
            return self._get_default_analysis()
    
    async def analyze_image_emotion(self, image_path: str) -> Dict[str, Any]:
        """
        分析图片情感，返回音乐生成参数
        """
        import base64
        
        # 读取图片并转换为 base64
        with open(image_path, "rb") as f:
            image_data = base64.b64encode(f.read()).decode("utf-8")
        
        # 获取图片格式
        ext = Path(image_path).suffix.lower()
        media_type = {
            ".jpg": "image/jpeg",
            ".jpeg": "image/jpeg", 
            ".png": "image/png",
            ".gif": "image/gif",
            ".webp": "image/webp"
        }.get(ext, "image/jpeg")
        
        prompt = """分析这张图片的情感和氛围，给出适合的音乐参数。

请返回 JSON 格式（不要包含其他内容）：
{
    "image_description": "图片内容描述",
    "emotions": ["主要情感1", "主要情感2"],
    "mood": "整体氛围描述",
    "energy_level": "high/medium/low",
    "suggested_genre": "建议的音乐风格",
    "suggested_bpm": 120,
    "suggested_instruments": ["乐器1", "乐器2"],
    "music_prompt": "用于AI音乐生成的英文提示词"
}
"""
        
        try:
            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(
                    f"{self.openai_base_url}/chat/completions",
                    headers={
                        "Authorization": f"Bearer {self.openai_api_key}",
                        "Content-Type": "application/json"
                    },
                    json={
                        "model": "gpt-4o-mini",
                        "messages": [
                            {
                                "role": "user",
                                "content": [
                                    {"type": "text", "text": prompt},
                                    {
                                        "type": "image_url",
                                        "image_url": {
                                            "url": f"data:{media_type};base64,{image_data}"
                                        }
                                    }
                                ]
                            }
                        ],
                        "max_tokens": 1000
                    }
                )
                
                if response.status_code == 200:
                    result = response.json()
                    content = result["choices"][0]["message"]["content"]
                    content = content.strip()
                    if content.startswith("```"):
                        content = content.split("```")[1]
                        if content.startswith("json"):
                            content = content[4:]
                    return json.loads(content)
                else:
                    print(f"API 错误: {response.text}")
                    return self._get_default_analysis()
                    
        except Exception as e:
            print(f"图片分析失败: {e}")
            return self._get_default_analysis()
    
    async def transcribe_audio(self, audio_path: str) -> str:
        """
        语音转文字 (Whisper API)
        """
        try:
            async with httpx.AsyncClient(timeout=60.0) as client:
                with open(audio_path, "rb") as f:
                    files = {"file": (Path(audio_path).name, f, "audio/mpeg")}
                    data = {"model": "whisper-1"}
                    
                    response = await client.post(
                        f"{self.openai_base_url}/audio/transcriptions",
                        headers={"Authorization": f"Bearer {self.openai_api_key}"},
                        files=files,
                        data=data
                    )
                    
                    if response.status_code == 200:
                        result = response.json()
                        return result.get("text", "")
                    else:
                        print(f"ASR 错误: {response.text}")
                        return ""
                        
        except Exception as e:
            print(f"语音转文字失败: {e}")
            return ""
    
    async def generate_music(self, prompt: str, duration: int = 30) -> Optional[str]:
        """
        调用音乐生成 API
        
        注意：这里使用模拟实现，实际项目中需要替换为真实的音乐生成 API
        如 Suno API、MusicGen 等
        """
        # 模拟生成：创建一个占位音频文件
        # 实际项目中，这里应该调用真实的音乐生成 API
        
        try:
            # 生成唯一文件名
            filename = f"{uuid.uuid4()}.mp3"
            output_path = settings.MUSIC_DIR / filename
            
            # ============================================
            # 这里是模拟实现，生产环境请替换为真实 API
            # ============================================
            
            # 方案1: 使用 Suno API (示例)
            # if self.suno_api_key:
            #     async with httpx.AsyncClient(timeout=120.0) as client:
            #         response = await client.post(
            #             f"{self.suno_api_url}/generate",
            #             headers={"Authorization": f"Bearer {self.suno_api_key}"},
            #             json={
            #                 "prompt": prompt,
            #                 "duration": duration,
            #                 "style": "auto"
            #             }
            #         )
            #         if response.status_code == 200:
            #             audio_data = response.content
            #             with open(output_path, "wb") as f:
            #                 f.write(audio_data)
            #             return f"/uploads/music/{filename}"
            
            # 方案2: 模拟实现（开发测试用）
            # 创建一个简单的占位文件
            print(f"[模拟] 生成音乐: {prompt[:50]}...")
            print(f"[模拟] 时长: {duration}秒")
            
            # 这里创建一个空的占位文件
            # 实际项目中应该调用真实的音乐生成服务
            output_path.touch()
            
            # 模拟延迟
            await self._simulate_delay(3)
            
            return f"/uploads/music/{filename}"
            
        except Exception as e:
            print(f"音乐生成失败: {e}")
            return None
    
    async def _simulate_delay(self, seconds: int):
        """模拟处理延迟"""
        import asyncio
        await asyncio.sleep(seconds)
    
    def _get_default_analysis(self) -> Dict[str, Any]:
        """返回默认的分析结果"""
        return {
            "emotions": ["neutral", "calm"],
            "mood": "平静",
            "energy_level": "medium",
            "suggested_genre": "ambient",
            "suggested_bpm": 90,
            "suggested_instruments": ["piano", "strings"],
            "music_prompt": "calm peaceful ambient music with soft piano and gentle strings"
        }
    
    # ============================================
    # 后台任务：完整的音乐生成流程
    # ============================================
    
    async def generate_music_from_text(
        self,
        db: Session,
        music_id: int,
        text: str,
        duration: int = 30
    ):
        """
        从文本生成音乐的完整流程（后台任务）
        """
        start_time = time.time()
        
        try:
            # 1. 情感分析
            analysis_start = time.time()
            analysis = await self.analyze_text_emotion(text)
            analysis_time = int((time.time() - analysis_start) * 1000)
            
            # 2. 生成音乐
            gen_start = time.time()
            music_prompt = analysis.get("music_prompt", "peaceful ambient music")
            music_url = await self.generate_music(music_prompt, duration)
            generation_time = int((time.time() - gen_start) * 1000)
            
            # 3. 更新数据库
            total_time = int((time.time() - start_time) * 1000)
            
            music = db.query(Music).filter(Music.id == music_id).first()
            if music:
                if music_url:
                    music.status = MusicStatus.completed
                    music.music_url = music_url
                else:
                    music.status = MusicStatus.failed
                
                music.emotion_tags = analysis.get("emotions", [])
                music.ai_analysis = analysis.get("mood", "")
                music.genre = analysis.get("suggested_genre", "")
                music.bpm = analysis.get("suggested_bpm", 120)
                music.instruments = analysis.get("suggested_instruments", [])
                
                # 创建生成日志
                log = GenerationLog(
                    music_id=music_id,
                    analysis_time=analysis_time,
                    generation_time=generation_time,
                    total_time=total_time,
                    llm_model="gpt-3.5-turbo",
                    music_model="simulated",
                    raw_prompt=music_prompt,
                    raw_response=json.dumps(analysis, ensure_ascii=False)
                )
                db.add(log)
                db.commit()
                
        except Exception as e:
            print(f"音乐生成失败: {e}")
            music = db.query(Music).filter(Music.id == music_id).first()
            if music:
                music.status = MusicStatus.failed
                
                log = GenerationLog(
                    music_id=music_id,
                    error_message=str(e),
                    total_time=int((time.time() - start_time) * 1000)
                )
                db.add(log)
                db.commit()
    
    async def generate_music_from_voice(
        self,
        db: Session,
        music_id: int,
        audio_path: str,
        duration: int = 30
    ):
        """
        从语音生成音乐的完整流程（后台任务）
        """
        start_time = time.time()
        
        try:
            # 1. 语音转文字
            asr_start = time.time()
            text = await self.transcribe_audio(audio_path)
            asr_time = int((time.time() - asr_start) * 1000)
            
            if not text:
                text = "无法识别的语音内容，将生成平静的背景音乐"
            
            # 2. 情感分析
            analysis_start = time.time()
            analysis = await self.analyze_text_emotion(text)
            analysis_time = int((time.time() - analysis_start) * 1000)
            
            # 3. 生成音乐
            gen_start = time.time()
            music_prompt = analysis.get("music_prompt", "peaceful ambient music")
            music_url = await self.generate_music(music_prompt, duration)
            generation_time = int((time.time() - gen_start) * 1000)
            
            # 4. 更新数据库
            total_time = int((time.time() - start_time) * 1000)
            
            music = db.query(Music).filter(Music.id == music_id).first()
            if music:
                if music_url:
                    music.status = MusicStatus.completed
                    music.music_url = music_url
                else:
                    music.status = MusicStatus.failed
                
                music.input_content = text  # 保存转录的文本
                music.emotion_tags = analysis.get("emotions", [])
                music.ai_analysis = analysis.get("mood", "")
                music.genre = analysis.get("suggested_genre", "")
                music.bpm = analysis.get("suggested_bpm", 120)
                music.instruments = analysis.get("suggested_instruments", [])
                
                log = GenerationLog(
                    music_id=music_id,
                    asr_time=asr_time,
                    analysis_time=analysis_time,
                    generation_time=generation_time,
                    total_time=total_time,
                    asr_model="whisper-1",
                    llm_model="gpt-3.5-turbo",
                    music_model="simulated",
                    raw_prompt=music_prompt,
                    raw_response=json.dumps(analysis, ensure_ascii=False)
                )
                db.add(log)
                db.commit()
                
        except Exception as e:
            print(f"语音音乐生成失败: {e}")
            music = db.query(Music).filter(Music.id == music_id).first()
            if music:
                music.status = MusicStatus.failed
                log = GenerationLog(
                    music_id=music_id,
                    error_message=str(e),
                    total_time=int((time.time() - start_time) * 1000)
                )
                db.add(log)
                db.commit()
    
    async def generate_music_from_image(
        self,
        db: Session,
        music_id: int,
        image_path: str,
        duration: int = 30
    ):
        """
        从图片生成音乐的完整流程（后台任务）
        """
        start_time = time.time()
        
        try:
            # 1. 图片情感分析
            analysis_start = time.time()
            analysis = await self.analyze_image_emotion(image_path)
            analysis_time = int((time.time() - analysis_start) * 1000)
            
            # 2. 生成音乐
            gen_start = time.time()
            music_prompt = analysis.get("music_prompt", "peaceful ambient music")
            music_url = await self.generate_music(music_prompt, duration)
            generation_time = int((time.time() - gen_start) * 1000)
            
            # 3. 更新数据库
            total_time = int((time.time() - start_time) * 1000)
            
            music = db.query(Music).filter(Music.id == music_id).first()
            if music:
                if music_url:
                    music.status = MusicStatus.completed
                    music.music_url = music_url
                else:
                    music.status = MusicStatus.failed
                
                music.emotion_tags = analysis.get("emotions", [])
                music.ai_analysis = analysis.get("image_description", "") + " - " + analysis.get("mood", "")
                music.genre = analysis.get("suggested_genre", "")
                music.bpm = analysis.get("suggested_bpm", 120)
                music.instruments = analysis.get("suggested_instruments", [])
                
                log = GenerationLog(
                    music_id=music_id,
                    analysis_time=analysis_time,
                    generation_time=generation_time,
                    total_time=total_time,
                    llm_model="gpt-4o-mini",
                    music_model="simulated",
                    raw_prompt=music_prompt,
                    raw_response=json.dumps(analysis, ensure_ascii=False)
                )
                db.add(log)
                db.commit()
                
        except Exception as e:
            print(f"图片音乐生成失败: {e}")
            music = db.query(Music).filter(Music.id == music_id).first()
            if music:
                music.status = MusicStatus.failed
                log = GenerationLog(
                    music_id=music_id,
                    error_message=str(e),
                    total_time=int((time.time() - start_time) * 1000)
                )
                db.add(log)
                db.commit()
```

---

## 7. API 路由

### 文件: `backend/app/routers/__init__.py`

```python
"""
API 路由包
"""
from .auth import router as auth_router
from .music import router as music_router
from .generate import router as generate_router

__all__ = ["auth_router", "music_router", "generate_router"]
```

### 文件: `backend/app/routers/auth.py` 【已修复】

```python
"""
用户认证路由
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.user import UserCreate, UserLogin, UserResponse, Token
from app.services.auth_service import create_user, authenticate_user, get_current_user  # ← 添加导入
from app.utils.security import create_access_token

router = APIRouter(prefix="/api/auth", tags=["认证"])

@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """
    用户注册
    """
    user = create_user(db, user_data)
    access_token = create_access_token(data={"sub": user.email})
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user
    }

@router.post("/login", response_model=Token)
async def login(credentials: UserLogin, db: Session = Depends(get_db)):
    """
    用户登录
    """
    user = authenticate_user(db, credentials.email, credentials.password)
    access_token = create_access_token(data={"sub": user.email})
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user
    }

@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user = Depends(get_current_user),  # ← 现在可以正常使用
):
    """
    获取当前用户信息
    """
    return current_user
```

### 文件: `backend/app/routers/music.py` 【已修复】

```python
"""
音乐管理路由
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.music import MusicResponse, MusicList, CollectionCreate, CollectionResponse
from app.services.auth_service import get_current_user
from app.services.music_service import (
    get_user_musics,
    get_music_by_id,
    add_to_collection,
    get_user_collections
)
from app.models.user import User
from app.models.music import Music  # ← 添加导入

router = APIRouter(prefix="/api/music", tags=["音乐"])

@router.get("/", response_model=MusicList)
async def list_musics(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    status: str = Query(None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    获取用户音乐列表
    """
    musics = get_user_musics(db, current_user.id, skip, limit, status)
    total = db.query(Music).filter(Music.user_id == current_user.id).count()
    
    return {
        "total": total,
        "items": musics
    }

@router.get("/{music_id}", response_model=MusicResponse)
async def get_music(
    music_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    获取音乐详情
    """
    music = get_music_by_id(db, music_id, current_user.id)
    return music

@router.delete("/{music_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_music(
    music_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    删除音乐
    """
    music = get_music_by_id(db, music_id, current_user.id)
    db.delete(music)
    db.commit()
    return None

@router.post("/collections", response_model=CollectionResponse, status_code=status.HTTP_201_CREATED)
async def create_collection(
    collection_data: CollectionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    添加到收藏
    """
    collection = add_to_collection(
        db,
        current_user.id,
        collection_data.music_id,
        collection_data.folder_name
    )
    return collection

@router.get("/collections/", response_model=List[CollectionResponse])
async def list_collections(
    folder_name: str = Query(None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    获取收藏列表
    """
    collections = get_user_collections(db, current_user.id, folder_name)
    return collections
```

### 文件: `backend/app/routers/generate.py`

```python
"""
AI 音乐生成路由
"""
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.music import MusicCreate, MusicResponse
from app.services.auth_service import get_current_user
from app.services.music_service import create_music
from app.services.ai_service import AIService
from app.models.user import User
from app.models.music import InputType
import uuid
from pathlib import Path
from app.config import settings

router = APIRouter(prefix="/api/generate", tags=["AI生成"])

@router.post("/text", response_model=MusicResponse, status_code=status.HTTP_202_ACCEPTED)
async def generate_from_text(
    title: str = Form(...),
    text: str = Form(...),
    duration: int = Form(30),
    background_tasks: BackgroundTasks = BackgroundTasks(),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    从文本生成音乐
    """
    music_data = MusicCreate(
        title=title,
        input_type=InputType.text,
        input_content=text,
        duration=duration
    )
    
    # 创建音乐记录
    music = create_music(db, current_user, music_data)
    
    # 后台生成音乐
    ai_service = AIService()
    background_tasks.add_task(
        ai_service.generate_music_from_text,
        db, music.id, text, duration
    )
    
    return music

@router.post("/voice", response_model=MusicResponse, status_code=status.HTTP_202_ACCEPTED)
async def generate_from_voice(
    title: str = Form(...),
    audio: UploadFile = File(...),
    duration: int = Form(30),
    background_tasks: BackgroundTasks = BackgroundTasks(),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    从语音生成音乐
    """
    # 保存上传的音频文件
    file_ext = audio.filename.split(".")[-1] if audio.filename else "wav"
    filename = f"{uuid.uuid4()}.{file_ext}"
    file_path = settings.TEMP_DIR / filename
    file_path.parent.mkdir(exist_ok=True)
    
    with open(file_path, "wb") as f:
        content = await audio.read()
        f.write(content)
    
    # 创建音乐记录
    music_data = MusicCreate(
        title=title,
        input_type=InputType.voice,
        input_content=str(file_path),
        duration=duration
    )
    music = create_music(db, current_user, music_data)
    
    # 后台生成音乐
    ai_service = AIService()
    background_tasks.add_task(
        ai_service.generate_music_from_voice,
        db, music.id, str(file_path), duration
    )
    
    return music

@router.post("/image", response_model=MusicResponse, status_code=status.HTTP_202_ACCEPTED)
async def generate_from_image(
    title: str = Form(...),
    image: UploadFile = File(...),
    duration: int = Form(30),
    background_tasks: BackgroundTasks = BackgroundTasks(),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    从图片生成音乐
    """
    # 保存上传的图片
    file_ext = image.filename.split(".")[-1] if image.filename else "jpg"
    filename = f"{uuid.uuid4()}.{file_ext}"
    file_path = settings.IMAGE_DIR / filename
    
    with open(file_path, "wb") as f:
        content = await image.read()
        f.write(content)
    
    # 创建音乐记录
    music_data = MusicCreate(
        title=title,
        input_type=InputType.image,
        input_content=str(file_path),
        duration=duration
    )
    music = create_music(db, current_user, music_data)
    
    # 后台生成音乐
    ai_service = AIService()
    background_tasks.add_task(
        ai_service.generate_music_from_image,
        db, music.id, str(file_path), duration
    )
    
    return music

@router.get("/status/{music_id}", response_model=MusicResponse)
async def get_generation_status(
    music_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    查询音乐生成状态
    """
    from app.services.music_service import get_music_by_id
    music = get_music_by_id(db, music_id, current_user.id)
    return music
```

---

## 8. 主应用入口

### 文件: `backend/app/__init__.py`

```python
"""
SoundMood 后端应用包
"""
```

### 文件: `backend/app/main.py`

```python
"""
FastAPI 主应用
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.config import settings
from app.database import init_db
from app.routers import auth_router, music_router, generate_router

# 创建 FastAPI 应用
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="SoundMood - AI 音乐生成平台",
    docs_url="/api/docs",
    redoc_url="/api/redoc"
)

# CORS 中间件
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 挂载静态文件
app.mount("/uploads", StaticFiles(directory=str(settings.UPLOAD_DIR)), name="uploads")

# 注册路由
app.include_router(auth_router)
app.include_router(music_router)
app.include_router(generate_router)

@app.on_event("startup")
async def startup_event():
    """
    应用启动时初始化数据库
    """
    print("🚀 SoundMood 后端启动中...")
    init_db()
    print(f"✅ 服务运行在 http://{settings.HOST}:{settings.PORT}")
    print(f"📖 API 文档: http://{settings.HOST}:{settings.PORT}/api/docs")

@app.get("/")
async def root():
    """
    健康检查端点
    """
    return {
        "message": "SoundMood API 运行中",
        "version": settings.APP_VERSION,
        "docs": "/api/docs"
    }

@app.get("/health")
async def health_check():
    """
    健康检查
    """
    return {"status": "healthy"}
```

### 文件: `backend/run.py`

```python
"""
启动脚本
"""
import uvicorn
from app.config import settings

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
        log_level="info"
    )
```

---

## 9. 依赖文件

### 文件: `backend/requirements.txt`

```
# Web 框架
fastapi==0.109.0
uvicorn[standard]==0.27.0

# 数据库
sqlalchemy==2.0.25
alembic==1.13.1

# 认证
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4

# 数据验证
pydantic==2.5.3
pydantic-settings==2.1.0
email-validator==2.1.0

# HTTP 客户端
httpx==0.26.0
aiofiles==23.2.1

# 文件处理
python-multipart==0.0.6

# 其他
python-dotenv==1.0.0
```

---

## 10. 快速启动指南

### 10.1 创建项目结构

```bash
# 创建目录
mkdir -p backend/app/{models,schemas,services,routers,utils}
mkdir -p backend/uploads/{music,images,temp}

# 创建所有 __init__.py 文件
touch backend/app/__init__.py
touch backend/app/models/__init__.py
touch backend/app/schemas/__init__.py
touch backend/app/services/__init__.py
touch backend/app/routers/__init__.py
touch backend/app/utils/__init__.py
```

### 10.2 安装依赖

```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate

# Mac/Linux
source venv/bin/activate

pip install -r requirements.txt
```

### 10.3 配置环境变量

创建 `backend/.env` 文件：

```env
APP_NAME=SoundMood
DEBUG=True
DATABASE_URL=sqlite:///./soundmood.db
SECRET_KEY=your-super-secret-key-change-this-in-production
OPENAI_API_KEY=sk-your-openai-key
```

### 10.4 启动服务

```bash
python run.py
```

### 10.5 验证

- 访问 http://localhost:8000/api/docs 查看 API 文档
- 访问 http://localhost:8000/health 检查服务状态

---

## ✅ 修复清单

| 问题 | 状态 | 说明 |
|------|------|------|
| 缺少 `config.py` | ✅ 已修复 | 新增完整配置文件 |
| 缺少 `ai_service.py` | ✅ 已修复 | 新增完整 AI 服务 |
| `auth.py` 缺少导入 | ✅ 已修复 | 添加 `get_current_user` 导入 |
| `music.py` 缺少导入 | ✅ 已修复 | 添加 `Music` 模型导入 |
| `BackgroundTasks` 默认值 | ✅ 已修复 | 添加默认值避免 None |

---

**文档版本**: 2.0（完整修复版）  
**更新日期**: 2025年1月  
**作者**: Claude
