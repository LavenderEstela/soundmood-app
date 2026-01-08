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