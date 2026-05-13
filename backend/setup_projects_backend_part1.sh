#!/bin/bash

# Script para crear el módulo de Proyectos - Backend
# Ejecutar desde: /Users/edegantea/development/maewalliscorp/gestionproyectos/backend/

echo "🚀 Creando módulo de Proyectos - Backend..."

# 1. Crear app projects si no existe
if [ ! -d "apps/projects" ]; then
    python manage.py startapp projects
    mv projects apps/
    echo "✓ App projects creada"
fi

# 2. Crear estructura de directorios
mkdir -p apps/projects/migrations

# 3. Crear models.py
echo "📄 Creando models.py..."
cat > apps/projects/models.py << 'EOF'
from django.db import models
from django.contrib.auth import get_user_model
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone

User = get_user_model()


class ProjectStatus(models.TextChoices):
    """Estados del proyecto según PMBOK"""
    INICIACION = 'INICIACION', 'Iniciación'
    PLANIFICACION = 'PLANIFICACION', 'Planificación'
    EJECUCION = 'EJECUCION', 'Ejecución'
    MONITOREO = 'MONITOREO', 'Monitoreo y Control'
    CIERRE = 'CIERRE', 'Cierre'
    PAUSADO = 'PAUSADO', 'Pausado'
    CANCELADO = 'CANCELADO', 'Cancelado'


class ProjectPriority(models.TextChoices):
    """Prioridad del proyecto"""
    BAJA = 'BAJA', 'Baja'
    MEDIA = 'MEDIA', 'Media'
    ALTA = 'ALTA', 'Alta'
    CRITICA = 'CRITICA', 'Crítica'


class ProjectCategory(models.Model):
    """Categorías de proyectos"""
    name = models.CharField(max_length=100, unique=True, verbose_name='Nombre')
    description = models.TextField(blank=True, null=True, verbose_name='Descripción')
    color = models.CharField(max_length=7, default='#667eea', verbose_name='Color')
    is_active = models.BooleanField(default=True, verbose_name='Activa')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Fecha de creación')
    
    class Meta:
        verbose_name = 'Categoría de Proyecto'
        verbose_name_plural = 'Categorías de Proyectos'
        ordering = ['name']
    
    def __str__(self):
        return self.name


class Project(models.Model):
    """Modelo principal de Proyecto"""
    # Información básica
    code = models.CharField(max_length=20, unique=True, verbose_name='Código', 
                           help_text='Código único del proyecto (ej: PIAP-2026-001)')
    name = models.CharField(max_length=255, verbose_name='Nombre del Proyecto')
    description = models.TextField(verbose_name='Descripción')
    
    # Clasificación
    category = models.ForeignKey(ProjectCategory, on_delete=models.PROTECT, 
                                related_name='projects', verbose_name='Categoría')
    status = models.CharField(max_length=20, choices=ProjectStatus.choices, 
                             default=ProjectStatus.INICIACION, verbose_name='Estado')
    priority = models.CharField(max_length=10, choices=ProjectPriority.choices, 
                               default=ProjectPriority.MEDIA, verbose_name='Prioridad')
    
    # Responsables
    director = models.ForeignKey(User, on_delete=models.PROTECT, 
                                related_name='directed_projects', 
                                verbose_name='Director del Proyecto')
    sponsor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True,
                               related_name='sponsored_projects', verbose_name='Patrocinador')
    
    # Fechas planificadas
    planned_start_date = models.DateField(verbose_name='Fecha de Inicio Planificada')
    planned_end_date = models.DateField(verbose_name='Fecha de Fin Planificada')
    
    # Fechas reales
    actual_start_date = models.DateField(null=True, blank=True, 
                                        verbose_name='Fecha de Inicio Real')
    actual_end_date = models.DateField(null=True, blank=True, 
                                      verbose_name='Fecha de Fin Real')
    
    # Presupuesto
    planned_budget = models.DecimalField(max_digits=12, decimal_places=2, 
                                        validators=[MinValueValidator(0)],
                                        verbose_name='Presupuesto Planificado')
    actual_budget = models.DecimalField(max_digits=12, decimal_places=2, default=0,
                                       validators=[MinValueValidator(0)],
                                       verbose_name='Presupuesto Ejecutado')
    
    # Alcance y objetivos
    objectives = models.TextField(verbose_name='Objetivos del Proyecto',
                                 help_text='Objetivos SMART del proyecto')
    scope = models.TextField(verbose_name='Alcance del Proyecto',
                            help_text='Delimitación del alcance')
    deliverables = models.TextField(blank=True, null=True, 
                                   verbose_name='Entregables Principales')
    
    # Riesgos y restricciones
    identified_risks = models.TextField(blank=True, null=True, 
                                       verbose_name='Riesgos Identificados')
    constraints = models.TextField(blank=True, null=True, 
                                  verbose_name='Restricciones')
    assumptions = models.TextField(blank=True, null=True, 
                                  verbose_name='Supuestos')
    
    # Progreso
    completion_percentage = models.IntegerField(default=0, 
                                               validators=[MinValueValidator(0), 
                                                         MaxValueValidator(100)],
                                               verbose_name='% de Completitud')
    
    # Metadatos
    is_active = models.BooleanField(default=True, verbose_name='Activo')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Creado')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Actualizado')
    
    # Campos adicionales de seguimiento
    notes = models.TextField(blank=True, null=True, verbose_name='Notas')
    
    class Meta:
        verbose_name = 'Proyecto'
        verbose_name_plural = 'Proyectos'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['code']),
            models.Index(fields=['status']),
            models.Index(fields=['director']),
        ]
    
    def __str__(self):
        return f"{self.code} - {self.name}"
    
    @property
    def is_overdue(self):
        """Verifica si el proyecto está retrasado"""
        if self.status not in [ProjectStatus.CIERRE, ProjectStatus.CANCELADO]:
            if self.planned_end_date < timezone.now().date():
                return True
        return False
    
    @property
    def duration_days(self):
        """Duración planificada en días"""
        return (self.planned_end_date - self.planned_start_date).days
    
    @property
    def actual_duration_days(self):
        """Duración real en días"""
        if self.actual_start_date and self.actual_end_date:
            return (self.actual_end_date - self.actual_start_date).days
        return None
    
    @property
    def budget_variance(self):
        """Variación presupuestaria"""
        return self.planned_budget - self.actual_budget
    
    @property
    def budget_variance_percentage(self):
        """Variación presupuestaria en porcentaje"""
        if self.planned_budget > 0:
            return ((self.planned_budget - self.actual_budget) / self.planned_budget) * 100
        return 0
    
    def clean(self):
        """Validaciones personalizadas"""
        from django.core.exceptions import ValidationError
        
        if self.planned_end_date < self.planned_start_date:
            raise ValidationError({
                'planned_end_date': 'La fecha de fin debe ser posterior a la fecha de inicio.'
            })
        
        if self.actual_start_date and self.actual_end_date:
            if self.actual_end_date < self.actual_start_date:
                raise ValidationError({
                    'actual_end_date': 'La fecha de fin real debe ser posterior a la fecha de inicio real.'
                })


class ProjectMilestone(models.Model):
    """Hitos del proyecto"""
    project = models.ForeignKey(Project, on_delete=models.CASCADE, 
                               related_name='milestones', verbose_name='Proyecto')
    name = models.CharField(max_length=255, verbose_name='Nombre del Hito')
    description = models.TextField(blank=True, null=True, verbose_name='Descripción')
    planned_date = models.DateField(verbose_name='Fecha Planificada')
    actual_date = models.DateField(null=True, blank=True, verbose_name='Fecha Real')
    is_completed = models.BooleanField(default=False, verbose_name='Completado')
    order = models.IntegerField(default=0, verbose_name='Orden')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Creado')
    
    class Meta:
        verbose_name = 'Hito del Proyecto'
        verbose_name_plural = 'Hitos del Proyecto'
        ordering = ['project', 'order', 'planned_date']
    
    def __str__(self):
        return f"{self.project.code} - {self.name}"


class ProjectDocument(models.Model):
    """Documentos adjuntos al proyecto"""
    project = models.ForeignKey(Project, on_delete=models.CASCADE, 
                               related_name='documents', verbose_name='Proyecto')
    name = models.CharField(max_length=255, verbose_name='Nombre del Documento')
    description = models.TextField(blank=True, null=True, verbose_name='Descripción')
    file = models.FileField(upload_to='projects/documents/', verbose_name='Archivo')
    uploaded_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True,
                                   related_name='uploaded_documents', 
                                   verbose_name='Subido por')
    uploaded_at = models.DateTimeField(auto_now_add=True, verbose_name='Fecha de Subida')
    
    class Meta:
        verbose_name = 'Documento del Proyecto'
        verbose_name_plural = 'Documentos del Proyecto'
        ordering = ['-uploaded_at']
    
    def __str__(self):
        return f"{self.project.code} - {self.name}"


class ProjectComment(models.Model):
    """Comentarios y notas del proyecto"""
    project = models.ForeignKey(Project, on_delete=models.CASCADE, 
                               related_name='comments', verbose_name='Proyecto')
    user = models.ForeignKey(User, on_delete=models.CASCADE, 
                            related_name='project_comments', verbose_name='Usuario')
    comment = models.TextField(verbose_name='Comentario')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Fecha')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Actualizado')
    
    class Meta:
        verbose_name = 'Comentario del Proyecto'
        verbose_name_plural = 'Comentarios del Proyecto'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.project.code} - {self.user.username} - {self.created_at}"
EOF

# 4. Crear serializers.py
echo "📄 Creando serializers.py..."
cat > apps/projects/serializers.py << 'EOF'
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import (
    Project, ProjectCategory, ProjectMilestone, 
    ProjectDocument, ProjectComment
)

User = get_user_model()


class UserBasicSerializer(serializers.ModelSerializer):
    """Serializer básico para usuarios"""
    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'last_name', 'email']


class ProjectCategorySerializer(serializers.ModelSerializer):
    """Serializer para categorías de proyectos"""
    projects_count = serializers.IntegerField(source='projects.count', read_only=True)
    
    class Meta:
        model = ProjectCategory
        fields = ['id', 'name', 'description', 'color', 'is_active', 
                 'created_at', 'projects_count']
        read_only_fields = ['created_at']


class ProjectMilestoneSerializer(serializers.ModelSerializer):
    """Serializer para hitos del proyecto"""
    is_overdue = serializers.SerializerMethodField()
    
    class Meta:
        model = ProjectMilestone
        fields = ['id', 'project', 'name', 'description', 'planned_date', 
                 'actual_date', 'is_completed', 'order', 'created_at', 'is_overdue']
        read_only_fields = ['created_at']
    
    def get_is_overdue(self, obj):
        """Verifica si el hito está retrasado"""
        from django.utils import timezone
        if not obj.is_completed and obj.planned_date < timezone.now().date():
            return True
        return False


class ProjectCommentSerializer(serializers.ModelSerializer):
    """Serializer para comentarios del proyecto"""
    user = UserBasicSerializer(read_only=True)
    
    class Meta:
        model = ProjectComment
        fields = ['id', 'project', 'user', 'comment', 'created_at', 'updated_at']
        read_only_fields = ['created_at', 'updated_at']


class ProjectDocumentSerializer(serializers.ModelSerializer):
    """Serializer para documentos del proyecto"""
    uploaded_by = UserBasicSerializer(read_only=True)
    file_url = serializers.SerializerMethodField()
    
    class Meta:
        model = ProjectDocument
        fields = ['id', 'project', 'name', 'description', 'file', 'file_url',
                 'uploaded_by', 'uploaded_at']
        read_only_fields = ['uploaded_at']
    
    def get_file_url(self, obj):
        request = self.context.get('request')
        if obj.file and request:
            return request.build_absolute_uri(obj.file.url)
        return None


class ProjectListSerializer(serializers.ModelSerializer):
    """Serializer para lista de proyectos (menos detalle)"""
    category_name = serializers.CharField(source='category.name', read_only=True)
    director_name = serializers.SerializerMethodField()
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    priority_display = serializers.CharField(source='get_priority_display', read_only=True)
    is_overdue = serializers.BooleanField(read_only=True)
    
    class Meta:
        model = Project
        fields = [
            'id', 'code', 'name', 'description', 'category', 'category_name',
            'status', 'status_display', 'priority', 'priority_display',
            'director', 'director_name', 'planned_start_date', 'planned_end_date',
            'planned_budget', 'actual_budget', 'completion_percentage',
            'is_active', 'is_overdue', 'created_at', 'updated_at'
        ]
    
    def get_director_name(self, obj):
        return f"{obj.director.first_name} {obj.director.last_name}" if obj.director.first_name else obj.director.username


class ProjectDetailSerializer(serializers.ModelSerializer):
    """Serializer detallado para proyectos"""
    category = ProjectCategorySerializer(read_only=True)
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=ProjectCategory.objects.all(),
        source='category',
        write_only=True
    )
    
    director = UserBasicSerializer(read_only=True)
    director_id = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.all(),
        source='director',
        write_only=True
    )
    
    sponsor = UserBasicSerializer(read_only=True)
    sponsor_id = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.all(),
        source='sponsor',
        write_only=True,
        required=False,
        allow_null=True
    )
    
    milestones = ProjectMilestoneSerializer(many=True, read_only=True)
    comments = ProjectCommentSerializer(many=True, read_only=True)
    documents = ProjectDocumentSerializer(many=True, read_only=True)
    
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    priority_display = serializers.CharField(source='get_priority_display', read_only=True)
    
    # Propiedades calculadas
    is_overdue = serializers.BooleanField(read_only=True)
    duration_days = serializers.IntegerField(read_only=True)
    actual_duration_days = serializers.IntegerField(read_only=True)
    budget_variance = serializers.DecimalField(max_digits=12, decimal_places=2, read_only=True)
    budget_variance_percentage = serializers.DecimalField(max_digits=5, decimal_places=2, read_only=True)
    
    class Meta:
        model = Project
        fields = [
            'id', 'code', 'name', 'description',
            'category', 'category_id', 'status', 'status_display',
            'priority', 'priority_display',
            'director', 'director_id', 'sponsor', 'sponsor_id',
            'planned_start_date', 'planned_end_date',
            'actual_start_date', 'actual_end_date',
            'planned_budget', 'actual_budget',
            'objectives', 'scope', 'deliverables',
            'identified_risks', 'constraints', 'assumptions',
            'completion_percentage', 'is_active', 'notes',
            'created_at', 'updated_at',
            'milestones', 'comments', 'documents',
            'is_overdue', 'duration_days', 'actual_duration_days',
            'budget_variance', 'budget_variance_percentage'
        ]
        read_only_fields = ['created_at', 'updated_at']
    
    def validate(self, data):
        """Validaciones personalizadas"""
        planned_start = data.get('planned_start_date')
        planned_end = data.get('planned_end_date')
        
        if planned_start and planned_end and planned_end < planned_start:
            raise serializers.ValidationError({
                'planned_end_date': 'La fecha de fin debe ser posterior a la fecha de inicio.'
            })
        
        actual_start = data.get('actual_start_date')
        actual_end = data.get('actual_end_date')
        
        if actual_start and actual_end and actual_end < actual_start:
            raise serializers.ValidationError({
                'actual_end_date': 'La fecha de fin real debe ser posterior a la fecha de inicio real.'
            })
        
        return data


class ProjectCreateUpdateSerializer(serializers.ModelSerializer):
    """Serializer para crear/actualizar proyectos"""
    
    class Meta:
        model = Project
        fields = [
            'code', 'name', 'description', 'category', 'status', 'priority',
            'director', 'sponsor', 'planned_start_date', 'planned_end_date',
            'actual_start_date', 'actual_end_date', 'planned_budget', 'actual_budget',
            'objectives', 'scope', 'deliverables', 'identified_risks',
            'constraints', 'assumptions', 'completion_percentage', 'is_active', 'notes'
        ]
    
    def validate(self, data):
        """Validaciones"""
        planned_start = data.get('planned_start_date')
        planned_end = data.get('planned_end_date')
        
        if planned_start and planned_end and planned_end < planned_start:
            raise serializers.ValidationError({
                'planned_end_date': 'La fecha de fin debe ser posterior a la fecha de inicio.'
            })
        
        return data
EOF

echo ""
echo "✅ Modelos y Serializers creados!"
echo ""
echo "Continúa en el siguiente mensaje con views, urls, admin y permisos..."