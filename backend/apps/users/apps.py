from django.apps import AppConfig

class UsersConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.users'  # ← Cambiar de 'users' a 'apps.users'
    label = 'users'