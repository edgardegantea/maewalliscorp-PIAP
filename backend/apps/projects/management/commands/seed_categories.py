from django.core.management.base import BaseCommand
from apps.projects.models import ProjectCategory


class Command(BaseCommand):
    help = 'Crea categorías de ejemplo para proyectos'

    def handle(self, *args, **kwargs):
        categories_data = [
            {
                'name': 'Desarrollo Web',
                'description': 'Proyectos de desarrollo de aplicaciones web y plataformas digitales',
                'color': '#667eea'
            },
            {
                'name': 'Infraestructura TI',
                'description': 'Proyectos de infraestructura tecnológica, servidores y redes',
                'color': '#28a745'
            },
            {
                'name': 'Marketing Digital',
                'description': 'Campañas de marketing, branding y estrategias digitales',
                'color': '#ffc107'
            },
            {
                'name': 'Investigación y Desarrollo',
                'description': 'Proyectos de investigación, innovación y desarrollo de nuevos productos',
                'color': '#17a2b8'
            },
            {
                'name': 'Consultoría',
                'description': 'Proyectos de consultoría y asesoramiento estratégico',
                'color': '#fd7e14'
            },
            {
                'name': 'Capacitación',
                'description': 'Programas de capacitación y desarrollo de talento',
                'color': '#6610f2'
            },
            {
                'name': 'Mantenimiento',
                'description': 'Proyectos de mantenimiento preventivo y correctivo',
                'color': '#6c757d'
            },
            {
                'name': 'Migración de Sistemas',
                'description': 'Proyectos de migración y actualización de sistemas legacy',
                'color': '#e83e8c'
            },
            {
                'name': 'Seguridad Informática',
                'description': 'Proyectos de seguridad, auditoría y compliance',
                'color': '#dc3545'
            },
            {
                'name': 'Transformación Digital',
                'description': 'Proyectos de transformación y modernización digital',
                'color': '#20c997'
            }
        ]

        created_count = 0
        skipped_count = 0

        for cat_data in categories_data:
            category, created = ProjectCategory.objects.get_or_create(
                name=cat_data['name'],
                defaults={
                    'description': cat_data['description'],
                    'color': cat_data['color'],
                    'is_active': True
                }
            )
            
            if created:
                created_count += 1
                self.stdout.write(
                    self.style.SUCCESS(f'✓ Categoría creada: {category.name}')
                )
            else:
                skipped_count += 1
                self.stdout.write(
                    self.style.WARNING(f'○ Categoría ya existe: {category.name}')
                )

        self.stdout.write(
            self.style.SUCCESS(
                f'\n✅ Proceso completado: {created_count} creadas, {skipped_count} ya existían'
            )
        )
