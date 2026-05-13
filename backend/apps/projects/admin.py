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
