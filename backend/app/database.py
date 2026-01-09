"""
数据库配置
"""
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.config import settings

# 根据数据库类型配置连接参数
connect_args = {}
if "sqlite" in settings.DATABASE_URL:
    # SQLite 需要这个参数
    connect_args = {"check_same_thread": False}

# MySQL 连接池配置
pool_config = {}
if "mysql" in settings.DATABASE_URL:
    pool_config = {
        "pool_size": 10,
        "max_overflow": 20,
        "pool_pre_ping": True,  # 自动重连
        "pool_recycle": 3600,   # 1小时回收连接
    }

engine = create_engine(
    settings.DATABASE_URL,
    connect_args=connect_args,
    echo=settings.DEBUG,
    **pool_config
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    """获取数据库会话"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    """初始化数据库"""
    from app.models import User, UserSettings, Music, Collection, Favorite
    Base.metadata.create_all(bind=engine)
