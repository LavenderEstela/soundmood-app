"""
FastAPI 主应用
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.config import settings
from app.database import init_db
from app.routers import auth_router, music_router, generate_router

# 创建 FastAPI 应用
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="SoundMood - AI 音乐生成平台",
    docs_url="/api/docs",
    redoc_url="/api/redoc"
)

# CORS 中间件（允许 Flutter 跨域访问）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境应限制具体域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 挂载静态文件（音乐和图片）
app.mount("/uploads", StaticFiles(directory=str(settings.UPLOAD_DIR)), name="uploads")

# 注册路由
app.include_router(auth_router)
app.include_router(music_router)
app.include_router(generate_router)

@app.on_event("startup")
async def startup_event():
    """
    应用启动时初始化数据库
    """
    print("🚀 SoundMood 后端启动中...")
    init_db()
    print(f"✅ 服务运行在 http://{settings.HOST}:{settings.PORT}")
    print(f"📖 API 文档: http://{settings.HOST}:{settings.PORT}/api/docs")

@app.get("/")
async def root():
    """
    健康检查端点
    """
    return {
        "message": "SoundMood API 运行中",
        "version": settings.APP_VERSION,
        "docs": "/api/docs"
    }

@app.get("/health")
async def health_check():
    """
    健康检查
    """
    return {"status": "healthy"}