"""
FastAPI 应用主文件
"""
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from app.config import settings
from app.database import init_db
from app.routers import auth_router, music_router, generate_router, user_router

app = FastAPI(title=settings.APP_NAME, debug=settings.DEBUG)

# 配置 CORS - 更宽松的配置以支持开发环境
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 开发环境允许所有源，生产环境建议改回 settings.ALLOWED_ORIGINS
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# 挂载静态文件
settings.UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(settings.UPLOAD_DIR)), name="uploads")

# 注册路由
app.include_router(auth_router)
app.include_router(music_router)
app.include_router(generate_router)
app.include_router(user_router)


@app.on_event("startup")
async def startup_event():
    """应用启动时初始化数据库"""
    init_db()


@app.get("/")
async def root():
    """根路径"""
    return {"message": "Welcome to SoundMood API"}


@app.get("/health")
async def health_check():
    """健康检查"""
    return {"status": "ok"}


# 全局异常处理
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """全局异常处理"""
    return JSONResponse(
        status_code=500,
        content={"detail": str(exc)},
    )
