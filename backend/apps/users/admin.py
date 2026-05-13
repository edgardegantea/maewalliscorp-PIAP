from django.contrib import admin

# El modelo User ahora está registrado en apps/authentication/admin.py
# Ya no es necesario registrarlo aquí

# Si tienes otros modelos en apps/users/models.py, regístralos aquí
# Ejemplo:
# from .models import OtroModelo
# admin.site.register(OtroModelo)