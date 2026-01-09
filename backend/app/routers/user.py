"""
用户管理路由 - 完整版
"""
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.user import (
    UserResponse, 
    UserSettingsResponse, 
    UserSettingsUpdate, 
    UserProfileUpdate
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
    allowed_types = ["image/jpeg", "image/png", "image/gif", "image/webp"]
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail="不支持的图片格式"
        )
    
    # 保存文件
    file_ext = file.filename.split(".")[-1] if file.filename else "jpg"
    filename = f"avatar_{current_user.id}_{uuid.uuid4()}.{file_ext}"
    
    # 确保目录存在
    image_dir = settings.UPLOAD_DIR / "images"
    image_dir.mkdir(parents=True, exist_ok=True)
    
    file_path = image_dir / filename
    
    with open(file_path, "wb") as f:
        content = await file.read()
        f.write(content)
    
    # 更新用户头像
    avatar_url = f"/uploads/images/{filename}"
    current_user.avatar_url = avatar_url
    db.commit()
    db.refresh(current_user)
    
    return current_user
