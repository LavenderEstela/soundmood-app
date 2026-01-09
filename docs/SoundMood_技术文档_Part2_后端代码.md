# SoundMood 技术文档

## Part 2: 后端 API 完整代码

---

## 📋 文档导航

| 部分 | 内容 | 状态 |
|------|------|------|
| Part 1 | 项目架构、环境准备、数据库设计 | ✅ 已完成 |
| **Part 2** | 后端 API 完整代码 | 📖 当前文档 |
| Part 3 | Flutter 前端完整代码 | 下一部分 |
| Part 4 | AI 服务集成 + 部署指南 | 待生成 |

---

## 1. 数据库连接模块

### 文件: `backend/app/database.py`

```python
"""
数据库连接和会话管理
"""
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from .config import settings

# 创建数据库引擎
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,  # 自动处理连接断开
    pool_recycle=3600,   # 1小时回收连接
    echo=settings.DEBUG   # 调试模式打印SQL
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
    from app.models import user, music  # 导入所有模型
    Base.metadata.create_all(bind=engine)
    print("✅ 数据库表创建完成！")
```

---

## 2. 数据模型 (ORM Models)

### 文件: `backend/app/models/__init__.py`

```python
"""
数据模型包
"""
from .user import User, UserSettings
from .music import Music, Collection, Playlist, PlaylistItem, GenerationLog

__all__ = [
    "User",
    "UserSettings",
    "Music",
    "Collection",
    "Playlist",
    "PlaylistItem",
    "GenerationLog"
]
```

### 文件: `backend/app/models/user.py`

```python
"""
用户相关数据模型
"""
from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text
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
    user_id = Column(Integer, nullable=False, unique=True)
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
```

---

## 3. Pydantic 模式 (API Schemas)

### 文件: `backend/app/schemas/__init__.py`

```python
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
    description: Optional[str]
    input_type: InputType
    input_content: Optional[str]
    emotion_tags: Optional[List[str]]
    ai_analysis: Optional[str]
    music_url: str
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
    note: Optional[str]
    created_at: datetime
    music: MusicResponse
    
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
    description: Optional[str]
    cover_url: Optional[str]
    is_public: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
```

---

## 4. 工具函数

### 文件: `backend/app/utils/__init__.py`

```python
"""
工具函数包
"""
from .security import *

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

## 5. 业务逻辑服务

### 文件: `backend/app/services/__init__.py`

```python
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
from typing import List
from app.models.music import Music, Collection, Playlist, PlaylistItem
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
        music_url="",  # 生成后填充
        status="generating"
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
    status: str = None
) -> List[Music]:
    """
    获取用户的音乐列表
    """
    query = db.query(Music).filter(Music.user_id == user_id)
    
    if status:
        query = query.filter(Music.status == status)
    
    musics = query.order_by(desc(Music.created_at)).offset(skip).limit(limit).all()
    return musics

def get_music_by_id(db: Session, music_id: int, user_id: int = None) -> Music:
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

def get_user_collections(db: Session, user_id: int, folder_name: str = None) -> List[Collection]:
    """
    获取用户收藏列表
    """
    query = db.query(Collection).filter(Collection.user_id == user_id)
    
    if folder_name:
        query = query.filter(Collection.folder_name == folder_name)
    
    collections = query.order_by(desc(Collection.created_at)).all()
    return collections
```

---

## 6. API 路由

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

### 文件: `backend/app/routers/auth.py`

```python
"""
用户认证路由
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.user import UserCreate, UserLogin, UserResponse, Token
from app.services.auth_service import create_user, authenticate_user
from app.utils.security import create_access_token

router = APIRouter(prefix="/api/auth", tags=["认证"])

@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """
    用户注册
    """
    user = create_user(db, user_data)
    
    # 生成访问令牌
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
    
    # 生成访问令牌
    access_token = create_access_token(data={"sub": user.email})
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user
    }

@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user = Depends(get_current_user),
):
    """
    获取当前用户信息
    """
    return current_user
```

### 文件: `backend/app/routers/music.py`

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
    background_tasks: BackgroundTasks = None,
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
    background_tasks: BackgroundTasks = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    从语音生成音乐
    """
    # 保存上传的音频文件
    file_ext = audio.filename.split(".")[-1]
    filename = f"{uuid.uuid4()}.{file_ext}"
    file_path = settings.UPLOAD_DIR / "temp" / filename
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
    background_tasks: BackgroundTasks = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    从图片生成音乐
    """
    # 保存上传的图片
    file_ext = image.filename.split(".")[-1]
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
```

---

## 7. 主应用入口

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

# CORS 中间件（允许 Flutter 跨域访问）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境应限制具体域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 挂载静态文件（音乐和图片）
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

## 8. 启动后端服务

### 8.1 创建所有 `__init__.py` 文件

```bash
# 在 backend 目录下
cd backend

# 创建空的 __init__.py
touch app/__init__.py
touch app/models/__init__.py
touch app/schemas/__init__.py
touch app/routers/__init__.py
touch app/services/__init__.py
touch app/utils/__init__.py
```

### 8.2 启动服务

```bash
# 确保虚拟环境已激活
# Windows: venv\Scripts\activate
# Mac/Linux: source venv/bin/activate

# 启动后端
python run.py
```

### 8.3 验证服务

访问 http://localhost:8000/api/docs 查看自动生成的 API 文档

---

## 9. API 测试示例

### 9.1 注册用户

```bash
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "测试用户",
    "password": "password123"
  }'
```

### 9.2 登录

```bash
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

返回的 `access_token` 用于后续请求的认证。

### 9.3 获取音乐列表

```bash
curl -X GET "http://localhost:8000/api/music/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## 10. 下一步

后端 API 已完成！接下来请查看 **Part 3: Flutter 前端完整代码**，包含：

1. Flutter 项目初始化
2. UI 界面设计（漂亮的设计！）
3. API 集成
4. 状态管理
5. 音频播放功能

---

**文档版本**: 1.0  
**更新日期**: 2025年1月  
**作者**: AI Assistant
