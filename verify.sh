#!/usr/bin/env bash
set -e

echo "🔧 1. Установка зависимостей..."
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt

echo "🧪 2. Запуск тестов..."
pytest -q

echo "🐳 3. Сборка Docker-образа..."
docker build -t fastapi-actions-demo .

echo "🚀 4. Запуск контейнера..."
docker run -d --rm -p 8000:80 --name fastapi-actions-demo fastapi-actions-demo

echo "⏳ 5. Ожидание старта контейнера..."
sleep 3

echo "🔍 6. Проверка ответа API..."
RESPONSE=$(curl -s http://127.0.0.1:8000)
echo "Ответ сервера: $RESPONSE"

if [[ "$RESPONSE" == *"Hello, GitHub Actions!"* ]]; then
  echo "✅ Всё работает! CI/CD пройдёт успешно."
else
  echo "❌ Ошибка: ответ сервера не совпал с ожидаемым."
  docker logs fastapi-actions-demo
  exit 1
fi

echo "🧹 7. Остановка контейнера..."
docker stop fastapi-actions-demo

echo "🎉 Проверка завершена успешно!"
