#!/bin/bash

# Скрипт для Ubuntu/Debian

# Перевірка та встановлення Docker
if ! command -v docker &> /dev/null; then
    echo "Встановлення Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io || { echo "Помилка встановлення Docker"; exit 1; }
else
    echo "Docker вже встановлено."
fi

# Перевірка та встановлення Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Встановлення Docker Compose..."
    sudo apt-get install -y docker-compose || { echo "Помилка встановлення Docker Compose"; exit 1; }
else
    echo "Docker Compose вже встановлено."
fi

# Перевірка та встановлення Python 3.9+
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
if [[ -z "$PYTHON_VERSION" || $(echo "$PYTHON_VERSION < 3.9" | bc) -eq 1 ]]; then
    echo "Встановлення Python 3.9..."
    sudo apt-get install -y python3 python3-pip python3-venv || { echo "Помилка встановлення Python"; exit 1; }
else
    echo "Python $PYTHON_VERSION вже встановлено."
fi

# Перевірка та встановлення Django у віртуальному середовищі
if ! python3 -m django --version &> /dev/null; then
    echo "Встановлення Django..."
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    source venv/bin/activate
    python3 -m pip install --upgrade pip
    python3 -m pip install django || { echo "Помилка встановлення Django у venv"; deactivate; exit 1; }
    echo "Django встановлено у віртуальному середовищі."
    deactivate
else
    echo "Django вже встановлено."
fi

echo "Всі інструменти встановлено або вже були встановлені."
