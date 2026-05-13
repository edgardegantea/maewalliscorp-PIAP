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
                               
    # Representantes de Nuestra Empresa (para contratos)
    developer_representative = models.CharField(max_length=255, blank=True, null=True, verbose_name='Representante Legal (Nuestra Empresa)')
    project_manager_name = models.CharField(max_length=255, blank=True, null=True, verbose_name='Responsable del Proyecto (Nuestra Empresa)')
                               
    # Datos del Cliente
    client_name = models.CharField(max_length=255, blank=True, null=True, verbose_name='Nombre de la Empresa o Cliente')
    client_representative = models.CharField(max_length=255, blank=True, null=True, verbose_name='Representante Legal o Apoderado')
    client_email = models.EmailField(blank=True, null=True, verbose_name='Correo del Cliente')
    client_phone = models.CharField(max_length=50, blank=True, null=True, verbose_name='Teléfono del Cliente')
    client_address = models.TextField(blank=True, null=True, verbose_name='Dirección del Cliente')
    
    # Datos de Facturación
    client_rfc = models.CharField(max_length=20, blank=True, null=True, verbose_name='RFC')
    client_tax_regime = models.CharField(max_length=100, blank=True, null=True, verbose_name='Régimen Fiscal')
    client_cfdi_usage = models.CharField(max_length=100, blank=True, null=True, verbose_name='Uso de CFDI')
    client_billing_email = models.EmailField(blank=True, null=True, verbose_name='Correo de Facturación')
    client_zip_code = models.CharField(max_length=10, blank=True, null=True, verbose_name='Código Postal')
    
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


class SprintStatus(models.TextChoices):
    PLANEADO = 'PLANEADO', 'Planeado'
    ACTIVO = 'ACTIVO', 'Activo'
    CERRADO = 'CERRADO', 'Cerrado'

class Sprint(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='sprints', verbose_name='Proyecto')
    number = models.PositiveIntegerField(verbose_name='Número')
    name = models.CharField(max_length=255, verbose_name='Nombre')
    goal = models.TextField(blank=True, null=True, verbose_name='Objetivo')
    start_date = models.DateField(verbose_name='Fecha de Inicio')
    end_date = models.DateField(verbose_name='Fecha de Fin')
    capacity = models.PositiveIntegerField(default=0, verbose_name='Capacidad (Puntos)')
    status = models.CharField(max_length=20, choices=SprintStatus.choices, default=SprintStatus.PLANEADO, verbose_name='Estado')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Sprint'
        verbose_name_plural = 'Sprints'
        ordering = ['project', 'number']

    def __str__(self):
        return f"{self.project.code} - Sprint {self.number}: {self.name}"


class BacklogItemPriority(models.TextChoices):
    BAJA = 'BAJA', 'Baja'
    MEDIA = 'MEDIA', 'Media'
    ALTA = 'ALTA', 'Alta'

class BacklogItemStatus(models.TextChoices):
    BACKLOG = 'BACKLOG', 'Backlog'
    EN_SPRINT = 'EN_SPRINT', 'En Sprint'
    COMPLETADA = 'COMPLETADA', 'Completada'

class BacklogItem(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='backlog_items', verbose_name='Proyecto')
    sprint = models.ForeignKey(Sprint, on_delete=models.SET_NULL, null=True, blank=True, related_name='items', verbose_name='Sprint')
    title = models.CharField(max_length=255, verbose_name='Título')
    description = models.TextField(blank=True, null=True, verbose_name='Descripción')
    acceptance_criteria = models.TextField(blank=True, null=True, verbose_name='Criterios de Aceptación')
    priority = models.CharField(max_length=10, choices=BacklogItemPriority.choices, default=BacklogItemPriority.MEDIA, verbose_name='Prioridad')
    story_points = models.PositiveIntegerField(default=0, verbose_name='Puntos de Historia')
    status = models.CharField(max_length=20, choices=BacklogItemStatus.choices, default=BacklogItemStatus.BACKLOG, verbose_name='Estado')
    order = models.PositiveIntegerField(default=0, verbose_name='Orden en Backlog')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Historia de Usuario'
        verbose_name_plural = 'Historias de Usuario'
        ordering = ['project', 'order', '-priority']

    def __str__(self):
        return f"{self.project.code} - {self.title}"


class TaskStatus(models.TextChoices):
    PENDIENTE = 'PENDIENTE', 'Pendiente'
    EN_PROGRESO = 'EN_PROGRESO', 'En Progreso'
    BLOQUEADA = 'BLOQUEADA', 'Bloqueada'
    COMPLETADA = 'COMPLETADA', 'Completada'

class Task(models.Model):
    sprint = models.ForeignKey(Sprint, on_delete=models.CASCADE, related_name='tasks', verbose_name='Sprint')
    backlog_item = models.ForeignKey(BacklogItem, on_delete=models.SET_NULL, null=True, blank=True, related_name='tasks', verbose_name='Historia de Usuario')
    title = models.CharField(max_length=255, verbose_name='Título')
    description = models.TextField(blank=True, null=True, verbose_name='Descripción')
    assigned_to = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_tasks', verbose_name='Asignado a')
    status = models.CharField(max_length=20, choices=TaskStatus.choices, default=TaskStatus.PENDIENTE, verbose_name='Estado')
    estimated_hours = models.PositiveIntegerField(default=0, verbose_name='Horas Estimadas')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Tarea'
        verbose_name_plural = 'Tareas'
        ordering = ['sprint', 'status', 'created_at']

    def __str__(self):
        return self.title


class RiskProbability(models.TextChoices):
    BAJA = 'BAJA', 'Baja'
    MEDIA = 'MEDIA', 'Media'
    ALTA = 'ALTA', 'Alta'

class RiskImpact(models.TextChoices):
    BAJO = 'BAJO', 'Bajo'
    MEDIO = 'MEDIO', 'Medio'
    ALTO = 'ALTO', 'Alto'

class RiskStatus(models.TextChoices):
    ABIERTO = 'ABIERTO', 'Abierto'
    EN_MITIGACION = 'EN_MITIGACION', 'En Mitigación'
    CERRADO = 'CERRADO', 'Cerrado'

class Risk(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='risks', verbose_name='Proyecto')
    description = models.TextField(verbose_name='Descripción')
    probability = models.CharField(max_length=10, choices=RiskProbability.choices, default=RiskProbability.MEDIA, verbose_name='Probabilidad')
    impact = models.CharField(max_length=10, choices=RiskImpact.choices, default=RiskImpact.MEDIO, verbose_name='Impacto')
    mitigation_plan = models.TextField(blank=True, null=True, verbose_name='Plan de Mitigación')
    status = models.CharField(max_length=20, choices=RiskStatus.choices, default=RiskStatus.ABIERTO, verbose_name='Estado')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Riesgo'
        verbose_name_plural = 'Riesgos'
        ordering = ['project', '-probability', '-impact']

    def __str__(self):
        return f"Riesgo: {self.description[:50]}"


class IncidentSeverity(models.TextChoices):
    BAJA = 'BAJA', 'Baja'
    MEDIA = 'MEDIA', 'Media'
    ALTA = 'ALTA', 'Alta'
    CRITICA = 'CRITICA', 'Crítica'

class IncidentStatus(models.TextChoices):
    ABIERTA = 'ABIERTA', 'Abierta'
    EN_REVISION = 'EN_REVISION', 'En Revisión'
    RESUELTA = 'RESUELTA', 'Resuelta'
    CERRADA = 'CERRADA', 'Cerrada'

class Incident(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='incidents', verbose_name='Proyecto')
    title = models.CharField(max_length=255, verbose_name='Título')
    description = models.TextField(verbose_name='Descripción')
    severity = models.CharField(max_length=10, choices=IncidentSeverity.choices, default=IncidentSeverity.MEDIA, verbose_name='Severidad')
    status = models.CharField(max_length=20, choices=IncidentStatus.choices, default=IncidentStatus.ABIERTA, verbose_name='Estado')
    reported_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='reported_incidents', verbose_name='Reportado por')
    assigned_to = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_incidents', verbose_name='Asignado a')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Incidencia'
        verbose_name_plural = 'Incidencias'
        ordering = ['project', '-severity', 'status']

    def __str__(self):
        return f"{self.project.code} - {self.title}"


class ProjectRole(models.TextChoices):
    PM = 'PM', 'Project Manager'
    DESARROLLADOR = 'DESARROLLADOR', 'Desarrollador'
    TESTER = 'TESTER', 'Tester'
    ANALISTA = 'ANALISTA', 'Analista'
    STAKEHOLDER = 'STAKEHOLDER', 'Stakeholder'

class ProjectMember(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='members', verbose_name='Proyecto')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='project_memberships', verbose_name='Usuario')
    role = models.CharField(max_length=20, choices=ProjectRole.choices, default=ProjectRole.DESARROLLADOR, verbose_name='Rol en Proyecto')
    assigned_at = models.DateTimeField(auto_now_add=True, verbose_name='Fecha de Asignación')

    class Meta:
        verbose_name = 'Miembro del Proyecto'
        verbose_name_plural = 'Miembros del Proyecto'
        unique_together = ('project', 'user')
        ordering = ['project', 'role', 'user__first_name']

    def __str__(self):
        return f"{self.user.username} - {self.get_role_display()} ({self.project.code})"


class ChangeStatus(models.TextChoices):
    SOLICITADA = 'SOLICITADA', 'Solicitada'
    EN_EVALUACION = 'EN_EVALUACION', 'En Evaluación'
    APROBADA = 'APROBADA', 'Aprobada'
    RECHAZADA = 'RECHAZADA', 'Rechazada'

class Change(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='changes', verbose_name='Proyecto')
    title = models.CharField(max_length=255, verbose_name='Título')
    description = models.TextField(verbose_name='Descripción')
    impact_estimated = models.TextField(blank=True, null=True, verbose_name='Impacto Estimado')
    requester = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='requested_changes', verbose_name='Solicitante')
    status = models.CharField(max_length=20, choices=ChangeStatus.choices, default=ChangeStatus.SOLICITADA, verbose_name='Estado')
    decision_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='decided_changes', verbose_name='Decidido por')
    decision_date = models.DateTimeField(null=True, blank=True, verbose_name='Fecha de Decisión')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Solicitud de Cambio'
        verbose_name_plural = 'Solicitudes de Cambio'
        ordering = ['project', 'status', '-created_at']

    def __str__(self):
        return f"{self.project.code} - {self.title}"

class CompanySettings(models.Model):
    """Configuración global de la empresa desarrolladora"""
    name = models.CharField(max_length=255, default='Maewallis Corp', verbose_name='Nombre de la Empresa')
    legal_name = models.CharField(max_length=255, default='Maewallis Corp', verbose_name='Razón Social')
    representative_name = models.CharField(max_length=255, blank=True, null=True, verbose_name='Representante Legal')
    rfc = models.CharField(max_length=20, blank=True, null=True, verbose_name='RFC')
    tax_regime = models.CharField(max_length=100, blank=True, null=True, verbose_name='Régimen Fiscal')
    address = models.TextField(blank=True, null=True, verbose_name='Dirección Fiscal')
    zip_code = models.CharField(max_length=10, blank=True, null=True, verbose_name='Código Postal')
    email = models.EmailField(blank=True, null=True, verbose_name='Correo de Contacto')
    phone = models.CharField(max_length=50, blank=True, null=True, verbose_name='Teléfono')
    website = models.URLField(blank=True, null=True, verbose_name='Sitio Web')
    
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Última Actualización')

    class Meta:
        verbose_name = 'Configuración de la Empresa'
        verbose_name_plural = 'Configuraciones de la Empresa'

    def save(self, *args, **kwargs):
        # Asegurar que solo exista un registro
        self.pk = 1
        super(CompanySettings, self).save(*args, **kwargs)

    @classmethod
    def load(cls):
        obj, created = cls.objects.get_or_create(pk=1)
        return obj
    
    def __str__(self):
        return self.name
