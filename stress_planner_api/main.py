from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import os
import requests


load_dotenv()  # .envファイルを読み込む
api_key = os.getenv("API_KEY")

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 全部許可。必要ならここを安全に
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Flutterから受け取るデータ形式
class UserInput(BaseModel):
    mood: str
    time_available: str
    energy_level: str
    refresh_preference: str
    desired_outcome: str
    budget: str
    optional_comment: str = None

print(f"現在読み込んでいるAPIキー: {api_key}")

@app.post("/generate_plan")
def generate_plan(user_input: UserInput):
    prompt = create_prompt(user_input)
    suggestions = call_gemini_api(prompt)
    return {"suggestions": suggestions}

def create_prompt(user_input: UserInput):
    return f"""
あなたはストレス発散アクションを提案するAIです。

以下の条件に合う具体的な行動プランを3〜5個、理由付きで提案してください。

【ユーザー情報】
- 気分: {user_input.mood}
- 時間: {user_input.time_available}
- 体力: {user_input.energy_level}
- 好み: {user_input.refresh_preference}
- 求めるもの: {user_input.desired_outcome}
- 予算: {user_input.budget}
- その他コメント: {user_input.optional_comment}

【出力形式】
・提案タイトル
・具体的な内容（1〜2文）
・なぜその行動が合っているか（1〜2文）
"""

def call_gemini_api(prompt: str):
    url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=" + api_key
    payload = {
        "contents": [{"parts": [{"text": prompt}]}]
    }
    response = requests.post(url, json=payload)
    print("Geminiレスポンス:", response.text)
    result = response.json()
    try:
        return result['candidates'][0]['content']['parts'][0]['text']
    except:
        return "提案を取得できませんでした。"
