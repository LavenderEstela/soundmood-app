"""
用户相关 API 模式 - 完整版
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime


# 用户创建请求
class UserCreate(BaseModel):
    email: EmailStr
    username: str = Field(..., min_length=2, max_length=100)
    password: str = Field(..., min_length=6)


# 用户登录请求
class UserLogin(BaseModel):
    email: EmailStr
    password: str


# 用户响应
class UserResponse(BaseModel):
    id: int
    email: str
    username: str
    avatar_url: Optional[str]
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


# Token 响应
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


# 用户设置响应
class UserSettingsResponse(BaseModel):
    id: int
    user_id: int
    preferred_language: str
    theme_preference: str
    default_duration: int
    default_genre: str
    notify_on_complete: bool
    public_profile: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# 用户设置更新请求
class UserSettingsUpdate(BaseModel):
    preferred_language: Optional[str] = None
    theme_preference: Optional[str] = None
    default_duration: Optional[int] = Field(None, ge=15, le=120)
    default_genre: Optional[str] = None
    notify_on_complete: Optional[bool] = None
    public_profile: Optional[bool] = None


# 用户资料更新请求
class UserProfileUpdate(BaseModel):
    username: Optional[str] = Field(None, min_length=2, max_length=100)
    avatar_url: Optional[str] = None
