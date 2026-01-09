"""
应用配置
"""
from pydantic_settings import BaseSettings
from pathlib import Path
from typing import List


class Settings(BaseSettings):
    # 应用配置
    APP_NAME: str = "SoundMood API"
    DEBUG: bool = True
    
    # 数据库配置 - MySQL
    DATABASE_URL: str = "mysql+pymysql://root:123456@localhost:3306/soundmood?charset=utf8mb4"
    
    # JWT 配置
    SECRET_KEY: str = "your-secret-key-here-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7天
    
    # 文件上传配置
    UPLOAD_DIR: Path = Path("uploads")
    MAX_FILE_SIZE: int = 10 * 1024 * 1024  # 10MB
    
    # CORS 配置 - 添加更多允许的源
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:5173",    # Vite 默认端口
        "http://localhost:5174",    # Vite 备用端口
        "http://localhost:4200",    # Angular 默认端口
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8080",
        "http://127.0.0.1:5173",
        "http://127.0.0.1:5174",
        "http://127.0.0.1:4200",
    ]
    
    class Config:
        case_sensitive = True


settings = Settings()
