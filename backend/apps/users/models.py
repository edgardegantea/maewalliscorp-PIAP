from django.contrib.auth.models import AbstractUser
from django.db import models

""" class User(AbstractUser):
    email = models.EmailField(unique=True)
    full_name = models.CharField(max_length=255, blank=True)
    role = models.CharField(
        max_length=50,
        choices=[
            ('ADMIN', 'Administrador'),
            ('DIRECTOR', 'Director'),
            ('PM', 'Project Manager'),
            ('TEAM_MEMBER', 'Miembro del equipo'),
        ],
        default='TEAM_MEMBER'
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'users'
        verbose_name = 'Usuario'
        verbose_name_plural = 'Usuarios'

    def __str__(self):
        return f"{self.username} - {self.full_name}" """