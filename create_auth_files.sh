#!/bin/bash

# Navegar al directorio del proyecto
cd /Users/edegantea/development/maewalliscorp/gestionproyectos/backend

echo "🚀 Creando archivos de autenticación JWT..."

# 1. Crear serializers.py
cat > apps/authentication/serializers.py << 'EOF'
from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    """Serializer para el modelo User"""
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'full_name', 'role', 'is_active', 'created_at']
        read_only_fields = ['id', 'created_at']


class LoginSerializer(serializers.Serializer):
    """Serializer para login"""
    username = serializers.CharField(required=True)
    password = serializers.CharField(write_only=True, required=True)


class RegisterSerializer(serializers.ModelSerializer):
    """Serializer para registro de usuarios"""
    password = serializers.CharField(write_only=True, required=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'full_name', 'password', 'password_confirm', 'role']

    def validate_email(self, value):
        """Validar que el email sea único"""
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Este email ya está registrado.")
        return value

    def validate_username(self, value):
        """Validar que el username sea único"""
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("Este nombre de usuario ya está en uso.")
        return value

    def validate(self, data):
        """Validar que las contraseñas coincidan"""
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError({"password_confirm": "Las contraseñas no coinciden."})
        return data

    def create(self, validated_data):
        """Crear usuario con contraseña encriptada"""
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        return user
EOF

echo "✅ Creado: apps/authentication/serializers.py"

# 2. Crear views.py
cat > apps/authentication/views.py << 'EOF'
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from .serializers import LoginSerializer, RegisterSerializer, UserSerializer


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    """
    Endpoint para iniciar sesión
    POST /api/auth/login/
    Body: {"username": "user", "password": "pass"}
    """
    serializer = LoginSerializer(data=request.data)
    
    if serializer.is_valid():
        username = serializer.validated_data['username']
        password = serializer.validated_data['password']
        
        user = authenticate(username=username, password=password)
        
        if user:
            if not user.is_active:
                return Response(
                    {'detail': 'Esta cuenta está desactivada.'},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            # Generar tokens JWT
            refresh = RefreshToken.for_user(user)
            
            return Response({
                'user': UserSerializer(user).data,
                'tokens': {
                    'refresh': str(refresh),
                    'access': str(refresh.access_token),
                }
            }, status=status.HTTP_200_OK)
        
        return Response(
            {'detail': 'Credenciales inválidas.'},
            status=status.HTTP_401_UNAUTHORIZED
        )
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    """
    Endpoint para registrar nuevo usuario
    POST /api/auth/register/
    """
    serializer = RegisterSerializer(data=request.data)
    
    if serializer.is_valid():
        user = serializer.save()
        
        # Generar tokens JWT automáticamente
        refresh = RefreshToken.for_user(user)
        
        return Response({
            'user': UserSerializer(user).data,
            'tokens': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }
        }, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile_view(request):
    """
    Endpoint para obtener perfil del usuario autenticado
    GET /api/auth/profile/
    """
    serializer = UserSerializer(request.user)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def update_profile_view(request):
    """
    Endpoint para actualizar perfil del usuario autenticado
    PUT/PATCH /api/auth/profile/update/
    """
    user = request.user
    serializer = UserSerializer(user, data=request.data, partial=True)
    
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
EOF

echo "✅ Creado: apps/authentication/views.py"

# 3. Crear urls.py
cat > apps/authentication/urls.py << 'EOF'
from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

app_name = 'authentication'

urlpatterns = [
    # Autenticación
    path('login/', views.login_view, name='login'),
    path('register/', views.register_view, name='register'),
    
    # Perfil
    path('profile/', views.profile_view, name='profile'),
    path('profile/update/', views.update_profile_view, name='profile-update'),
    
    # Refresh token
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
]
EOF

echo "✅ Creado: apps/authentication/urls.py"

# 4. Actualizar URLs principales
cat > piap_project/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    # Admin
    path('admin/', admin.site.urls),
    
    # API Authentication
    path('api/auth/', include('apps.authentication.urls')),
    
    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
]
EOF

echo "✅ Actualizado: piap_project/urls.py"

# 5. Actualizar admin.py
cat > apps/users/admin.py << 'EOF'
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """Configuración del admin para el modelo User"""
    
    list_display = ['username', 'email', 'full_name', 'role', 'is_active', 'is_staff', 'created_at']
    list_filter = ['role', 'is_active', 'is_staff', 'created_at']
    search_fields = ['username', 'email', 'full_name']
    ordering = ['-created_at']
    
    fieldsets = BaseUserAdmin.fieldsets + (
        ('Información adicional', {
            'fields': ('full_name', 'role', 'created_at', 'updated_at')
        }),
    )
    
    readonly_fields = ['created_at', 'updated_at']
    
    add_fieldsets = BaseUserAdmin.add_fieldsets + (
        ('Información adicional', {
            'fields': ('email', 'full_name', 'role')
        }),
    )
EOF

echo "✅ Actualizado: apps/users/admin.py"

echo ""
echo "🎉 ¡Todos los archivos creados!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Reinicia el servidor Django: python manage.py runserver"
echo "2. Prueba los endpoints en: http://localhost:8000/api/auth/login/"