from rest_framework import permissions


class IsProjectDirectorOrReadOnly(permissions.BasePermission):
    """
    Permiso personalizado para proyectos:
    - Lectura: cualquier usuario autenticado
    - Escritura: solo el director del proyecto o superusuarios
    """
    
    def has_permission(self, request, view):
        # Todos los usuarios autenticados pueden leer
        if request.method in permissions.SAFE_METHODS:
            return request.user and request.user.is_authenticated
        
        # Solo usuarios autenticados pueden crear
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        # Lectura: cualquier usuario autenticado
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Escritura: solo director o superusuario
        return obj.director == request.user or request.user.is_superuser


class IsProjectMember(permissions.BasePermission):
    """
    Permiso para miembros del proyecto
    (se puede extender cuando se implemente el módulo de equipos)
    """
    
    def has_object_permission(self, request, view, obj):
        # Por ahora, solo el director o superusuario
        if hasattr(obj, 'director'):
            return obj.director == request.user or request.user.is_superuser
        
        # Si el objeto es un proyecto relacionado (milestone, document, comment)
        if hasattr(obj, 'project'):
            return obj.project.director == request.user or request.user.is_superuser
        
        return False


class IsProjectOwner(permissions.BasePermission):
    """
    Permiso para el propietario del contenido (comentarios, documentos)
    """
    
    def has_object_permission(self, request, view, obj):
        # Lectura: cualquier usuario autenticado del proyecto
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Escritura/eliminación: solo el creador o director del proyecto
        if hasattr(obj, 'user'):  # Para comentarios
            return obj.user == request.user or request.user.is_superuser
        
        if hasattr(obj, 'uploaded_by'):  # Para documentos
            return obj.uploaded_by == request.user or request.user.is_superuser
        
        return False
