import openai
from sqlalchemy.orm import Session
from crud import update_translation_task
from dotenv import load_dotenv
import os

load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")

def perform_translation(task: int, text: str, languages: list, db: Session):
    translations = {}
    for lang in languages:
        try:
            response = openai.ChatCompletion.create(
                model = "gpt-4",
                messages = [
                    {"role": "system", "content": f"You are a helpful assistant that translates text into {lang}."},
                    {"role": "user", "content": text},
                ],
                max_tokens = 1000
            )
            translated_text = response['choices'][0]['message']['content'].strip()
            translations[lang] = translated_text
        except Exception as e:
            print("Unexpected error:", e)
            translations[lang] = f"Unexpected error: {e}"
    update_translation_task(db, task, translations)
            