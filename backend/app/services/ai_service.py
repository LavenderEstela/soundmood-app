"""
AI 服务：情感分析 + 音乐生成
"""
import json
import time
import uuid
import httpx
from pathlib import Path
from typing import Optional, Dict, Any, List
from sqlalchemy.orm import Session

from app.config import settings
from app.models.music import Music, MusicStatus, GenerationLog

class AIService:
    """
    AI 服务类，负责：
    1. 语音转文字 (ASR)
    2. 情感分析 (LLM)
    3. 图像理解 (Vision)
    4. 音乐生成 (Music API)
    """
    
    def __init__(self):
        self.openai_api_key = settings.OPENAI_API_KEY
        self.openai_base_url = settings.OPENAI_BASE_URL or "https://api.openai.com/v1"
        self.suno_api_key = settings.SUNO_API_KEY
        self.suno_api_url = settings.SUNO_API_URL
    
    async def analyze_text_emotion(self, text: str) -> Dict[str, Any]:
        """
        分析文本情感，返回音乐生成参数
        """
        prompt = f"""分析以下文本的情感，并给出适合的音乐参数。

文本内容：
{text}

请返回 JSON 格式（不要包含其他内容）：
{{
    "emotions": ["主要情感1", "主要情感2"],
    "mood": "整体心情描述",
    "energy_level": "high/medium/low",
    "suggested_genre": "建议的音乐风格",
    "suggested_bpm": 120,
    "suggested_instruments": ["乐器1", "乐器2"],
    "music_prompt": "用于AI音乐生成的英文提示词"
}}
"""
        
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    f"{self.openai_base_url}/chat/completions",
                    headers={
                        "Authorization": f"Bearer {self.openai_api_key}",
                        "Content-Type": "application/json"
                    },
                    json={
                        "model": "gpt-3.5-turbo",
                        "messages": [
                            {"role": "system", "content": "你是一个情感分析和音乐推荐专家。请只返回JSON格式，不要包含其他文字。"},
                            {"role": "user", "content": prompt}
                        ],
                        "temperature": 0.7
                    }
                )
                
                if response.status_code == 200:
                    result = response.json()
                    content = result["choices"][0]["message"]["content"]
                    # 清理可能的 markdown 格式
                    content = content.strip()
                    if content.startswith("```"):
                        content = content.split("```")[1]
                        if content.startswith("json"):
                            content = content[4:]
                    return json.loads(content)
                else:
                    print(f"API 错误: {response.text}")
                    return self._get_default_analysis()
                    
        except Exception as e:
            print(f"情感分析失败: {e}")
            return self._get_default_analysis()
    
    async def analyze_image_emotion(self, image_path: str) -> Dict[str, Any]:
        """
        分析图片情感，返回音乐生成参数
        """
        import base64
        
        # 读取图片并转换为 base64
        with open(image_path, "rb") as f:
            image_data = base64.b64encode(f.read()).decode("utf-8")
        
        # 获取图片格式
        ext = Path(image_path).suffix.lower()
        media_type = {
            ".jpg": "image/jpeg",
            ".jpeg": "image/jpeg", 
            ".png": "image/png",
            ".gif": "image/gif",
            ".webp": "image/webp"
        }.get(ext, "image/jpeg")
        
        prompt = """分析这张图片的情感和氛围，给出适合的音乐参数。

请返回 JSON 格式（不要包含其他内容）：
{
    "image_description": "图片内容描述",
    "emotions": ["主要情感1", "主要情感2"],
    "mood": "整体氛围描述",
    "energy_level": "high/medium/low",
    "suggested_genre": "建议的音乐风格",
    "suggested_bpm": 120,
    "suggested_instruments": ["乐器1", "乐器2"],
    "music_prompt": "用于AI音乐生成的英文提示词"
}
"""
        
        try:
            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(
                    f"{self.openai_base_url}/chat/completions",
                    headers={
                        "Authorization": f"Bearer {self.openai_api_key}",
                        "Content-Type": "application/json"
                    },
                    json={
                        "model": "gpt-4o-mini",
                        "messages": [
                            {
                                "role": "user",
                                "content": [
                                    {"type": "text", "text": prompt},
                                    {
                                        "type": "image_url",
                                        "image_url": {
                                            "url": f"data:{media_type};base64,{image_data}"
                                        }
                                    }
                                ]
                            }
                        ],
                        "max_tokens": 1000
                    }
                )
                
                if response.status_code == 200:
                    result = response.json()
                    content = result["choices"][0]["message"]["content"]
                    content = content.strip()
                    if content.startswith("```"):
                        content = content.split("```")[1]
                        if content.startswith("json"):
                            content = content[4:]
                    return json.loads(content)
                else:
                    print(f"API 错误: {response.text}")
                    return self._get_default_analysis()
                    
        except Exception as e:
            print(f"图片分析失败: {e}")
            return self._get_default_analysis()
    
    async def transcribe_audio(self, audio_path: str) -> str:
        """
        语音转文字 (Whisper API)
        """
        try:
            async with httpx.AsyncClient(timeout=60.0) as client:
                with open(audio_path, "rb") as f:
                    files = {"file": (Path(audio_path).name, f, "audio/mpeg")}
                    data = {"model": "whisper-1"}
                    
                    response = await client.post(
                        f"{self.openai_base_url}/audio/transcriptions",
                        headers={"Authorization": f"Bearer {self.openai_api_key}"},
                        files=files,
                        data=data
                    )
                    
                    if response.status_code == 200:
                        result = response.json()
                        return result.get("text", "")
                    else:
                        print(f"ASR 错误: {response.text}")
                        return ""
                        
        except Exception as e:
            print(f"语音转文字失败: {e}")
            return ""
    
    async def generate_music(self, prompt: str, duration: int = 30) -> Optional[str]:
        """
        调用音乐生成 API
        
        注意：这里使用模拟实现，实际项目中需要替换为真实的音乐生成 API
        如 Suno API、MusicGen 等
        """
        # 模拟生成：创建一个占位音频文件
        # 实际项目中，这里应该调用真实的音乐生成 API
        
        try:
            # 生成唯一文件名
            filename = f"{uuid.uuid4()}.mp3"
            output_path = settings.MUSIC_DIR / filename
            
            # ============================================
            # 这里是模拟实现，生产环境请替换为真实 API
            # ============================================
            
            # 方案1: 使用 Suno API (示例)
            # if self.suno_api_key:
            #     async with httpx.AsyncClient(timeout=120.0) as client:
            #         response = await client.post(
            #             f"{self.suno_api_url}/generate",
            #             headers={"Authorization": f"Bearer {self.suno_api_key}"},
            #             json={
            #                 "prompt": prompt,
            #                 "duration": duration,
            #                 "style": "auto"
            #             }
            #         )
            #         if response.status_code == 200:
            #             audio_data = response.content
            #             with open(output_path, "wb") as f:
            #                 f.write(audio_data)
            #             return f"/uploads/music/{filename}"
            
            # 方案2: 模拟实现（开发测试用）
            # 创建一个简单的占位文件
            print(f"[模拟] 生成音乐: {prompt[:50]}...")
            print(f"[模拟] 时长: {duration}秒")
            
            # 这里创建一个空的占位文件
            # 实际项目中应该调用真实的音乐生成服务
            output_path.touch()
            
            # 模拟延迟
            await self._simulate_delay(3)
            
            return f"/uploads/music/{filename}"
            
        except Exception as e:
            print(f"音乐生成失败: {e}")
            return None
    
    async def _simulate_delay(self, seconds: int):
        """模拟处理延迟"""
        import asyncio
        await asyncio.sleep(seconds)
    
    def _get_default_analysis(self) -> Dict[str, Any]:
        """返回默认的分析结果"""
        return {
            "emotions": ["neutral", "calm"],
            "mood": "平静",
            "energy_level": "medium",
            "suggested_genre": "ambient",
            "suggested_bpm": 90,
            "suggested_instruments": ["piano", "strings"],
            "music_prompt": "calm peaceful ambient music with soft piano and gentle strings"
        }
    
    # ============================================
    # 后台任务：完整的音乐生成流程
    # ============================================
    
    async def generate_music_from_text(
        self,
        db: Session,
        music_id: int,
        text: str,
        duration: int = 30
    ):
        """
        从文本生成音乐的完整流程（后台任务）
        """
        start_time = time.time()
        
        try:
            # 1. 情感分析
            analysis_start = time.time()
            analysis = await self.analyze_text_emotion(text)
            analysis_time = int((time.time() - analysis_start) * 1000)
            
            # 2. 生成音乐
            gen_start = time.time()
            music_prompt = analysis.get("music_prompt", "peaceful ambient music")
            music_url = await self.generate_music(music_prompt, duration)
            generation_time = int((time.time() - gen_start) * 1000)
            
            # 3. 更新数据库
            total_time = int((time.time() - start_time) * 1000)
            
            music = db.query(Music).filter(Music.id == music_id).first()
            if music:
                if music_url:
                    music.status = MusicStatus.completed
                    music.music_url = music_url
                else:
                    music.status = MusicStatus.failed
                
                music.emotion_tags = analysis.get("emotions", [])
                music.ai_analysis = analysis.get("mood", "")
                music.genre = analysis.get("suggested_genre", "")
                music.bpm = analysis.get("suggested_bpm", 120)
                music.instruments = analysis.get("suggested_instruments", [])
                
                # 创建生成日志
                log = GenerationLog(
                    music_id=music_id,
                    analysis_time=analysis_time,
                    generation_time=generation_time,
                    total_time=total_time,
                    llm_model="gpt-3.5-turbo",
                    music_model="simulated",
                    raw_prompt=music_prompt,
                    raw_response=json.dumps(analysis, ensure_ascii=False)
                )
                db.add(log)
                db.commit()
                
        except Exception as e:
            print(f"音乐生成失败: {e}")
            music = db.query(Music).filter(Music.id == music_id).first()
            if music:
                music.status = MusicStatus.failed
                
                log = GenerationLog(
                    music_id=music_id,
                    error_message=str(e),
                    total_time=int((time.time() - start_time) * 1000)
                )
                db.add(log)
                db.commit()
    
    async def generate_music_from_voice(
        self,
        db: Session,
        music_id: int,
        audio_path: str,
        duration: int = 30
    ):
        """
        从语音生成音乐的完整流程（后台任务）
        """
        start_time = time.time()
        
        try:
            # 1. 语音转文字
            asr_start = time.time()
            text = await self.transcribe_audio(audio_path)
            asr_time = int((time.time() - asr_start) * 1000)
            
            if not text:
                text = "无法识别的语音内容，将生成平静的背景音乐"
            
            # 2. 情感分析
            analysis_start = time.time()
            analysis = await self.analyze_text_emotion(text)
            analysis_time = int((time.time() - analysis_start) * 1000)
            
            # 3. 生成音乐
            gen_start = time.time()
            music_prompt = analysis.get("music_prompt", "peaceful ambient music")
            music_url = await self.generate_music(music_prompt, duration)
            generation_time = int((time.time() - gen_start) * 1000)
            
            # 4. 更新数据库
            total_time = int((time.time() - start_time) * 1000)
            
            music = db.query(Music).filter(Music.id == music_id).first()
            if music:
                if music_url:
                    music.status = MusicStatus.completed
                    music.music_url = music_url
                else:
                    music.status = MusicStatus.failed
                
                music.input_content = text  # 保存转录的文本
                music.emotion_tags = analysis.get("emotions", [])
                music.ai_analysis = analysis.get("mood", "")
                music.genre = analysis.get("suggested_genre", "")
                music.bpm = analysis.get("suggested_bpm", 120)
                music.instruments = analysis.get("suggested_instruments", [])
                
                log = GenerationLog(
                    music_id=music_id,
                    asr_time=asr_time,
                    analysis_time=analysis_time,
                    generation_time=generation_time,
                    total_time=total_time,
                    asr_model="whisper-1",
                    llm_model="gpt-3.5-turbo",
                    music_model="simulated",
                    raw_prompt=music_prompt,
                    raw_response=json.dumps(analysis, ensure_ascii=False)
                )
                db.add(log)
                db.commit()
                
        except Exception as e:
            print(f"语音音乐生成失败: {e}")
            music = db.query(Music).filter(Music.id == music_id).first()
            if music:
                music.status = MusicStatus.failed
                log = GenerationLog(
                    music_id=music_id,
                    error_message=str(e),
                    total_time=int((time.time() - start_time) * 1000)
                )
                db.add(log)
                db.commit()
    
    async def generate_music_from_image(
        self,
        db: Session,
        music_id: int,
        image_path: str,
        duration: int = 30
    ):
        """
        从图片生成音乐的完整流程（后台任务）
        """
        start_time = time.time()
        
        try:
            # 1. 图片情感分析
            analysis_start = time.time()
            analysis = await self.analyze_image_emotion(image_path)
            analysis_time = int((time.time() - analysis_start) * 1000)
            
            # 2. 生成音乐
            gen_start = time.time()
            music_prompt = analysis.get("music_prompt", "peaceful ambient music")
            music_url = await self.generate_music(music_prompt, duration)
            generation_time = int((time.time() - gen_start) * 1000)
            
            # 3. 更新数据库
            total_time = int((time.time() - start_time) * 1000)
            
            music = db.query(Music).filter(Music.id == music_id).first()
            if music:
                if music_url:
                    music.status = MusicStatus.completed
                    music.music_url = music_url
                else:
                    music.status = MusicStatus.failed
                
                music.emotion_tags = analysis.get("emotions", [])
                music.ai_analysis = analysis.get("image_description", "") + " - " + analysis.get("mood", "")
                music.genre = analysis.get("suggested_genre", "")
                music.bpm = analysis.get("suggested_bpm", 120)
                music.instruments = analysis.get("suggested_instruments", [])
                
                log = GenerationLog(
                    music_id=music_id,
                    analysis_time=analysis_time,
                    generation_time=generation_time,
                    total_time=total_time,
                    llm_model="gpt-4o-mini",
                    music_model="simulated",
                    raw_prompt=music_prompt,
                    raw_response=json.dumps(analysis, ensure_ascii=False)
                )
                db.add(log)
                db.commit()
                
        except Exception as e:
            print(f"图片音乐生成失败: {e}")
            music = db.query(Music).filter(Music.id == music_id).first()
            if music:
                music.status = MusicStatus.failed
                log = GenerationLog(
                    music_id=music_id,
                    error_message=str(e),
                    total_time=int((time.time() - start_time) * 1000)
                )
                db.add(log)
                db.commit()