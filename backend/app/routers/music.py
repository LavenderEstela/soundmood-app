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