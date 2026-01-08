"""
应用配置管理
"""
from pydantic_settings import BaseSettings
from pathlib import Path
from typing import Optional

class Settings(BaseSettings):
    """
    应用配置（从环境变量或 .env 文件加载）
    """
    # 应用基本信息
    APP_NAME: str = "SoundMood"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    
    # 服务器配置
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    
    # 数据库配置
    DATABASE_URL: str = "DATABASE_URL=mysql+pymysql://root:123456@localhost:3306/soundmood?charset=utf8mb4"
    
    # JWT 配置
    SECRET_KEY: str = "your-super-secret-key-change-in-production-min-32-chars"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7天
    
    # AI 服务配置
    OPENAI_API_KEY: Optional[str] = None
    OPENAI_BASE_URL: Optional[str] = None
    SUNO_API_KEY: Optional[str] = None
    SUNO_API_URL: str = "https://api.suno.ai"
    
    # 文件存储配置
    BASE_DIR: Path = Path(__file__).resolve().parent.parent
    UPLOAD_DIR: Path = BASE_DIR / "uploads"
    MUSIC_DIR: Path = UPLOAD_DIR / "music"
    IMAGE_DIR: Path = UPLOAD_DIR / "images"
    TEMP_DIR: Path = UPLOAD_DIR / "temp"
    
    # 音乐生成配置
    DEFAULT_MUSIC_DURATION: int = 30
    MAX_MUSIC_DURATION: int = 120
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        extra = "ignore"
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # 确保上传目录存在
        self.UPLOAD_DIR.mkdir(exist_ok=True)
        self.MUSIC_DIR.mkdir(exist_ok=True)
        self.IMAGE_DIR.mkdir(exist_ok=True)
        self.TEMP_DIR.mkdir(exist_ok=True)

# 全局配置实例
settings = Settings()