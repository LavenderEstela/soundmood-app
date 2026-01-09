"""
用户服务 - 完整版
"""
from sqlalchemy.orm import Session
from app.models.user import User, UserSettings
from app.schemas.user import UserSettingsUpdate, UserProfileUpdate
from fastapi import HTTPException, status


def get_user_settings(db: Session, user_id: int) -> UserSettings:
    """获取用户设置"""
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
    """更新用户设置"""
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
    """更新用户资料"""
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
