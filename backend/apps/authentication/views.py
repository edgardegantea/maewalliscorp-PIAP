from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate, get_user_model
from django.utils import timezone
from .serializers import (
    UserSerializer, RegisterSerializer, LoginSerializer,
    ChangePasswordSerializer, PasswordResetRequestSerializer,
    PasswordResetConfirmSerializer, EmailVerificationSerializer,
    ProfileUpdateSerializer
)
from .models import PasswordResetToken, EmailVerificationToken, LoginAttempt

User = get_user_model()


def get_client_ip(request):
    """Obtiene la IP del cliente"""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    """
    Registro de nuevo usuario
    POST /api/auth/register/
    Body: {username, email, password, password_confirm, first_name, last_name, phone, position, department}
    """
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        
        # Crear token de verificación de email
        verification_token = EmailVerificationToken.objects.create(user=user)
        
        # TODO: Enviar email de verificación
        # send_verification_email(user, verification_token.token)
        
        # Generar tokens JWT
        refresh = RefreshToken.for_user(user)
        
        return Response({
            'message': 'Usuario registrado exitosamente. Por favor verifica tu email.',
            'user': UserSerializer(user).data,
            'tokens': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            },
            'verification_token': str(verification_token.token)  # Solo para testing
        }, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    """
    Login de usuario
    POST /api/auth/login/
    Body: {username, password}
    """
    serializer = LoginSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    username = serializer.validated_data['username']
    password = serializer.validated_data['password']
    ip_address = get_client_ip(request)
    user_agent = request.META.get('HTTP_USER_AGENT', '')
    
    user = authenticate(username=username, password=password)
    
    # Registrar intento de login
    LoginAttempt.objects.create(
        username=username,
        ip_address=ip_address,
        success=user is not None,
        user_agent=user_agent
    )
    
    if user is not None:
        if not user.is_active:
            return Response({
                'detail': 'Esta cuenta ha sido desactivada.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        refresh = RefreshToken.for_user(user)
        
        return Response({
            'message': 'Login exitoso',
            'user': UserSerializer(user).data,
            'tokens': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }
        }, status=status.HTTP_200_OK)
    
    return Response({
        'detail': 'Credenciales inválidas.'
    }, status=status.HTTP_401_UNAUTHORIZED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    """
    Logout de usuario (blacklist del refresh token)
    POST /api/auth/logout/
    Body: {refresh}
    """
    try:
        refresh_token = request.data.get('refresh')
        if refresh_token:
            token = RefreshToken(refresh_token)
            token.blacklist()
        
        return Response({
            'message': 'Logout exitoso'
        }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({
            'detail': 'Error al cerrar sesión.'
        }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password_view(request):
    """
    Cambio de contraseña autenticado
    POST /api/auth/change-password/
    Body: {old_password, new_password, new_password_confirm}
    """
    serializer = ChangePasswordSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    user = request.user
    
    # Verificar contraseña actual
    if not user.check_password(serializer.validated_data['old_password']):
        return Response({
            'old_password': ['La contraseña actual es incorrecta.']
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Establecer nueva contraseña
    user.set_password(serializer.validated_data['new_password'])
    user.save()
    
    return Response({
        'message': 'Contraseña cambiada exitosamente.'
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([AllowAny])
def password_reset_request_view(request):
    """
    Solicitar recuperación de contraseña
    POST /api/auth/password-reset/request/
    Body: {email}
    """
    serializer = PasswordResetRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    email = serializer.validated_data['email']
    
    try:
        user = User.objects.get(email=email)
        
        # Invalidar tokens anteriores
        PasswordResetToken.objects.filter(user=user, is_used=False).update(is_used=True)
        
        # Crear nuevo token
        reset_token = PasswordResetToken.objects.create(user=user)
        
        # TODO: Enviar email con el token
        # send_password_reset_email(user, reset_token.token)
        
        return Response({
            'message': 'Se ha enviado un email con instrucciones para recuperar tu contraseña.',
            'reset_token': str(reset_token.token)  # Solo para testing
        }, status=status.HTTP_200_OK)
    
    except User.DoesNotExist:
        # Por seguridad, siempre retornar éxito
        return Response({
            'message': 'Si el email existe en nuestro sistema, recibirás instrucciones para recuperar tu contraseña.'
        }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([AllowAny])
def password_reset_confirm_view(request):
    """
    Confirmar recuperación de contraseña
    POST /api/auth/password-reset/confirm/
    Body: {token, new_password, new_password_confirm}
    """
    serializer = PasswordResetConfirmSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    token_uuid = serializer.validated_data['token']
    
    try:
        reset_token = PasswordResetToken.objects.get(token=token_uuid)
        
        if not reset_token.is_valid():
            return Response({
                'detail': 'El token ha expirado o ya ha sido utilizado.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Establecer nueva contraseña
        user = reset_token.user
        user.set_password(serializer.validated_data['new_password'])
        user.save()
        
        # Marcar token como usado
        reset_token.is_used = True
        reset_token.save()
        
        return Response({
            'message': 'Contraseña restablecida exitosamente.'
        }, status=status.HTTP_200_OK)
    
    except PasswordResetToken.DoesNotExist:
        return Response({
            'detail': 'Token inválido.'
        }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def verify_email_view(request):
    """
    Verificar email
    POST /api/auth/verify-email/
    Body: {token}
    """
    serializer = EmailVerificationSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    token_uuid = serializer.validated_data['token']
    
    try:
        verification_token = EmailVerificationToken.objects.get(token=token_uuid)
        
        if not verification_token.is_valid():
            return Response({
                'detail': 'El token ha expirado o ya ha sido utilizado.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Verificar email
        user = verification_token.user
        user.is_verified = True
        user.save()
        
        # Marcar token como usado
        verification_token.is_used = True
        verification_token.save()
        
        return Response({
            'message': 'Email verificado exitosamente.'
        }, status=status.HTTP_200_OK)
    
    except EmailVerificationToken.DoesNotExist:
        return Response({
            'detail': 'Token inválido.'
        }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile_view(request):
    """
    Obtener perfil del usuario autenticado
    GET /api/auth/profile/
    """
    serializer = UserSerializer(request.user)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def profile_update_view(request):
    """
    Actualizar perfil del usuario
    PUT/PATCH /api/auth/profile/update/
    Body: {first_name, last_name, phone, position, department}
    """
    serializer = ProfileUpdateSerializer(request.user, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response({
            'message': 'Perfil actualizado exitosamente.',
            'user': UserSerializer(request.user).data
        }, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
