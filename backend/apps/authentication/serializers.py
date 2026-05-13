from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    """Serializer para información del usuario"""
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 
                  'phone', 'position', 'department', 'is_verified', 
                  'created_at', 'updated_at']
        read_only_fields = ['id', 'is_verified', 'created_at', 'updated_at']


class RegisterSerializer(serializers.ModelSerializer):
    """Serializer para registro de usuarios"""
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True, required=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password_confirm', 
                  'first_name', 'last_name', 'phone', 'position', 'department']
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({"password": "Las contraseñas no coinciden."})
        
        # Validar email único
        if User.objects.filter(email=attrs['email']).exists():
            raise serializers.ValidationError({"email": "Este email ya está registrado."})
        
        # Validar username único
        if User.objects.filter(username=attrs['username']).exists():
            raise serializers.ValidationError({"username": "Este nombre de usuario ya está en uso."})
        
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        return user


class LoginSerializer(serializers.Serializer):
    """Serializer para login"""
    username = serializers.CharField(required=True)
    password = serializers.CharField(required=True, write_only=True)


class ChangePasswordSerializer(serializers.Serializer):
    """Serializer para cambio de contraseña autenticado"""
    old_password = serializers.CharField(required=True, write_only=True)
    new_password = serializers.CharField(required=True, write_only=True, validators=[validate_password])
    new_password_confirm = serializers.CharField(required=True, write_only=True)
    
    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError({"new_password": "Las contraseñas no coinciden."})
        return attrs


class PasswordResetRequestSerializer(serializers.Serializer):
    """Serializer para solicitar recuperación de contraseña"""
    email = serializers.EmailField(required=True)


class PasswordResetConfirmSerializer(serializers.Serializer):
    """Serializer para confirmar recuperación de contraseña"""
    token = serializers.UUIDField(required=True)
    new_password = serializers.CharField(required=True, write_only=True, validators=[validate_password])
    new_password_confirm = serializers.CharField(required=True, write_only=True)
    
    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError({"new_password": "Las contraseñas no coinciden."})
        return attrs


class EmailVerificationSerializer(serializers.Serializer):
    """Serializer para verificación de email"""
    token = serializers.UUIDField(required=True)


class ProfileUpdateSerializer(serializers.ModelSerializer):
    """Serializer para actualizar perfil"""
    class Meta:
        model = User
        fields = ['first_name', 'last_name', 'phone', 'position', 'department']
