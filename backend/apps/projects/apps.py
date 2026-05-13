from django.apps import AppConfig


class ProjectsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.projects'
    verbose_name = 'Gestión de Proyectos'
    
    def ready(self):
        # Aquí se pueden registrar señales si es necesario
        pass
