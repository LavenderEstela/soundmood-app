# SoundMood 后端补充文档

## 前后端功能对齐 - 缺失接口与数据库补充

---

## 📋 问题汇总

经对比分析 Flutter 前端（Part 1-6）与 FastAPI 后端（Part 1-2），发现以下功能缺失：

| 分类 | 缺失项 | 优先级 |
|------|--------|--------|
| **收藏功能** | 取消收藏接口、收藏标签 | 🔴 高 |
| **日记功能** | 按日期分组、统计接口 | 🔴 高 |
| **情绪筛选** | emotion 参数、primary_emotion 字段 | 🟡 中 |
| **用户设置** | 主题偏好、设置接口 | 🟡 中 |
| **状态查询** | 生成状态轮询接口 | 🟡 中 |
| **播放计数** | 播放次数增加接口 | 🟢 低 |

---

## 1. 数据库补充

### 1.1 修改 `musics` 表

```sql
-- 添加主要情绪字段（前端 Music 模型需要）
ALTER TABLE musics 
ADD COLUMN primary_emotion VARCHAR(50) DEFAULT NULL 
COMMENT '主要情绪: happy, calm, sad, energetic, nostalgic'
AFTER emotion_tags;

-- 添加封面图片字段（用于唱片封面展示）
ALTER TABLE musics 
ADD COLUMN cover_url VARCHAR(500) DEFAULT NULL 
COMMENT '封面图片URL'
AFTER music_url;
```

### 1.2 修改 `user_settings` 表

```sql
-- 添加主题偏好字段
ALTER TABLE user_settings 
ADD COLUMN theme_preference VARCHAR(20) DEFAULT 'cloud' 
COMMENT '主题偏好: cloud, space'
AFTER preferred_language;
```

### 1.3 修改 `collections` 表

```sql
-- 添加标签字段（用于收藏分类筛选）
ALTER TABLE collections 
ADD COLUMN tags JSON DEFAULT NULL 
COMMENT '收藏标签: ["治愈", "工作", "助眠", "放松"]'
AFTER note;
```

### 1.4 完整建表补充 SQL

```sql
-- 如果需要重新创建表，使用以下完整 SQL

-- 修改后的 musics 表
CREATE TABLE IF NOT EXISTS musics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- 输入类型: voice, text, image
    input_type ENUM('voice', 'text', 'image') NOT NULL,
    input_content TEXT,
    emotion_tags JSON,
    primary_emotion VARCHAR(50) DEFAULT NULL COMMENT '主要情绪',
    ai_analysis TEXT,
    
    -- 音乐文件信息
    music_url VARCHAR(500) NOT NULL,
    cover_url VARCHAR(500) DEFAULT NULL COMMENT '封面图片',
    music_format VARCHAR(10) DEFAULT 'mp3',
    duration INT DEFAULT 0,
    file_size INT DEFAULT 0,
    
    -- 音乐参数
    bpm INT DEFAULT 120,
    genre VARCHAR(100),
    instruments JSON,
    
    -- 状态
    status ENUM('generating', 'completed', 'failed') DEFAULT 'generating',
    is_public BOOLEAN DEFAULT FALSE,
    play_count INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_primary_emotion (primary_emotion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 修改后的 collections 表
CREATE TABLE IF NOT EXISTS collections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    music_id INT NOT NULL,
    folder_name VARCHAR(100) DEFAULT 'default',
    note TEXT,
    tags JSON DEFAULT NULL COMMENT '收藏标签',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (music_id) REFERENCES musics(id) ON DELETE CASCADE,
    UNIQUE KEY unique_collection (user_id, music_id),
    INDEX idx_user_folder (user_id, folder_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 修改后的 user_settings 表
CREATE TABLE IF NOT EXISTS user_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    
    preferred_language VARCHAR(10) DEFAULT 'zh',
    theme_preference VARCHAR(20) DEFAULT 'cloud' COMMENT '主题偏好',
    default_duration INT DEFAULT 30,
    default_genre VARCHAR(100) DEFAULT 'pop',
    
    notify_on_complete BOOLEAN DEFAULT TRUE,
    public_profile BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2. ORM 模型补充

### 2.1 修改 `backend/app/models/music.py`

```python
"""
音乐相关数据模型 - 补充版
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

# 情绪类型枚举
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
    primary_emotion = Column(String(50), index=True)  # 🆕 新增：主要情绪
    ai_analysis = Column(Text)
    
    # 音乐文件信息
    music_url = Column(String(500), nullable=False)
    cover_url = Column(String(500))  # 🆕 新增：封面图片
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
    tags = Column(JSON)  # 🆕 新增：收藏标签
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    user = relationship("User", back_populates="collections")
    music = relationship("Music", back_populates="collections")
```

### 2.2 修改 `backend/app/models/user.py`

```python
"""
用户相关数据模型 - 补充版
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
    theme_preference = Column(String(20), default="cloud")  # 🆕 新增：主题偏好
    default_duration = Column(Integer, default=30)
    default_genre = Column(String(100), default="pop")
    
    notify_on_complete = Column(Boolean, default=True)
    public_profile = Column(Boolean, default=False)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 关系
    user = relationship("User", back_populates="settings")
```

---

## 3. API Schema 补充

### 3.1 新增 `backend/app/schemas/music.py` 内容

```python
"""
音乐相关 API 模式 - 补充版
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, date
from app.models.music import InputType, MusicStatus

# ... 保留原有的 schemas ...

# 🆕 新增：带收藏状态的音乐响应
class MusicWithFavorite(BaseModel):
    id: int
    user_id: int
    title: str
    description: Optional[str]
    input_type: InputType
    input_content: Optional[str]
    emotion_tags: Optional[List[str]]
    primary_emotion: Optional[str]  # 🆕 新增
    ai_analysis: Optional[str]
    music_url: str
    cover_url: Optional[str]  # 🆕 新增
    music_format: str
    duration: int
    file_size: int
    bpm: int
    genre: Optional[str]
    instruments: Optional[List[str]]
    status: MusicStatus
    is_public: bool
    play_count: int
    is_favorite: bool  # 🆕 新增：是否已收藏
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# 🆕 新增：日记条目（按日期分组）
class JournalEntry(BaseModel):
    date: date
    items: List[MusicWithFavorite]
    count: int


# 🆕 新增：日记列表响应
class JournalResponse(BaseModel):
    entries: List[JournalEntry]
    total: int


# 🆕 新增：用户统计信息
class UserStatsResponse(BaseModel):
    total_count: int  # 总作品数
    monthly_count: int  # 本月作品数
    total_duration: int  # 总时长（秒）
    favorite_count: int  # 收藏数
    emotion_distribution: dict  # 情绪分布


# 🆕 新增：音乐状态响应
class MusicStatusResponse(BaseModel):
    id: int
    status: MusicStatus
    progress: Optional[int] = None  # 生成进度百分比
    error_message: Optional[str] = None
    music_url: Optional[str] = None


# 🆕 新增：收藏更新请求
class CollectionUpdate(BaseModel):
    folder_name: Optional[str] = None
    note: Optional[str] = None
    tags: Optional[List[str]] = None
```

### 3.2 新增 `backend/app/schemas/user.py` 内容

```python
"""
用户相关 API 模式 - 补充版
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

# ... 保留原有的 schemas ...

# 🆕 新增：用户设置响应
class UserSettingsResponse(BaseModel):
    id: int
    user_id: int
    preferred_language: str
    theme_preference: str  # 🆕 新增
    default_duration: int
    default_genre: str
    notify_on_complete: bool
    public_profile: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# 🆕 新增：用户设置更新请求
class UserSettingsUpdate(BaseModel):
    preferred_language: Optional[str] = None
    theme_preference: Optional[str] = None
    default_duration: Optional[int] = Field(None, ge=15, le=120)
    default_genre: Optional[str] = None
    notify_on_complete: Optional[bool] = None
    public_profile: Optional[bool] = None


# 🆕 新增：用户资料更新请求
class UserProfileUpdate(BaseModel):
    username: Optional[str] = Field(None, min_length=2, max_length=100)
    avatar_url: Optional[str] = None
```

---

## 4. 业务服务补充

### 4.1 修改 `backend/app/services/music_service.py`

```python
"""
音乐管理服务 - 补充版
"""
from sqlalchemy.orm import Session
from sqlalchemy import desc, func, extract
from typing import List, Optional, Dict
from datetime import datetime, date, timedelta
from collections import defaultdict
from app.models.music import Music, Collection, Playlist, PlaylistItem
from app.models.user import User
from app.schemas.music import MusicCreate
from fastapi import HTTPException, status

# ... 保留原有的函数 ...

# 🆕 新增：获取带收藏状态的音乐列表
def get_user_musics_with_favorite(
    db: Session,
    user_id: int,
    skip: int = 0,
    limit: int = 20,
    status_filter: str = None,
    emotion: str = None  # 🆕 情绪筛选
) -> List[Dict]:
    """
    获取用户的音乐列表（包含收藏状态）
    """
    query = db.query(Music).filter(Music.user_id == user_id)
    
    if status_filter:
        query = query.filter(Music.status == status_filter)
    
    if emotion:
        query = query.filter(Music.primary_emotion == emotion)
    
    musics = query.order_by(desc(Music.created_at)).offset(skip).limit(limit).all()
    
    # 获取用户的收藏列表
    user_collection_ids = set(
        c.music_id for c in 
        db.query(Collection.music_id).filter(Collection.user_id == user_id).all()
    )
    
    # 添加收藏状态
    result = []
    for music in musics:
        music_dict = music.__dict__.copy()
        music_dict['is_favorite'] = music.id in user_collection_ids
        result.append(music_dict)
    
    return result


# 🆕 新增：获取日记（按日期分组）
def get_user_journal(
    db: Session,
    user_id: int,
    start_date: date = None,
    end_date: date = None,
    emotion: str = None
) -> Dict:
    """
    获取用户日记（按日期分组）
    """
    query = db.query(Music).filter(
        Music.user_id == user_id,
        Music.status == "completed"
    )
    
    if start_date:
        query = query.filter(Music.created_at >= start_date)
    if end_date:
        query = query.filter(Music.created_at <= end_date)
    if emotion:
        query = query.filter(Music.primary_emotion == emotion)
    
    musics = query.order_by(desc(Music.created_at)).all()
    
    # 获取收藏状态
    user_collection_ids = set(
        c.music_id for c in 
        db.query(Collection.music_id).filter(Collection.user_id == user_id).all()
    )
    
    # 按日期分组
    grouped = defaultdict(list)
    for music in musics:
        date_key = music.created_at.date()
        music_dict = {
            **music.__dict__,
            'is_favorite': music.id in user_collection_ids
        }
        grouped[date_key].append(music_dict)
    
    # 格式化输出
    entries = [
        {
            'date': date_key,
            'items': items,
            'count': len(items)
        }
        for date_key, items in sorted(grouped.items(), reverse=True)
    ]
    
    return {
        'entries': entries,
        'total': len(musics)
    }


# 🆕 新增：获取用户统计
def get_user_stats(db: Session, user_id: int) -> Dict:
    """
    获取用户统计信息
    """
    # 总作品数
    total_count = db.query(func.count(Music.id)).filter(
        Music.user_id == user_id,
        Music.status == "completed"
    ).scalar()
    
    # 本月作品数
    now = datetime.now()
    first_day_of_month = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    monthly_count = db.query(func.count(Music.id)).filter(
        Music.user_id == user_id,
        Music.status == "completed",
        Music.created_at >= first_day_of_month
    ).scalar()
    
    # 总时长
    total_duration = db.query(func.sum(Music.duration)).filter(
        Music.user_id == user_id,
        Music.status == "completed"
    ).scalar() or 0
    
    # 收藏数
    favorite_count = db.query(func.count(Collection.id)).filter(
        Collection.user_id == user_id
    ).scalar()
    
    # 情绪分布
    emotion_counts = db.query(
        Music.primary_emotion,
        func.count(Music.id)
    ).filter(
        Music.user_id == user_id,
        Music.status == "completed",
        Music.primary_emotion.isnot(None)
    ).group_by(Music.primary_emotion).all()
    
    emotion_distribution = {emotion: count for emotion, count in emotion_counts}
    
    return {
        'total_count': total_count,
        'monthly_count': monthly_count,
        'total_duration': total_duration,
        'favorite_count': favorite_count,
        'emotion_distribution': emotion_distribution
    }


# 🆕 新增：删除收藏
def remove_from_collection(db: Session, user_id: int, music_id: int) -> bool:
    """
    取消收藏
    """
    collection = db.query(Collection).filter(
        Collection.user_id == user_id,
        Collection.music_id == music_id
    ).first()
    
    if not collection:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="未找到该收藏"
        )
    
    db.delete(collection)
    db.commit()
    return True


# 🆕 新增：切换收藏状态
def toggle_favorite(db: Session, user_id: int, music_id: int) -> bool:
    """
    切换收藏状态，返回新状态（True=已收藏）
    """
    collection = db.query(Collection).filter(
        Collection.user_id == user_id,
        Collection.music_id == music_id
    ).first()
    
    if collection:
        db.delete(collection)
        db.commit()
        return False
    else:
        new_collection = Collection(
            user_id=user_id,
            music_id=music_id
        )
        db.add(new_collection)
        db.commit()
        return True


# 🆕 新增：增加播放次数
def increment_play_count(db: Session, music_id: int, user_id: int) -> Music:
    """
    增加播放次数
    """
    music = db.query(Music).filter(
        Music.id == music_id,
        Music.user_id == user_id
    ).first()
    
    if not music:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="音乐不存在"
        )
    
    music.play_count += 1
    db.commit()
    db.refresh(music)
    return music


# 🆕 新增：获取收藏列表（带标签筛选）
def get_user_collections_with_tags(
    db: Session,
    user_id: int,
    folder_name: str = None,
    tag: str = None
) -> List[Collection]:
    """
    获取用户收藏列表（支持标签筛选）
    """
    query = db.query(Collection).filter(Collection.user_id == user_id)
    
    if folder_name:
        query = query.filter(Collection.folder_name == folder_name)
    
    if tag:
        # JSON 数组包含查询
        query = query.filter(Collection.tags.contains([tag]))
    
    collections = query.order_by(desc(Collection.created_at)).all()
    return collections
```

### 4.2 新增 `backend/app/services/user_service.py`

```python
"""
用户服务 - 新增
"""
from sqlalchemy.orm import Session
from app.models.user import User, UserSettings
from app.schemas.user import UserSettingsUpdate, UserProfileUpdate
from fastapi import HTTPException, status

def get_user_settings(db: Session, user_id: int) -> UserSettings:
    """
    获取用户设置
    """
    settings = db.query(UserSettings).filter(UserSettings.user_id == user_id).first()
    
    if not settings:
        # 如果不存在，创建默认设置
        settings = UserSettings(user_id=user_id)
        db.add(settings)
        db.commit()
        db.refresh(settings)
    
    return settings


def update_user_settings(
    db: Session, 
    user_id: int, 
    settings_data: UserSettingsUpdate
) -> UserSettings:
    """
    更新用户设置
    """
    settings = get_user_settings(db, user_id)
    
    update_data = settings_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(settings, field, value)
    
    db.commit()
    db.refresh(settings)
    return settings


def update_user_profile(
    db: Session,
    user_id: int,
    profile_data: UserProfileUpdate
) -> User:
    """
    更新用户资料
    """
    user = db.query(User).filter(User.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="用户不存在"
        )
    
    update_data = profile_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(user, field, value)
    
    db.commit()
    db.refresh(user)
    return user
```

---

## 5. API 路由补充

### 5.1 修改 `backend/app/routers/music.py`

```python
"""
音乐管理路由 - 补充版
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date
from app.database import get_db
from app.schemas.music import (
    MusicResponse, MusicList, MusicWithFavorite,
    CollectionCreate, CollectionResponse, CollectionUpdate,
    JournalResponse, UserStatsResponse, MusicStatusResponse
)
from app.services.auth_service import get_current_user
from app.services.music_service import (
    get_user_musics_with_favorite,
    get_music_by_id,
    add_to_collection,
    remove_from_collection,
    toggle_favorite,
    get_user_collections_with_tags,
    get_user_journal,
    get_user_stats,
    increment_play_count
)
from app.models.user import User
from app.models.music import Music

router = APIRouter(prefix="/api/music", tags=["音乐"])


# 🆕 修改：音乐列表增加情绪筛选和收藏状态
@router.get("/", response_model=List[MusicWithFavorite])
async def list_musics(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    status: str = Query(None),
    emotion: str = Query(None, description="情绪筛选: happy, calm, sad, energetic, nostalgic"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    获取用户音乐列表（包含收藏状态）
    """
    musics = get_user_musics_with_favorite(
        db, current_user.id, skip, limit, status, emotion
    )
    return musics


# 🆕 新增：获取日记（按日期分组）
@router.get("/journal", response_model=JournalResponse)
async def get_journal(
    start_date: Optional[date] = Query(None),
    end_date: Optional[date] = Query(None),
    emotion: Optional[str] = Query(None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    获取用户日记（按日期分组）
    """
    journal = get_user_journal(db, current_user.id, start_date, end_date, emotion)
    return journal


# 🆕 新增：获取用户统计
@router.get("/stats", response_model=UserStatsResponse)
async def get_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    获取用户统计信息
    """
    stats = get_user_stats(db, current_user.id)
    return stats


# 🆕 新增：获取音乐生成状态
@router.get("/{music_id}/status", response_model=MusicStatusResponse)
async def get_music_status(
    music_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    获取音乐生成状态（用于前端轮询）
    """
    music = get_music_by_id(db, music_id, current_user.id)
    return {
        "id": music.id,
        "status": music.status,
        "progress": None,  # 可以从 generation_logs 中获取
        "error_message": None,
        "music_url": music.music_url if music.status == "completed" else None
    }


# 🆕 新增：增加播放次数
@router.post("/{music_id}/play")
async def play_music(
    music_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    增加播放次数
    """
    music = increment_play_count(db, music_id, current_user.id)
    return {"play_count": music.play_count}


# 🆕 新增：切换收藏状态
@router.post("/{music_id}/favorite")
async def toggle_music_favorite(
    music_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    切换收藏状态
    """
    is_favorite = toggle_favorite(db, current_user.id, music_id)
    return {"is_favorite": is_favorite}


# 🆕 修改：收藏列表支持标签筛选
@router.get("/collections/", response_model=List[CollectionResponse])
async def list_collections(
    folder_name: str = Query(None),
    tag: str = Query(None, description="标签筛选: 治愈, 工作, 助眠, 放松"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    获取收藏列表（支持标签筛选）
    """
    collections = get_user_collections_with_tags(
        db, current_user.id, folder_name, tag
    )
    return collections


# 🆕 新增：取消收藏
@router.delete("/collections/{music_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_collection(
    music_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    取消收藏
    """
    remove_from_collection(db, current_user.id, music_id)
    return None


# ... 保留原有的其他路由 ...
```

### 5.2 新增 `backend/app/routers/user.py`

```python
"""
用户管理路由 - 新增
"""
from fastapi import APIRouter, Depends, UploadFile, File
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.user import (
    UserResponse, UserSettingsResponse, UserSettingsUpdate, UserProfileUpdate
)
from app.services.auth_service import get_current_user
from app.services.user_service import (
    get_user_settings,
    update_user_settings,
    update_user_profile
)
from app.models.user import User
from app.config import settings
import uuid

router = APIRouter(prefix="/api/user", tags=["用户"])


@router.get("/settings", response_model=UserSettingsResponse)
async def get_settings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    获取用户设置
    """
    user_settings = get_user_settings(db, current_user.id)
    return user_settings


@router.put("/settings", response_model=UserSettingsResponse)
async def update_settings(
    settings_data: UserSettingsUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    更新用户设置
    """
    user_settings = update_user_settings(db, current_user.id, settings_data)
    return user_settings


@router.put("/profile", response_model=UserResponse)
async def update_profile(
    profile_data: UserProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    更新用户资料
    """
    user = update_user_profile(db, current_user.id, profile_data)
    return user


@router.post("/avatar", response_model=UserResponse)
async def upload_avatar(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    上传头像
    """
    # 验证文件类型
    if file.content_type not in settings.ALLOWED_IMAGE_TYPES:
        raise HTTPException(
            status_code=400,
            detail="不支持的图片格式"
        )
    
    # 保存文件
    file_ext = file.filename.split(".")[-1]
    filename = f"avatar_{current_user.id}_{uuid.uuid4()}.{file_ext}"
    file_path = settings.IMAGE_DIR / filename
    
    with open(file_path, "wb") as f:
        content = await file.read()
        f.write(content)
    
    # 更新用户头像
    avatar_url = f"/uploads/images/{filename}"
    current_user.avatar_url = avatar_url
    db.commit()
    db.refresh(current_user)
    
    return current_user
```

### 5.3 更新 `backend/app/routers/__init__.py`

```python
"""
API 路由包 - 补充版
"""
from .auth import router as auth_router
from .music import router as music_router
from .generate import router as generate_router
from .user import router as user_router  # 🆕 新增

__all__ = [
    "auth_router",
    "music_router", 
    "generate_router",
    "user_router"  # 🆕 新增
]
```

### 5.4 更新 `backend/app/main.py`

```python
"""
FastAPI 主应用 - 补充版
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.config import settings
from app.database import init_db
from app.routers import auth_router, music_router, generate_router, user_router  # 🆕 新增

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
app.include_router(user_router)  # 🆕 新增

# ... 其他代码保持不变 ...
```

---

## 6. 前端对接调整建议

### 6.1 更新 `lib/services/api_service.dart`

需要添加以下方法：

```dart
// 获取日记（按日期分组）
Future<Map<String, dynamic>> getJournal({
  DateTime? startDate,
  DateTime? endDate,
  String? emotion,
}) async {
  final params = <String, String>{};
  if (startDate != null) params['start_date'] = startDate.toIso8601String().split('T')[0];
  if (endDate != null) params['end_date'] = endDate.toIso8601String().split('T')[0];
  if (emotion != null) params['emotion'] = emotion;
  
  final response = await _dio.get('/music/journal', queryParameters: params);
  return response.data;
}

// 获取用户统计
Future<Map<String, dynamic>> getUserStats() async {
  final response = await _dio.get('/music/stats');
  return response.data;
}

// 切换收藏状态
Future<bool> toggleFavorite(int musicId) async {
  final response = await _dio.post('/music/$musicId/favorite');
  return response.data['is_favorite'];
}

// 获取用户设置
Future<Map<String, dynamic>> getUserSettings() async {
  final response = await _dio.get('/user/settings');
  return response.data;
}

// 更新用户设置
Future<Map<String, dynamic>> updateUserSettings(Map<String, dynamic> settings) async {
  final response = await _dio.put('/user/settings', data: settings);
  return response.data;
}

// 增加播放次数
Future<void> incrementPlayCount(int musicId) async {
  await _dio.post('/music/$musicId/play');
}

// 获取音乐状态
Future<Map<String, dynamic>> getMusicStatus(int musicId) async {
  final response = await _dio.get('/music/$musicId/status');
  return response.data;
}
```

### 6.2 更新 `lib/models/music.dart`

确保前端模型与后端一致：

```dart
class Music {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final String inputType;
  final String? inputContent;
  final List<String>? emotionTags;
  final String? primaryEmotion;  // 确保有此字段
  final String? aiAnalysis;
  final String musicUrl;
  final String? coverUrl;  // 新增
  final String musicFormat;
  final int duration;
  final int fileSize;
  final int bpm;
  final String? genre;
  final List<String>? instruments;
  final String status;
  final bool isPublic;
  final int playCount;
  final bool isFavorite;  // 确保有此字段
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // ... 构造函数和其他方法
}
```

---

## 7. 完整 API 端点清单

### 认证模块 `/api/auth`
| 方法 | 端点 | 描述 | 状态 |
|------|------|------|------|
| POST | /register | 用户注册 | ✅ 已有 |
| POST | /login | 用户登录 | ✅ 已有 |
| GET | /me | 获取当前用户 | ✅ 已有 |

### 用户模块 `/api/user`
| 方法 | 端点 | 描述 | 状态 |
|------|------|------|------|
| GET | /settings | 获取用户设置 | 🆕 新增 |
| PUT | /settings | 更新用户设置 | 🆕 新增 |
| PUT | /profile | 更新用户资料 | 🆕 新增 |
| POST | /avatar | 上传头像 | 🆕 新增 |

### 音乐模块 `/api/music`
| 方法 | 端点 | 描述 | 状态 |
|------|------|------|------|
| GET | / | 音乐列表（+情绪筛选+收藏状态） | 🔄 修改 |
| GET | /{id} | 音乐详情 | ✅ 已有 |
| DELETE | /{id} | 删除音乐 | ✅ 已有 |
| GET | /{id}/status | 获取生成状态 | 🆕 新增 |
| POST | /{id}/play | 增加播放次数 | 🆕 新增 |
| POST | /{id}/favorite | 切换收藏状态 | 🆕 新增 |
| GET | /journal | 日记（按日期分组） | 🆕 新增 |
| GET | /stats | 用户统计 | 🆕 新增 |
| POST | /collections | 添加收藏 | ✅ 已有 |
| GET | /collections/ | 收藏列表（+标签筛选） | 🔄 修改 |
| DELETE | /collections/{music_id} | 取消收藏 | 🆕 新增 |

### 生成模块 `/api/generate`
| 方法 | 端点 | 描述 | 状态 |
|------|------|------|------|
| POST | /text | 文本生成 | ✅ 已有 |
| POST | /voice | 语音生成 | ✅ 已有 |
| POST | /image | 图片生成 | ✅ 已有 |

---

## 8. 实施步骤

1. **执行数据库迁移 SQL**
2. **更新 ORM 模型文件**
3. **添加新的 Schema 文件**
4. **更新/添加 Service 文件**
5. **更新/添加 Router 文件**
6. **更新 main.py 注册新路由**
7. **重启后端服务测试 API**
8. **更新前端 API 服务对接**

---

**文档版本**: 1.0  
**更新日期**: 2025年1月  
**作者**: AI Assistant
