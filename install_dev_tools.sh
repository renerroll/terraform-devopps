#!/bin/bash

# Перевірка та встановлення Docker
if ! command -v docker &> /dev/null; then
    echo "Встановлення Docker..."
    brew install --cask docker || {
        echo "Помилка встановлення Docker"; exit 1;
    }
else
    echo "Docker вже встановлено."
fi

# Перевірка та встановлення Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Встановлення Docker Compose..."
    brew install docker-compose || {
        echo "Помилка встановлення Docker Compose"; exit 1;
    }
else
    echo "Docker Compose вже встановлено."
fi

# Перевірка та встановлення Python 3.9+
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
if [[ -z "$PYTHON_VERSION" || $(echo "$PYTHON_VERSION < 3.9" | bc) -eq 1 ]]; then
    echo "Встановлення Python 3.9..."
    brew install python@3.9 || {
        echo "Помилка встановлення Python"; exit 1;
    }
else
    echo "Python $PYTHON_VERSION вже встановлено."
fi

# Перевірка та встановлення Django

# Перевірка та встановлення Django
if ! python3 -m django --version &> /dev/null; then
    echo "Встановлення Django..."
    # Спроба встановити через pip з --user
    if python3 -m pip install --user django; then
        echo "Django встановлено через --user."
    else
        echo "Створення віртуального середовища..."
        python3 -m venv venv
        source venv/bin/activate
        python3 -m pip install --upgrade pip
        python3 -m pip install django || {
            echo "Помилка встановлення Django у venv"; exit 1;
        }
        echo "Django встановлено у віртуальному середовищі."
    fi
else
    echo "Django вже встановлено."
fi

echo "Всі інструменти встановлено або вже були встановлені."
