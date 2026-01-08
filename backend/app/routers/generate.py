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