from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q, Count, Sum, Avg
from .models import (
    Project, ProjectCategory, ProjectMilestone,
    ProjectDocument, ProjectComment,
    Sprint, BacklogItem, Task, Risk, Incident, ProjectMember, Change, CompanySettings
)
from .serializers import (
    ProjectListSerializer, ProjectDetailSerializer,
    ProjectCreateUpdateSerializer, ProjectCategorySerializer,
    ProjectMilestoneSerializer, ProjectDocumentSerializer,
    ProjectCommentSerializer, SprintSerializer, BacklogItemSerializer,
    TaskSerializer, RiskSerializer, IncidentSerializer, ProjectMemberSerializer,
    ChangeSerializer, UserBasicSerializer, CompanySettingsSerializer
)
from .permissions import IsProjectDirectorOrReadOnly, IsProjectMember


from django.contrib.auth import get_user_model

User = get_user_model()

class UserViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet solo lectura para listar usuarios"""
    queryset = User.objects.filter(is_active=True)
    serializer_class = UserBasicSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['username', 'first_name', 'last_name', 'email']

class CompanySettingsViewSet(viewsets.GenericViewSet):
    """ViewSet para la configuración de la empresa (Singleton)"""
    permission_classes = [IsAuthenticated]
    serializer_class = CompanySettingsSerializer

    def get_object(self):
        return CompanySettings.load()

    def list(self, request):
        serializer = self.get_serializer(self.get_object())
        return Response(serializer.data)

    def create(self, request):
        # Create is actually update for singleton
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)
    
    @action(detail=False, methods=['patch', 'put'])
    def update_settings(self, request):
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

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
        
        from django.utils import timezone
        today = timezone.now().date()
        
        stats = {
            'total_projects': queryset.count(),
            'by_status': {},
            'by_priority': {},
            'total_budget_planned': queryset.aggregate(Sum('planned_budget'))['planned_budget__sum'] or 0,
            'total_budget_actual': queryset.aggregate(Sum('actual_budget'))['actual_budget__sum'] or 0,
            'avg_completion': queryset.aggregate(Avg('completion_percentage'))['completion_percentage__avg'] or 0,
            # Corregir: calcular proyectos retrasados sin usar la property
            'overdue_projects': queryset.filter(
                planned_end_date__lt=today,
                is_active=True
            ).exclude(
                status__in=['CIERRE', 'CANCELADO']
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

    @action(detail=True, methods=['get'])
    def generate_legal_document(self, request, pk=None):
        """Genera un documento legal en PDF"""
        from django.http import FileResponse
        from .legal_docs import generate_pdf
        
        project = self.get_object()
        doc_type = request.query_params.get('type', 'inicio')
        
        buffer = generate_pdf(project, doc_type)
        
        return FileResponse(buffer, as_attachment=True, filename=f"documento_{doc_type}_{project.code}.pdf")


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


class SprintViewSet(viewsets.ModelViewSet):
    """ViewSet para Sprints"""
    queryset = Sprint.objects.all()
    serializer_class = SprintSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['project', 'status']
    ordering_fields = ['number', 'start_date']
    ordering = ['project', '-number']

    @action(detail=True, methods=['get'])
    def backlog_items(self, request, pk=None):
        """Obtiene las historias de usuario de este sprint"""
        sprint = self.get_object()
        items = sprint.items.all()
        serializer = BacklogItemSerializer(items, many=True)
        return Response(serializer.data)


class BacklogItemViewSet(viewsets.ModelViewSet):
    """ViewSet para Historias de Usuario (Backlog)"""
    queryset = BacklogItem.objects.all()
    serializer_class = BacklogItemSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['project', 'sprint', 'status', 'priority']
    search_fields = ['title', 'description', 'acceptance_criteria']
    ordering_fields = ['order', 'priority', 'story_points', 'created_at']
    ordering = ['order', '-priority']


class TaskViewSet(viewsets.ModelViewSet):
    """ViewSet para Tareas"""
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['sprint', 'backlog_item', 'assigned_to', 'status']
    search_fields = ['title', 'description']
    ordering_fields = ['status', 'created_at', 'estimated_hours']
    ordering = ['status', '-created_at']


class RiskViewSet(viewsets.ModelViewSet):
    """ViewSet para Riesgos"""
    queryset = Risk.objects.all()
    serializer_class = RiskSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['project', 'probability', 'impact', 'status']
    search_fields = ['description', 'mitigation_plan']
    ordering_fields = ['probability', 'impact', 'status', 'created_at']
    ordering = ['-probability', '-impact']


class IncidentViewSet(viewsets.ModelViewSet):
    """ViewSet para Incidencias"""
    queryset = Incident.objects.all()
    serializer_class = IncidentSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['project', 'severity', 'status', 'reported_by', 'assigned_to']
    search_fields = ['title', 'description']
    ordering_fields = ['severity', 'status', 'created_at']
    ordering = ['-severity', 'status']

    def perform_create(self, serializer):
        serializer.save(reported_by=self.request.user)

class ProjectMemberViewSet(viewsets.ModelViewSet):
    """ViewSet para Miembros del Proyecto"""
    queryset = ProjectMember.objects.all()
    serializer_class = ProjectMemberSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['project', 'user', 'role']
    ordering_fields = ['role', 'assigned_at']
    ordering = ['project', 'role']

class ChangeViewSet(viewsets.ModelViewSet):
    """ViewSet para Solicitudes de Cambio"""
    queryset = Change.objects.all()
    serializer_class = ChangeSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['project', 'status', 'requester']
    search_fields = ['title', 'description', 'impact_estimated']
    ordering_fields = ['status', 'created_at']
    ordering = ['-created_at']

    def perform_create(self, serializer):
        serializer.save(requester=self.request.user)

    @action(detail=True, methods=['post'])
    def resolve(self, request, pk=None):
        """Aprueba o rechaza una solicitud de cambio"""
        change = self.get_object()
        status_param = request.data.get('status')

        if status_param not in ['APROBADA', 'RECHAZADA']:
            return Response(
                {'error': 'El estado debe ser APROBADA o RECHAZADA'},
                status=status.HTTP_400_BAD_REQUEST
            )

        from django.utils import timezone
        change.status = status_param
        change.decision_by = request.user
        change.decision_date = timezone.now()
        change.save()

        serializer = self.get_serializer(change)
        return Response(serializer.data)
