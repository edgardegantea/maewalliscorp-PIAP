from django.contrib.auth.models import AbstractUser
from django.db import models
import uuid
from django.utils import timezone
from datetime import timedelta

class User(AbstractUser):
    """Usuario personalizado con campos adicionales"""
    email = models.EmailField(unique=True, verbose_name='Correo electrónico')
    phone = models.CharField(max_length=15, blank=True, null=True, verbose_name='Teléfono')
    position = models.CharField(max_length=100, blank=True, null=True, verbose_name='Cargo')
    department = models.CharField(max_length=100, blank=True, null=True, verbose_name='Departamento')
    is_active = models.BooleanField(default=True, verbose_name='Activo')
    is_verified = models.BooleanField(default=False, verbose_name='Email verificado')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Fecha de creación')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Fecha de actualización')
    
    class Meta:
        verbose_name = 'Usuario'
        verbose_name_plural = 'Usuarios'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.username} ({self.email})"


class PasswordResetToken(models.Model):
    """Token para recuperación de contraseña"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='reset_tokens')
    token = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    
    class Meta:
        verbose_name = 'Token de Recuperación'
        verbose_name_plural = 'Tokens de Recuperación'
        ordering = ['-created_at']
    
    def save(self, *args, **kwargs):
        if not self.expires_at:
            # Token válido por 1 hora
            self.expires_at = timezone.now() + timedelta(hours=1)
        super().save(*args, **kwargs)
    
    def is_valid(self):
        """Verifica si el token es válido"""
        return not self.is_used and timezone.now() < self.expires_at
    
    def __str__(self):
        return f"Token para {self.user.username} - {self.token}"


class EmailVerificationToken(models.Model):
    """Token para verificación de email"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='verification_tokens')
    token = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    
    class Meta:
        verbose_name = 'Token de Verificación'
        verbose_name_plural = 'Tokens de Verificación'
        ordering = ['-created_at']
    
    def save(self, *args, **kwargs):
        if not self.expires_at:
            # Token válido por 24 horas
            self.expires_at = timezone.now() + timedelta(hours=24)
        super().save(*args, **kwargs)
    
    def is_valid(self):
        """Verifica si el token es válido"""
        return not self.is_used and timezone.now() < self.expires_at
    
    def __str__(self):
        return f"Token de verificación para {self.user.username}"


class LoginAttempt(models.Model):
    """Registro de intentos de login para seguridad"""
    username = models.CharField(max_length=150)
    ip_address = models.GenericIPAddressField()
    success = models.BooleanField()
    timestamp = models.DateTimeField(auto_now_add=True)
    user_agent = models.TextField(blank=True, null=True)
    
    class Meta:
        verbose_name = 'Intento de Login'
        verbose_name_plural = 'Intentos de Login'
        ordering = ['-timestamp']
    
    def __str__(self):
        status = "Exitoso" if self.success else "Fallido"
        return f"{self.username} - {status} - {self.timestamp}"
