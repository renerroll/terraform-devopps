# Django + PostgreSQL + Nginx (Docker)

Структура проекту та інструкції для локального запуску.

Try it:

1. Build and run containers:

   docker-compose up --build -d

2. Apply migrations and create superuser:

   docker-compose exec web python manage.py migrate
   docker-compose exec web python manage.py createsuperuser

3. Open http://localhost
