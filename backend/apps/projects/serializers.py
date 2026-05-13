from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import (
    Project, ProjectCategory, ProjectMilestone, 
    ProjectDocument, ProjectComment,
    Sprint, BacklogItem, Task, Risk, Incident, ProjectMember, Change, CompanySettings
)

User = get_user_model()

class CompanySettingsSerializer(serializers.ModelSerializer):
    """Serializer para la configuración de la empresa"""
    class Meta:
        model = CompanySettings
        fields = '__all__'

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
            'client_name', 'client_representative',
            'developer_representative', 'project_manager_name',
            'client_rfc', 'client_tax_regime', 'client_cfdi_usage',
            'client_billing_email', 'client_zip_code',
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
            'developer_representative', 'project_manager_name',
            'client_name', 'client_representative', 'client_email',
            'client_phone', 'client_address',
            'client_rfc', 'client_tax_regime', 'client_cfdi_usage',
            'client_billing_email', 'client_zip_code',
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
            'director', 'sponsor', 'developer_representative', 'project_manager_name',
            'client_name', 'client_representative',
            'client_email', 'client_phone', 'client_address',
            'client_rfc', 'client_tax_regime', 'client_cfdi_usage',
            'client_billing_email', 'client_zip_code',
            'planned_start_date', 'planned_end_date',
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


class SprintSerializer(serializers.ModelSerializer):
    """Serializer para Sprints"""
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    
    class Meta:
        model = Sprint
        fields = [
            'id', 'project', 'number', 'name', 'goal', 'start_date', 
            'end_date', 'capacity', 'status', 'status_display', 
            'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']

    def validate(self, data):
        start_date = data.get('start_date')
        end_date = data.get('end_date')
        if start_date and end_date and end_date < start_date:
            raise serializers.ValidationError({
                'end_date': 'La fecha de fin debe ser posterior a la fecha de inicio.'
            })
        return data


class BacklogItemSerializer(serializers.ModelSerializer):
    """Serializer para Historias de Usuario (Backlog Items)"""
    priority_display = serializers.CharField(source='get_priority_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    sprint_name = serializers.CharField(source='sprint.name', read_only=True)
    
    class Meta:
        model = BacklogItem
        fields = [
            'id', 'project', 'sprint', 'sprint_name', 'title', 'description',
            'acceptance_criteria', 'priority', 'priority_display',
            'story_points', 'status', 'status_display', 'order',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']

class TaskSerializer(serializers.ModelSerializer):
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    assigned_to_name = serializers.SerializerMethodField()

    class Meta:
        model = Task
        fields = [
            'id', 'sprint', 'backlog_item', 'title', 'description', 
            'assigned_to', 'assigned_to_name', 'status', 'status_display', 
            'estimated_hours', 'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']

    def get_assigned_to_name(self, obj):
        if obj.assigned_to:
            return f"{obj.assigned_to.first_name} {obj.assigned_to.last_name}".strip() or obj.assigned_to.username
        return None


class RiskSerializer(serializers.ModelSerializer):
    probability_display = serializers.CharField(source='get_probability_display', read_only=True)
    impact_display = serializers.CharField(source='get_impact_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Risk
        fields = [
            'id', 'project', 'description', 'probability', 'probability_display',
            'impact', 'impact_display', 'mitigation_plan', 'status', 'status_display',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']


class IncidentSerializer(serializers.ModelSerializer):
    severity_display = serializers.CharField(source='get_severity_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    reported_by_name = serializers.SerializerMethodField()
    assigned_to_name = serializers.SerializerMethodField()

    class Meta:
        model = Incident
        fields = [
            'id', 'project', 'title', 'description', 'severity', 'severity_display',
            'status', 'status_display', 'reported_by', 'reported_by_name',
            'assigned_to', 'assigned_to_name', 'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']

    def get_reported_by_name(self, obj):
        if obj.reported_by:
            return f"{obj.reported_by.first_name} {obj.reported_by.last_name}".strip() or obj.reported_by.username
        return None

    def get_assigned_to_name(self, obj):
        if obj.assigned_to:
            return f"{obj.assigned_to.first_name} {obj.assigned_to.last_name}".strip() or obj.assigned_to.username
        return None

class ProjectMemberSerializer(serializers.ModelSerializer):
    role_display = serializers.CharField(source='get_role_display', read_only=True)
    user_data = UserBasicSerializer(source='user', read_only=True)

    class Meta:
        model = ProjectMember
        fields = [
            'id', 'project', 'user', 'user_data', 'role', 'role_display', 'assigned_at'
        ]
        read_only_fields = ['assigned_at']

class ChangeSerializer(serializers.ModelSerializer):
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    requester_name = serializers.SerializerMethodField()
    decision_by_name = serializers.SerializerMethodField()

    class Meta:
        model = Change
        fields = [
            'id', 'project', 'title', 'description', 'impact_estimated',
            'requester', 'requester_name', 'status', 'status_display',
            'decision_by', 'decision_by_name', 'decision_date',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at', 'decision_date']

    def get_requester_name(self, obj):
        if obj.requester:
            return f"{obj.requester.first_name} {obj.requester.last_name}".strip() or obj.requester.username
        return None

    def get_decision_by_name(self, obj):
        if obj.decision_by:
            return f"{obj.decision_by.first_name} {obj.decision_by.last_name}".strip() or obj.decision_by.username
        return None
