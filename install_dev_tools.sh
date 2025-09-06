#!/bin/bash

set -e 

echo "Updating package list..."
sudo apt update -y

# Docker
if ! command -v docker &> /dev/null; then
  echo "🐳 Installing Docker..."
  sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
else
  echo "✅ Docker already installed"
fi

# Docker Compose
if ! docker compose version &> /dev/null; then
  echo "🔧 Installing Docker Compose plugin..."
  sudo apt install -y docker-compose-plugin
else
  echo "✅ Docker Compose already installed"
fi

# Python 3.9+
if ! command -v python3 &> /dev/null || [[ $(python3 -V | cut -d ' ' -f 2 | cut -d '.' -f 1-2) < "3.9" ]]; then
  echo "🐍 Installing Python 3.9+ and pip..."
  sudo apt install -y python3 python3-pip
else
  echo "✅ Python 3.9+ already installed"
fi

# Django
if ! python3 -m pip show django &> /dev/null; then
  echo "🌀 Creating virtual environment..."
  python3 -m venv venv
  source venv/bin/activate

  echo "🌐 Installing Django inside virtual environment..."
  pip install django

else
  echo "✅ Django already installed"
fi

echo "Dev tools are installed and ready!"
