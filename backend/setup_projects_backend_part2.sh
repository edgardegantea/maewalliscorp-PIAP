#!/bin/bash

# Script para crear el módulo de Proyectos - Backend Parte 2
# Ejecutar desde: /Users/edegantea/development/maewalliscorp/gestionproyectos/backend/

echo "🚀 Creando módulo de Proyectos - Backend Parte 2..."

# 1. Crear views.py
echo "📄 Creando views.py..."
cat > apps/projects/views.py << 'EOF'
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q, Count, Sum, Avg
from .models import (
    Project, ProjectCategory, ProjectMilestone,
    ProjectDocument, ProjectComment
)
from .serializers import (
    ProjectListSerializer, ProjectDetailSerializer,
    ProjectCreateUpdateSerializer, ProjectCategorySerializer,
    ProjectMilestoneSerializer, ProjectDocumentSerializer,
    ProjectCommentSerializer
)
from .permissions import IsProjectDirectorOrReadOnly, IsProjectMember


class ProjectCategoryViewSet(viewsets.ModelViewSet):
    """ViewSet para categorías de proyectos"""
    queryset = ProjectCategory.objects.filter(is_active=True)
    serializer_class = ProjectCategorySerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'description']
    ordering_fields = ['name', 'created_at']
    ordering = ['name']


class ProjectViewSet(viewsets.ModelViewSet):
    """ViewSet para proyectos"""
    permission_classes = [IsAuthenticated, IsProjectDirectorOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'priority', 'category', 'director', 'is_active']
    search_fields = ['code', 'name', 'description', 'objectives']
    ordering_fields = ['created_at', 'planned_start_date', 'planned_end_date', 'completion_percentage']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """
        Filtra proyectos según el usuario:
        - Superusuario: todos los proyectos
        - Director: proyectos que dirige
        - Usuario normal: proyectos activos
        """
        user = self.request.user
        
        if user.is_superuser:
            return Project.objects.all()
        
        # Usuarios normales solo ven proyectos donde son director o miembro
        return Project.objects.filter(
            Q(director=user) | Q(is_active=True)
        ).distinct()
    
    def get_serializer_class(self):
        """Usa diferentes serializers según la acción"""
        if self.action == 'list':
            return ProjectListSerializer
        elif self.action in ['create', 'update', 'partial_update']:
            return ProjectCreateUpdateSerializer
        return ProjectDetailSerializer
    
    def perform_create(self, serializer):
        """Al crear, asigna al usuario actual como director si no se especifica"""
        if not serializer.validated_data.get('director'):
            serializer.save(director=self.request.user)
        else:
            serializer.save()
    
    @action(detail=False, methods=['get'])
    def my_projects(self, request):
        """Obtiene los proyectos del usuario autenticado"""
        projects = self.get_queryset().filter(director=request.user)
        serializer = self.get_serializer(projects, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def statistics(self, request):
        """Obtiene estadísticas generales de proyectos"""
        queryset = self.get_queryset()
        
        stats = {
            'total_projects': queryset.count(),
            'by_status': {},
            'by_priority': {},
            'total_budget_planned': queryset.aggregate(Sum('planned_budget'))['planned_budget__sum'] or 0,
            'total_budget_actual': queryset.aggregate(Sum('actual_budget'))['actual_budget__sum'] or 0,
            'avg_completion': queryset.aggregate(Avg('completion_percentage'))['completion_percentage__avg'] or 0,
            'overdue_projects': queryset.filter(
                is_overdue=True, 
                is_active=True
            ).count()
        }
        
        # Contar por estado
        from .models import ProjectStatus, ProjectPriority
        for status_choice in ProjectStatus.choices:
            count = queryset.filter(status=status_choice[0]).count()
            stats['by_status'][status_choice[1]] = count
        
        # Contar por prioridad
        for priority_choice in ProjectPriority.choices:
            count = queryset.filter(priority=priority_choice[0]).count()
            stats['by_priority'][priority_choice[1]] = count
        
        return Response(stats)
    
    @action(detail=True, methods=['post'])
    def update_progress(self, request, pk=None):
        """Actualiza el progreso del proyecto"""
        project = self.get_object()
        percentage = request.data.get('completion_percentage')
        
        if percentage is None:
            return Response(
                {'error': 'Se requiere completion_percentage'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            percentage = int(percentage)
            if percentage < 0 or percentage > 100:
                raise ValueError
        except ValueError:
            return Response(
                {'error': 'completion_percentage debe ser un número entre 0 y 100'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        project.completion_percentage = percentage
        project.save()
        
        serializer = self.get_serializer(project)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def timeline(self, request, pk=None):
        """Obtiene la línea de tiempo del proyecto con hitos"""
        project = self.get_object()
        milestones = project.milestones.all()
        
        timeline_data = {
            'project': {
                'name': project.name,
                'planned_start': project.planned_start_date,
                'planned_end': project.planned_end_date,
                'actual_start': project.actual_start_date,
                'actual_end': project.actual_end_date,
            },
            'milestones': ProjectMilestoneSerializer(milestones, many=True).data
        }
        
        return Response(timeline_data)


class ProjectMilestoneViewSet(viewsets.ModelViewSet):
    """ViewSet para hitos del proyecto"""
    queryset = ProjectMilestone.objects.all()
    serializer_class = ProjectMilestoneSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['project', 'is_completed']
    ordering_fields = ['order', 'planned_date']
    ordering = ['order', 'planned_date']
    
    @action(detail=True, methods=['post'])
    def mark_completed(self, request, pk=None):
        """Marca un hito como completado"""
        milestone = self.get_object()
        milestone.is_completed = True
        
        from django.utils import timezone
        if not milestone.actual_date:
            milestone.actual_date = timezone.now().date()
        
        milestone.save()
        serializer = self.get_serializer(milestone)
        return Response(serializer.data)


class ProjectDocumentViewSet(viewsets.ModelViewSet):
    """ViewSet para documentos del proyecto"""
    queryset = ProjectDocument.objects.all()
    serializer_class = ProjectDocumentSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['project']
    search_fields = ['name', 'description']
    
    def perform_create(self, serializer):
        """Al subir documento, registra quién lo subió"""
        serializer.save(uploaded_by=self.request.user)


class ProjectCommentViewSet(viewsets.ModelViewSet):
    """ViewSet para comentarios del proyecto"""
    queryset = ProjectComment.objects.all()
    serializer_class = ProjectCommentSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['project']
    ordering_fields = ['created_at']
    ordering = ['-created_at']
    
    def perform_create(self, serializer):
        """Al crear comentario, registra el usuario"""
        serializer.save(user=self.request.user)
EOF

# 2. Crear permissions.py
echo "📄 Creando permissions.py..."
cat > apps/projects/permissions.py << 'EOF'
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
EOF

# 3. Crear urls.py
echo "📄 Creando urls.py..."
cat > apps/projects/urls.py << 'EOF'
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'categories', views.ProjectCategoryViewSet, basename='project-category')
router.register(r'projects', views.ProjectViewSet, basename='project')
router.register(r'milestones', views.ProjectMilestoneViewSet, basename='project-milestone')
router.register(r'documents', views.ProjectDocumentViewSet, basename='project-document')
router.register(r'comments', views.ProjectCommentViewSet, basename='project-comment')

urlpatterns = [
    path('', include(router.urls)),
]
EOF

# 4. Crear admin.py
echo "📄 Creando admin.py..."
cat > apps/projects/admin.py << 'EOF'
from django.contrib import admin
from django.utils.html import format_html
from .models import (
    Project, ProjectCategory, ProjectMilestone,
    ProjectDocument, ProjectComment
)


@admin.register(ProjectCategory)
class ProjectCategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'colored_badge', 'is_active', 'projects_count', 'created_at']
    list_filter = ['is_active', 'created_at']
    search_fields = ['name', 'description']
    ordering = ['name']
    
    def colored_badge(self, obj):
        return format_html(
            '<span style="background-color: {}; color: white; padding: 3px 10px; border-radius: 3px;">{}</span>',
            obj.color,
            obj.name
        )
    colored_badge.short_description = 'Vista previa'
    
    def projects_count(self, obj):
        return obj.projects.count()
    projects_count.short_description = 'Proyectos'


class ProjectMilestoneInline(admin.TabularInline):
    model = ProjectMilestone
    extra = 1
    fields = ['name', 'planned_date', 'actual_date', 'is_completed', 'order']


class ProjectDocumentInline(admin.TabularInline):
    model = ProjectDocument
    extra = 0
    fields = ['name', 'file', 'uploaded_by', 'uploaded_at']
    readonly_fields = ['uploaded_by', 'uploaded_at']


class ProjectCommentInline(admin.TabularInline):
    model = ProjectComment
    extra = 0
    fields = ['user', 'comment', 'created_at']
    readonly_fields = ['user', 'created_at']


@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = [
        'code', 'name', 'status_badge', 'priority_badge', 'director',
        'completion_bar', 'budget_status', 'planned_end_date', 'is_overdue_icon'
    ]
    list_filter = [
        'status', 'priority', 'category', 'is_active',
        'planned_start_date', 'planned_end_date'
    ]
    search_fields = ['code', 'name', 'description', 'objectives']
    readonly_fields = [
        'created_at', 'updated_at', 'is_overdue', 'duration_days',
        'budget_variance', 'budget_variance_percentage'
    ]
    
    fieldsets = (
        ('Información Básica', {
            'fields': ('code', 'name', 'description', 'category')
        }),
        ('Clasificación', {
            'fields': ('status', 'priority', 'is_active')
        }),
        ('Responsables', {
            'fields': ('director', 'sponsor')
        }),
        ('Fechas Planificadas', {
            'fields': ('planned_start_date', 'planned_end_date')
        }),
        ('Fechas Reales', {
            'fields': ('actual_start_date', 'actual_end_date'),
            'classes': ('collapse',)
        }),
        ('Presupuesto', {
            'fields': ('planned_budget', 'actual_budget', 'budget_variance', 'budget_variance_percentage')
        }),
        ('Alcance y Objetivos', {
            'fields': ('objectives', 'scope', 'deliverables'),
            'classes': ('collapse',)
        }),
        ('Gestión de Riesgos', {
            'fields': ('identified_risks', 'constraints', 'assumptions'),
            'classes': ('collapse',)
        }),
        ('Progreso', {
            'fields': ('completion_percentage',)
        }),
        ('Información Adicional', {
            'fields': ('notes', 'created_at', 'updated_at', 'is_overdue', 'duration_days'),
            'classes': ('collapse',)
        }),
    )
    
    inlines = [ProjectMilestoneInline, ProjectDocumentInline, ProjectCommentInline]
    
    def status_badge(self, obj):
        colors = {
            'INICIACION': '#6c757d',
            'PLANIFICACION': '#17a2b8',
            'EJECUCION': '#28a745',
            'MONITOREO': '#ffc107',
            'CIERRE': '#007bff',
            'PAUSADO': '#fd7e14',
            'CANCELADO': '#dc3545',
        }
        return format_html(
            '<span style="background-color: {}; color: white; padding: 3px 10px; border-radius: 3px;">{}</span>',
            colors.get(obj.status, '#6c757d'),
            obj.get_status_display()
        )
    status_badge.short_description = 'Estado'
    
    def priority_badge(self, obj):
        colors = {
            'BAJA': '#28a745',
            'MEDIA': '#ffc107',
            'ALTA': '#fd7e14',
            'CRITICA': '#dc3545',
        }
        return format_html(
            '<span style="background-color: {}; color: white; padding: 3px 10px; border-radius: 3px;">{}</span>',
            colors.get(obj.priority, '#6c757d'),
            obj.get_priority_display()
        )
    priority_badge.short_description = 'Prioridad'
    
    def completion_bar(self, obj):
        percentage = obj.completion_percentage
        color = '#28a745' if percentage >= 70 else '#ffc107' if percentage >= 40 else '#dc3545'
        return format_html(
            '<div style="width: 100px; background-color: #e9ecef; border-radius: 3px;">'
            '<div style="width: {}%; background-color: {}; color: white; text-align: center; border-radius: 3px; padding: 2px;">{}%</div>'
            '</div>',
            percentage, color, percentage
        )
    completion_bar.short_description = '% Completitud'
    
    def budget_status(self, obj):
        variance = obj.budget_variance
        if variance > 0:
            color = '#28a745'
            icon = '▼'
        elif variance < 0:
            color = '#dc3545'
            icon = '▲'
        else:
            color = '#6c757d'
            icon = '='
        
        return format_html(
            '<span style="color: {};">{} ${:,.2f}</span>',
            color, icon, abs(variance)
        )
    budget_status.short_description = 'Variación Presup.'
    
    def is_overdue_icon(self, obj):
        if obj.is_overdue:
            return format_html('<span style="color: red; font-size: 20px;">⚠️</span>')
        return format_html('<span style="color: green;">✓</span>')
    is_overdue_icon.short_description = 'A tiempo'


@admin.register(ProjectMilestone)
class ProjectMilestoneAdmin(admin.ModelAdmin):
    list_display = ['name', 'project', 'planned_date', 'actual_date', 'is_completed', 'order']
    list_filter = ['is_completed', 'planned_date', 'project']
    search_fields = ['name', 'description', 'project__name']
    ordering = ['project', 'order', 'planned_date']


@admin.register(ProjectDocument)
class ProjectDocumentAdmin(admin.ModelAdmin):
    list_display = ['name', 'project', 'uploaded_by', 'uploaded_at']
    list_filter = ['uploaded_at', 'project']
    search_fields = ['name', 'description', 'project__name']
    readonly_fields = ['uploaded_by', 'uploaded_at']
    ordering = ['-uploaded_at']


@admin.register(ProjectComment)
class ProjectCommentAdmin(admin.ModelAdmin):
    list_display = ['project', 'user', 'comment_preview', 'created_at']
    list_filter = ['created_at', 'project']
    search_fields = ['comment', 'project__name', 'user__username']
    readonly_fields = ['user', 'created_at', 'updated_at']
    ordering = ['-created_at']
    
    def comment_preview(self, obj):
        return obj.comment[:50] + '...' if len(obj.comment) > 50 else obj.comment
    comment_preview.short_description = 'Comentario'
EOF

# 5. Crear apps.py (configuración de la app)
echo "📄 Creando apps.py..."
cat > apps/projects/apps.py << 'EOF'
from django.apps import AppConfig


class ProjectsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.projects'
    verbose_name = 'Gestión de Proyectos'
    
    def ready(self):
        # Aquí se pueden registrar señales si es necesario
        pass
EOF

# 6. Crear __init__.py
touch apps/projects/__init__.py
touch apps/projects/migrations/__init__.py

echo ""
echo "✅ Views, URLs, Admin y Permisos creados!"
echo ""
echo "Ahora necesitas:"
echo "1. Registrar la app en settings.py"
echo "2. Registrar las URLs en config/urls.py"
echo "3. Instalar django-filter: pip install django-filter"
echo "4. Ejecutar migraciones: python manage.py makemigrations && python manage.py migrate"
EOF

# Guardar el script
chmod +x setup_projects_backend_part2.sh

echo ""
echo "✅ Script creado: setup_projects_backend_part2.sh"
echo ""
echo "Ejecuta:"
echo "  ./setup_projects_backend_part2.sh"