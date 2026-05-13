from django.apps import AppConfig

class AuthenticationConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.authentication'  # ← Cambiar de 'authentication' a 'apps.authentication'
    label = 'authentication'