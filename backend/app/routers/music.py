"""
音乐管理路由 - 完整版
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date
from app.database import get_db
from app.schemas.music import (
    MusicResponse, 
    MusicWithFavorite,
    MusicListResponse,
    CollectionCreate, 
    CollectionResponse, 
    CollectionUpdate,
    JournalResponse, 
    UserStatsResponse, 
    MusicStatusResponse
)
from app.services.auth_service import get_current_user
from app.services.music_service import (
    get_user_musics_with_favorite,
    get_music_by_id,
    delete_music,
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


@router.get("/", response_model=List[MusicWithFavorite])
async def list_musics(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    status: Optional[str] = Query(None),
    emotion: Optional[str] = Query(None, description="情绪筛选: happy, calm, sad, energetic, nostalgic"),
    is_favorite: Optional[bool] = Query(None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    获取用户音乐列表（包含收藏状态）
    """
    musics = get_user_musics_with_favorite(
        db, current_user.id, skip, limit, status, emotion
    )
    
    # 如果需要筛选收藏
    if is_favorite is not None:
        musics = [m for m in musics if m["is_favorite"] == is_favorite]
    
    return musics


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
async def delete_music_endpoint(
    music_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    删除音乐
    """
    delete_music(db, music_id, current_user.id)
    return None


@router.get("/{music_id}/status", response_model=MusicStatusResponse)
async def get_music_status(
    music_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    获取音乐生成状态
    """
    music = get_music_by_id(db, music_id, current_user.id)
    return {
        "id": music.id,
        "status": music.status,
        "progress": None,
        "error_message": None,
        "music_url": music.music_url if music.status == "completed" else None
    }


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


@router.post("/collections", response_model=CollectionResponse)
async def create_collection(
    data: CollectionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    添加收藏
    """
    collection = add_to_collection(
        db, 
        current_user.id, 
        data.music_id,
        data.folder_name,
        data.note,
        data.tags
    )
    return collection


@router.get("/collections/", response_model=List[CollectionResponse])
async def list_collections(
    folder_name: Optional[str] = Query(None),
    tag: Optional[str] = Query(None, description="标签筛选"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    获取收藏列表
    """
    collections = get_user_collections_with_tags(
        db, current_user.id, folder_name, tag
    )
    return collections


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
