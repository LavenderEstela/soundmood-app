"""
数据库连接和会话管理
"""
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from .config import settings

# 创建数据库引擎
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,  # 自动处理连接断开
    pool_recycle=3600,   # 1小时回收连接
    echo=settings.DEBUG   # 调试模式打印SQL
)

# 会话工厂
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 模型基类
Base = declarative_base()

def get_db():
    """
    依赖注入函数：为每个请求提供数据库会话
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    """
    初始化数据库（创建所有表）
    """
    from app.models import user, music  # 导入所有模型
    Base.metadata.create_all(bind=engine)
    print("✅ 数据库表创建完成！")