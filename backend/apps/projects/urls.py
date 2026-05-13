from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'categories', views.ProjectCategoryViewSet, basename='project-category')
router.register(r'projects', views.ProjectViewSet, basename='project')
router.register(r'milestones', views.ProjectMilestoneViewSet, basename='project-milestone')
router.register(r'documents', views.ProjectDocumentViewSet, basename='project-document')
router.register(r'comments', views.ProjectCommentViewSet, basename='project-comment')
router.register(r'sprints', views.SprintViewSet, basename='project-sprint')
router.register(r'backlog', views.BacklogItemViewSet, basename='project-backlog')
router.register(r'tasks', views.TaskViewSet, basename='project-task')
router.register(r'risks', views.RiskViewSet, basename='project-risk')
router.register(r'incidents', views.IncidentViewSet, basename='project-incident')
router.register(r'members', views.ProjectMemberViewSet, basename='project-member')
router.register(r'users', views.UserViewSet, basename='project-user')
router.register(r'changes', views.ChangeViewSet, basename='project-change')
router.register(r'company-settings', views.CompanySettingsViewSet, basename='company-settings')

urlpatterns = [
    path('', include(router.urls)),
]
