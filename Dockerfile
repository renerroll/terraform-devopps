# Use Python 3.9 slim image
FROM python:3.9-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /code

# System deps needed for some Python packages (psycopg2)
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential libpq-dev gcc && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt /code/
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy project
COPY . /code/

# Replace `project` in the CMD below with your Django project module name if different
CMD ["gunicorn", "project.wsgi:application", "--bind", "0.0.0.0:8000"]
