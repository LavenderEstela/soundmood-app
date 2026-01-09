"""
音乐管理服务 - 完整版
"""
from sqlalchemy.orm import Session
from sqlalchemy import desc, func
from typing import List, Optional, Dict, Any
from datetime import datetime, date
from collections import defaultdict
from app.models.music import Music, Collection, InputType, MusicStatus
from app.schemas.music import MusicCreate
from fastapi import HTTPException, status
import uuid
import os


# ============= 基础 CRUD 操作 =============

def get_music_by_id(db: Session, music_id: int, user_id: int) -> Music:
    """获取音乐详情"""
    music = db.query(Music).filter(
        Music.id == music_id,
        Music.user_id == user_id
    ).first()
    
    if not music:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="音乐不存在"
        )
    return music


def get_user_musics(
    db: Session,
    user_id: int,
    skip: int = 0,
    limit: int = 20,
    status_filter: str = None,
    emotion: str = None
) -> List[Music]:
    """获取用户音乐列表"""
    query = db.query(Music).filter(Music.user_id == user_id)
    
    if status_filter:
        query = query.filter(Music.status == status_filter)
    
    if emotion:
        query = query.filter(Music.primary_emotion == emotion)
    
    return query.order_by(desc(Music.created_at)).offset(skip).limit(limit).all()


def get_user_musics_with_favorite(
    db: Session,
    user_id: int,
    skip: int = 0,
    limit: int = 20,
    status_filter: str = None,
    emotion: str = None
) -> List[Dict]:
    """获取用户音乐列表（包含收藏状态）"""
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
        music_dict = {
            "id": music.id,
            "user_id": music.user_id,
            "title": music.title,
            "description": music.description,
            "input_type": music.input_type,
            "input_content": music.input_content,
            "emotion_tags": music.emotion_tags,
            "primary_emotion": music.primary_emotion,
            "ai_analysis": music.ai_analysis,
            "music_url": music.music_url,
            "cover_url": music.cover_url,
            "music_format": music.music_format,
            "duration": music.duration,
            "file_size": music.file_size,
            "bpm": music.bpm,
            "genre": music.genre,
            "instruments": music.instruments,
            "status": music.status,
            "is_public": music.is_public,
            "play_count": music.play_count,
            "created_at": music.created_at,
            "updated_at": music.updated_at,
            "is_favorite": music.id in user_collection_ids
        }
        result.append(music_dict)
    
    return result


def delete_music(db: Session, music_id: int, user_id: int) -> bool:
    """删除音乐"""
    music = get_music_by_id(db, music_id, user_id)
    db.delete(music)
    db.commit()
    return True


# ============= 收藏相关 =============

def add_to_collection(
    db: Session,
    user_id: int,
    music_id: int,
    folder_name: str = "default",
    note: str = None,
    tags: List[str] = None
) -> Collection:
    """添加收藏"""
    # 检查是否已收藏
    existing = db.query(Collection).filter(
        Collection.user_id == user_id,
        Collection.music_id == music_id
    ).first()
    
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="已经收藏过了"
        )
    
    collection = Collection(
        user_id=user_id,
        music_id=music_id,
        folder_name=folder_name,
        note=note,
        tags=tags
    )
    db.add(collection)
    db.commit()
    db.refresh(collection)
    return collection


def remove_from_collection(db: Session, user_id: int, music_id: int) -> bool:
    """取消收藏"""
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


def toggle_favorite(db: Session, user_id: int, music_id: int) -> bool:
    """切换收藏状态，返回新状态（True=已收藏）"""
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


def get_user_collections(
    db: Session,
    user_id: int,
    folder_name: str = None
) -> List[Collection]:
    """获取用户收藏列表"""
    query = db.query(Collection).filter(Collection.user_id == user_id)
    
    if folder_name:
        query = query.filter(Collection.folder_name == folder_name)
    
    return query.order_by(desc(Collection.created_at)).all()


def get_user_collections_with_tags(
    db: Session,
    user_id: int,
    folder_name: str = None,
    tag: str = None
) -> List[Collection]:
    """获取用户收藏列表（支持标签筛选）"""
    query = db.query(Collection).filter(Collection.user_id == user_id)
    
    if folder_name:
        query = query.filter(Collection.folder_name == folder_name)
    
    collections = query.order_by(desc(Collection.created_at)).all()
    
    # 如果需要标签筛选
    if tag:
        collections = [c for c in collections if c.tags and tag in c.tags]
    
    return collections


# ============= 日记和统计 =============

def get_user_journal(
    db: Session,
    user_id: int,
    start_date: date = None,
    end_date: date = None,
    emotion: str = None
) -> Dict:
    """获取用户日记（按日期分组）"""
    query = db.query(Music).filter(
        Music.user_id == user_id,
        Music.status == "completed"
    )
    
    if start_date:
        query = query.filter(Music.created_at >= datetime.combine(start_date, datetime.min.time()))
    if end_date:
        query = query.filter(Music.created_at <= datetime.combine(end_date, datetime.max.time()))
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
            "id": music.id,
            "user_id": music.user_id,
            "title": music.title,
            "description": music.description,
            "input_type": music.input_type,
            "input_content": music.input_content,
            "emotion_tags": music.emotion_tags,
            "primary_emotion": music.primary_emotion,
            "ai_analysis": music.ai_analysis,
            "music_url": music.music_url,
            "cover_url": music.cover_url,
            "music_format": music.music_format,
            "duration": music.duration,
            "file_size": music.file_size,
            "bpm": music.bpm,
            "genre": music.genre,
            "instruments": music.instruments,
            "status": music.status,
            "is_public": music.is_public,
            "play_count": music.play_count,
            "created_at": music.created_at,
            "updated_at": music.updated_at,
            "is_favorite": music.id in user_collection_ids
        }
        grouped[date_key].append(music_dict)
    
    # 格式化输出
    entries = [
        {
            "date": date_key,
            "items": items,
            "count": len(items)
        }
        for date_key, items in sorted(grouped.items(), reverse=True)
    ]
    
    return {
        "entries": entries,
        "total": len(musics)
    }


def get_user_stats(db: Session, user_id: int) -> Dict:
    """获取用户统计信息"""
    # 总作品数
    total_count = db.query(func.count(Music.id)).filter(
        Music.user_id == user_id,
        Music.status == "completed"
    ).scalar() or 0
    
    # 本月作品数
    now = datetime.now()
    first_day_of_month = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    monthly_count = db.query(func.count(Music.id)).filter(
        Music.user_id == user_id,
        Music.status == "completed",
        Music.created_at >= first_day_of_month
    ).scalar() or 0
    
    # 总时长
    total_duration = db.query(func.sum(Music.duration)).filter(
        Music.user_id == user_id,
        Music.status == "completed"
    ).scalar() or 0
    
    # 收藏数
    favorite_count = db.query(func.count(Collection.id)).filter(
        Collection.user_id == user_id
    ).scalar() or 0
    
    # 情绪分布
    emotion_counts = db.query(
        Music.primary_emotion,
        func.count(Music.id)
    ).filter(
        Music.user_id == user_id,
        Music.status == "completed",
        Music.primary_emotion.isnot(None)
    ).group_by(Music.primary_emotion).all()
    
    emotion_distribution = {emotion: count for emotion, count in emotion_counts if emotion}
    
    return {
        "total_count": total_count,
        "monthly_count": monthly_count,
        "total_duration": total_duration,
        "favorite_count": favorite_count,
        "emotion_distribution": emotion_distribution
    }


def increment_play_count(db: Session, music_id: int, user_id: int) -> Music:
    """增加播放次数"""
    music = get_music_by_id(db, music_id, user_id)
    music.play_count += 1
    db.commit()
    db.refresh(music)
    return music


# ============= 音乐生成 =============

def create_music(
    db: Session,
    user_id: int,
    title: str,
    input_type: str,
    input_content: str = None,
    duration: int = 30
) -> Music:
    """创建音乐（生成中状态）"""
    music = Music(
        user_id=user_id,
        title=title,
        input_type=input_type,
        input_content=input_content,
        duration=duration,
        status=MusicStatus.generating,
        music_url=""  # 生成完成后更新
    )
    db.add(music)
    db.commit()
    db.refresh(music)
    return music


def update_music_status(
    db: Session,
    music_id: int,
    status: str,
    music_url: str = None,
    emotion_tags: List[str] = None,
    primary_emotion: str = None,
    ai_analysis: str = None
) -> Music:
    """更新音乐状态"""
    music = db.query(Music).filter(Music.id == music_id).first()
    if not music:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="音乐不存在"
        )
    
    music.status = status
    if music_url:
        music.music_url = music_url
    if emotion_tags:
        music.emotion_tags = emotion_tags
    if primary_emotion:
        music.primary_emotion = primary_emotion
    if ai_analysis:
        music.ai_analysis = ai_analysis
    
    db.commit()
    db.refresh(music)
    return music


# 别名，用于兼容不同的调用方式
get_music_list = get_user_musics
get_music_detail = get_music_by_id
