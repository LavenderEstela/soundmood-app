"""
音乐生成路由 - 完整版
"""
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import Optional
from app.database import get_db
from app.services.auth_service import get_current_user
from app.services.music_service import create_music, update_music_status, get_music_by_id
from app.models.user import User
from app.models.music import Music, MusicStatus
from app.schemas.music import MusicResponse, GenerateResponse
from app.config import settings
import uuid
import os

router = APIRouter(prefix="/api/generate", tags=["生成"])


async def mock_generate_music(db: Session, music_id: int, music_url: str):
    """
    模拟音乐生成（实际项目中替换为真实的 AI 生成逻辑）
    """
    import asyncio
    await asyncio.sleep(2)  # 模拟生成时间
    
    # 更新状态为完成
    update_music_status(
        db=db,
        music_id=music_id,
        status="completed",
        music_url=music_url,
        emotion_tags=["calm", "peaceful"],
        primary_emotion="calm",
        ai_analysis="基于您的输入，生成了一首平静舒缓的音乐。"
    )


@router.post("/text", response_model=GenerateResponse)
async def generate_from_text(
    background_tasks: BackgroundTasks,
    title: str = Form(...),
    text: str = Form(...),
    duration: int = Form(default=30),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    从文本生成音乐
    """
    # 创建音乐记录
    music = create_music(
        db=db,
        user_id=current_user.id,
        title=title,
        input_type="text",
        input_content=text,
        duration=duration
    )
    
    # 生成模拟音乐 URL
    music_url = f"/uploads/music/generated_{music.id}.mp3"
    
    # 添加后台任务（实际项目中替换为真实的生成逻辑）
    background_tasks.add_task(mock_generate_music, db, music.id, music_url)
    
    return {
        "id": music.id,
        "status": music.status,
        "message": "音乐生成中，请稍候..."
    }


@router.post("/voice", response_model=GenerateResponse)
async def generate_from_voice(
    background_tasks: BackgroundTasks,
    title: str = Form(...),
    audio: UploadFile = File(...),
    duration: int = Form(default=30),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    从语音生成音乐
    """
    # 保存音频文件
    file_ext = audio.filename.split(".")[-1] if audio.filename else "wav"
    filename = f"voice_{current_user.id}_{uuid.uuid4()}.{file_ext}"
    
    # 确保目录存在
    audio_dir = settings.UPLOAD_DIR / "audio"
    audio_dir.mkdir(parents=True, exist_ok=True)
    
    file_path = audio_dir / filename
    with open(file_path, "wb") as f:
        content = await audio.read()
        f.write(content)
    
    # 创建音乐记录
    music = create_music(
        db=db,
        user_id=current_user.id,
        title=title,
        input_type="voice",
        input_content=f"/uploads/audio/{filename}",
        duration=duration
    )
    
    # 生成模拟音乐 URL
    music_url = f"/uploads/music/generated_{music.id}.mp3"
    
    # 添加后台任务
    background_tasks.add_task(mock_generate_music, db, music.id, music_url)
    
    return {
        "id": music.id,
        "status": music.status,
        "message": "音乐生成中，请稍候..."
    }


@router.post("/image", response_model=GenerateResponse)
async def generate_from_image(
    background_tasks: BackgroundTasks,
    title: str = Form(...),
    image: UploadFile = File(...),
    duration: int = Form(default=30),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    从图片生成音乐
    """
    # 验证文件类型
    allowed_types = ["image/jpeg", "image/png", "image/gif", "image/webp"]
    if image.content_type not in allowed_types:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="不支持的图片格式"
        )
    
    # 保存图片文件
    file_ext = image.filename.split(".")[-1] if image.filename else "jpg"
    filename = f"image_{current_user.id}_{uuid.uuid4()}.{file_ext}"
    
    # 确保目录存在
    image_dir = settings.UPLOAD_DIR / "images"
    image_dir.mkdir(parents=True, exist_ok=True)
    
    file_path = image_dir / filename
    with open(file_path, "wb") as f:
        content = await image.read()
        f.write(content)
    
    # 创建音乐记录
    music = create_music(
        db=db,
        user_id=current_user.id,
        title=title,
        input_type="image",
        input_content=f"/uploads/images/{filename}",
        duration=duration
    )
    
    # 生成模拟音乐 URL
    music_url = f"/uploads/music/generated_{music.id}.mp3"
    
    # 添加后台任务
    background_tasks.add_task(mock_generate_music, db, music.id, music_url)
    
    return {
        "id": music.id,
        "status": music.status,
        "message": "音乐生成中，请稍候..."
    }


@router.get("/status/{music_id}", response_model=MusicResponse)
async def get_generation_status(
    music_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    查询生成状态
    """
    music = get_music_by_id(db, music_id, current_user.id)
    return music
