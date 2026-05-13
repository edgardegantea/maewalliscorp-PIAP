#!/bin/bash
cd /Users/edegantea/development/maewalliscorp/gestionproyectos/backend

echo "🐍 Configurando Backend Django con MySQL..."

# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate

# Actualizar pip
pip install --upgrade pip

# Instalar dependencias (NOTA: mysqlclient en lugar de psycopg2)
pip install Django==4.2.7
pip install djangorestframework==3.14.0
pip install djangorestframework-simplejwt==5.3.1
pip install mysqlclient==2.2.0
pip install django-cors-headers==4.3.1
pip install python-decouple==3.8
pip install drf-spectacular==0.27.0

# Guardar dependencias
pip freeze > requirements.txt

# Inicializar proyecto Django
django-admin startproject piap_project .

# Crear apps
mkdir -p apps
touch apps/__init__.py
python manage.py startapp users apps/users
python manage.py startapp authentication apps/authentication

# Crear archivo .env
echo "📝 Creando archivo .env..."
cat > .env << 'EOF'
SECRET_KEY=django-insecure-dev-key-change-in-production-x8k2m9p4
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

DB_NAME=piap_db
DB_USER=piap_user
DB_PASSWORD=piap_secure_password_2026
DB_HOST=localhost
DB_PORT=3306

CORS_ALLOWED_ORIGINS=http://localhost:5173
EOF

echo "✅ Backend Django configurado con MySQL"
echo "⚠️  Siguiente: configurar MySQL y crear base de datos"