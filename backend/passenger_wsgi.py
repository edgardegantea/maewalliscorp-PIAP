import os
import sys

# Ruta al directorio del proyecto Django (donde está manage.py)
sys.path.insert(0, os.path.dirname(__file__))

# Configurar el entorno de Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'piap_project.settings')

# Iniciar la aplicación WSGI
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
