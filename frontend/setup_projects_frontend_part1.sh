#!/bin/bash

# Script para crear el frontend del módulo de Proyectos
# Ejecutar desde: /Users/edegantea/development/maewalliscorp/gestionproyectos/frontend/

echo "🚀 Creando frontend del módulo de Proyectos..."

# Crear estructura de directorios
echo "📁 Creando estructura de directorios..."
mkdir -p src/pages/projects
mkdir -p src/components/projects
mkdir -p src/stores
mkdir -p src/services

# 1. Crear projectsAPI.js
echo "🌐 Creando projectsAPI.js..."
cat > src/services/projectsAPI.js << 'EOF'
import api from './api';

export const projectsAPI = {
  // Proyectos
  getProjects: (params) => api.get('/projects/projects/', { params }),
  getProject: (id) => api.get(`/projects/projects/${id}/`),
  createProject: (data) => api.post('/projects/projects/', data),
  updateProject: (id, data) => api.patch(`/projects/projects/${id}/`, data),
  deleteProject: (id) => api.delete(`/projects/projects/${id}/`),
  
  // Acciones especiales
  getMyProjects: () => api.get('/projects/projects/my_projects/'),
  getStatistics: () => api.get('/projects/projects/statistics/'),
  updateProgress: (id, percentage) => api.post(`/projects/projects/${id}/update_progress/`, {
    completion_percentage: percentage
  }),
  getTimeline: (id) => api.get(`/projects/projects/${id}/timeline/`),
  
  // Categorías
  getCategories: () => api.get('/projects/categories/'),
  getCategory: (id) => api.get(`/projects/categories/${id}/`),
  createCategory: (data) => api.post('/projects/categories/', data),
  updateCategory: (id, data) => api.patch(`/projects/categories/${id}/`, data),
  deleteCategory: (id) => api.delete(`/projects/categories/${id}/`),
  
  // Hitos
  getMilestones: (projectId) => api.get('/projects/milestones/', { params: { project: projectId } }),
  createMilestone: (data) => api.post('/projects/milestones/', data),
  updateMilestone: (id, data) => api.patch(`/projects/milestones/${id}/`, data),
  deleteMilestone: (id) => api.delete(`/projects/milestones/${id}/`),
  markMilestoneCompleted: (id) => api.post(`/projects/milestones/${id}/mark_completed/`),
  
  // Comentarios
  getComments: (projectId) => api.get('/projects/comments/', { params: { project: projectId } }),
  createComment: (data) => api.post('/projects/comments/', data),
  updateComment: (id, data) => api.patch(`/projects/comments/${id}/`, data),
  deleteComment: (id) => api.delete(`/projects/comments/${id}/`),
  
  // Documentos
  getDocuments: (projectId) => api.get('/projects/documents/', { params: { project: projectId } }),
  uploadDocument: (data) => {
    const formData = new FormData();
    Object.keys(data).forEach(key => formData.append(key, data[key]));
    return api.post('/projects/documents/', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
  },
  deleteDocument: (id) => api.delete(`/projects/documents/${id}/`),
};
EOF

# 2. Crear projectsStore.js
echo "🗄️ Creando projectsStore.js..."
cat > src/stores/projectsStore.js << 'EOF'
import { create } from 'zustand';
import { projectsAPI } from '../services/projectsAPI';

export const useProjectsStore = create((set, get) => ({
  projects: [],
  currentProject: null,
  categories: [],
  statistics: null,
  loading: false,
  error: null,

  // Obtener proyectos
  fetchProjects: async (filters = {}) => {
    set({ loading: true, error: null });
    try {
      const response = await projectsAPI.getProjects(filters);
      set({ projects: response.data, loading: false });
      return response.data;
    } catch (error) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  // Obtener proyecto por ID
  fetchProject: async (id) => {
    set({ loading: true, error: null });
    try {
      const response = await projectsAPI.getProject(id);
      set({ currentProject: response.data, loading: false });
      return response.data;
    } catch (error) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  // Crear proyecto
  createProject: async (projectData) => {
    set({ loading: true, error: null });
    try {
      const response = await projectsAPI.createProject(projectData);
      set(state => ({
        projects: [response.data, ...state.projects],
        loading: false
      }));
      return response.data;
    } catch (error) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  // Actualizar proyecto
  updateProject: async (id, projectData) => {
    set({ loading: true, error: null });
    try {
      const response = await projectsAPI.updateProject(id, projectData);
      set(state => ({
        projects: state.projects.map(p => p.id === id ? response.data : p),
        currentProject: state.currentProject?.id === id ? response.data : state.currentProject,
        loading: false
      }));
      return response.data;
    } catch (error) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  // Eliminar proyecto
  deleteProject: async (id) => {
    set({ loading: true, error: null });
    try {
      await projectsAPI.deleteProject(id);
      set(state => ({
        projects: state.projects.filter(p => p.id !== id),
        loading: false
      }));
    } catch (error) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  // Obtener mis proyectos
  fetchMyProjects: async () => {
    set({ loading: true, error: null });
    try {
      const response = await projectsAPI.getMyProjects();
      set({ projects: response.data, loading: false });
      return response.data;
    } catch (error) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  // Obtener estadísticas
  fetchStatistics: async () => {
    try {
      const response = await projectsAPI.getStatistics();
      set({ statistics: response.data });
      return response.data;
    } catch (error) {
      console.error('Error fetching statistics:', error);
      throw error;
    }
  },

  // Actualizar progreso
  updateProgress: async (id, percentage) => {
    try {
      const response = await projectsAPI.updateProgress(id, percentage);
      set(state => ({
        projects: state.projects.map(p => p.id === id ? response.data : p),
        currentProject: state.currentProject?.id === id ? response.data : state.currentProject
      }));
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // Obtener categorías
  fetchCategories: async () => {
    try {
      const response = await projectsAPI.getCategories();
      set({ categories: response.data });
      return response.data;
    } catch (error) {
      console.error('Error fetching categories:', error);
      throw error;
    }
  },

  // Limpiar estado
  clearCurrentProject: () => set({ currentProject: null }),
  clearError: () => set({ error: null }),
}));
EOF

# 3. Crear ProjectsListPage.jsx
echo "📄 Creando ProjectsListPage.jsx..."
cat > src/pages/projects/ProjectsListPage.jsx << 'EOF'
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useProjectsStore } from '../../stores/projectsStore';
import { useAuthStore } from '../../stores/authStore';
import ProjectCard from '../../components/projects/ProjectCard';
import ProjectStats from '../../components/projects/ProjectStats';
import './ProjectsListPage.css';

export default function ProjectsListPage() {
  const navigate = useNavigate();
  const user = useAuthStore(state => state.user);
  const { projects, statistics, loading, fetchProjects, fetchStatistics } = useProjectsStore();
  
  const [filters, setFilters] = useState({
    search: '',
    status: '',
    priority: '',
    category: ''
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      await fetchProjects();
      await fetchStatistics();
    } catch (error) {
      console.error('Error loading data:', error);
    }
  };

  const handleFilterChange = (key, value) => {
    setFilters(prev => ({ ...prev, [key]: value }));
  };

  const filteredProjects = projects.filter(project => {
    const matchesSearch = project.name.toLowerCase().includes(filters.search.toLowerCase()) ||
                         project.code.toLowerCase().includes(filters.search.toLowerCase());
    const matchesStatus = !filters.status || project.status === filters.status;
    const matchesPriority = !filters.priority || project.priority === filters.priority;
    
    return matchesSearch && matchesStatus && matchesPriority;
  });

  return (
    <div className="projects-page">
      <header className="projects-header">
        <div className="header-content">
          <div className="header-left">
            <h1>📊 Gestión de Proyectos</h1>
            <p>Administra y da seguimiento a todos tus proyectos</p>
          </div>
          <div className="header-actions">
            <button onClick={() => navigate('/dashboard')} className="btn-secondary">
              ← Dashboard
            </button>
            <button onClick={() => navigate('/projects/new')} className="btn-primary">
              + Nuevo Proyecto
            </button>
          </div>
        </div>
      </header>

      <main className="projects-main">
        {/* Estadísticas */}
        {statistics && <ProjectStats stats={statistics} />}

        {/* Filtros */}
        <div className="filters-section">
          <div className="search-box">
            <input
              type="text"
              placeholder="Buscar proyectos por nombre o código..."
              value={filters.search}
              onChange={(e) => handleFilterChange('search', e.target.value)}
            />
          </div>

          <div className="filter-buttons">
            <select
              value={filters.status}
              onChange={(e) => handleFilterChange('status', e.target.value)}
            >
              <option value="">Todos los estados</option>
              <option value="INICIACION">Iniciación</option>
              <option value="PLANIFICACION">Planificación</option>
              <option value="EJECUCION">Ejecución</option>
              <option value="MONITOREO">Monitoreo</option>
              <option value="CIERRE">Cierre</option>
              <option value="PAUSADO">Pausado</option>
              <option value="CANCELADO">Cancelado</option>
            </select>

            <select
              value={filters.priority}
              onChange={(e) => handleFilterChange('priority', e.target.value)}
            >
              <option value="">Todas las prioridades</option>
              <option value="BAJA">Baja</option>
              <option value="MEDIA">Media</option>
              <option value="ALTA">Alta</option>
              <option value="CRITICA">Crítica</option>
            </select>

            {(filters.search || filters.status || filters.priority) && (
              <button
                className="btn-clear"
                onClick={() => setFilters({ search: '', status: '', priority: '', category: '' })}
              >
                Limpiar filtros
              </button>
            )}
          </div>
        </div>

        {/* Lista de proyectos */}
        <div className="projects-section">
          {loading ? (
            <div className="loading-container">
              <div className="spinner"></div>
              <p>Cargando proyectos...</p>
            </div>
          ) : filteredProjects.length === 0 ? (
            <div className="empty-state">
              <div className="empty-icon">📋</div>
              <h3>No hay proyectos</h3>
              <p>Comienza creando tu primer proyecto</p>
              <button onClick={() => navigate('/projects/new')} className="btn-primary">
                + Crear Proyecto
              </button>
            </div>
          ) : (
            <div className="projects-grid">
              {filteredProjects.map(project => (
                <ProjectCard
                  key={project.id}
                  project={project}
                  onClick={() => navigate(`/projects/${project.id}`)}
                />
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
EOF

# 4. Crear ProjectsListPage.css
echo "🎨 Creando ProjectsListPage.css..."
cat > src/pages/projects/ProjectsListPage.css << 'EOF'
.projects-page {
  min-height: 100vh;
  background-color: #f5f7fa;
}

.projects-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 30px 0;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.header-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.header-left h1 {
  font-size: 2rem;
  margin: 0 0 5px 0;
}

.header-left p {
  margin: 0;
  opacity: 0.9;
  font-size: 0.95rem;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.btn-primary, .btn-secondary {
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 0.95rem;
}

.btn-primary {
  background: white;
  color: #667eea;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 1px solid white;
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.3);
}

.projects-main {
  max-width: 1400px;
  margin: 0 auto;
  padding: 30px 20px;
}

.filters-section {
  background: white;
  border-radius: 10px;
  padding: 20px;
  margin-bottom: 30px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.search-box {
  margin-bottom: 15px;
}

.search-box input {
  width: 100%;
  padding: 12px 20px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.3s;
}

.search-box input:focus {
  outline: none;
  border-color: #667eea;
}

.filter-buttons {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.filter-buttons select {
  padding: 10px 15px;
  border: 2px solid #e0e0e0;
  border-radius: 6px;
  background: white;
  cursor: pointer;
  font-size: 0.9rem;
  transition: border-color 0.3s;
}

.filter-buttons select:focus {
  outline: none;
  border-color: #667eea;
}

.btn-clear {
  padding: 10px 20px;
  background: #f8f9fa;
  border: 2px solid #e0e0e0;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s;
}

.btn-clear:hover {
  background: #e9ecef;
  border-color: #adb5bd;
}

.projects-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 25px;
}

@media (max-width: 768px) {
  .projects-grid {
    grid-template-columns: 1fr;
  }
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  color: #666;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.empty-state {
  text-align: center;
  padding: 80px 20px;
  background: white;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.empty-icon {
  font-size: 5rem;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-state h3 {
  color: #333;
  margin-bottom: 10px;
  font-size: 1.5rem;
}

.empty-state p {
  color: #666;
  margin-bottom: 25px;
}
EOF

# 5. Crear ProjectCard.jsx
echo "📄 Creando ProjectCard.jsx..."
cat > src/components/projects/ProjectCard.jsx << 'EOF'
import './ProjectCard.css';

export default function ProjectCard({ project, onClick }) {
  const getStatusColor = (status) => {
    const colors = {
      'INICIACION': '#6c757d',
      'PLANIFICACION': '#17a2b8',
      'EJECUCION': '#28a745',
      'MONITOREO': '#ffc107',
      'CIERRE': '#007bff',
      'PAUSADO': '#fd7e14',
      'CANCELADO': '#dc3545'
    };
    return colors[status] || '#6c757d';
  };

  const getPriorityColor = (priority) => {
    const colors = {
      'BAJA': '#28a745',
      'MEDIA': '#ffc107',
      'ALTA': '#fd7e14',
      'CRITICA': '#dc3545'
    };
    return colors[priority] || '#6c757d';
  };

  const getProgressColor = (percentage) => {
    if (percentage >= 70) return '#28a745';
    if (percentage >= 40) return '#ffc107';
    return '#dc3545';
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('es-MX', { year: 'numeric', month: 'short', day: 'numeric' });
  };

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN',
      minimumFractionDigits: 0
    }).format(amount);
  };

  return (
    <div className="project-card" onClick={onClick}>
      <div className="card-header">
        <div className="card-title-section">
          <h3 className="card-code">{project.code}</h3>
          <h2 className="card-title">{project.name}</h2>
        </div>
        <div className="card-badges">
          <span 
            className="badge badge-status" 
            style={{ backgroundColor: getStatusColor(project.status) }}
          >
            {project.status_display}
          </span>
          <span 
            className="badge badge-priority" 
            style={{ backgroundColor: getPriorityColor(project.priority) }}
          >
            {project.priority_display}
          </span>
        </div>
      </div>

      <p className="card-description">{project.description}</p>

      <div className="card-info">
        <div className="info-item">
          <span className="info-label">Director:</span>
          <span className="info-value">{project.director_name}</span>
        </div>
        <div className="info-item">
          <span className="info-label">Categoría:</span>
          <span className="info-value">{project.category_name}</span>
        </div>
      </div>

      <div className="card-dates">
        <div className="date-item">
          <span className="date-label">Inicio:</span>
          <span className="date-value">{formatDate(project.planned_start_date)}</span>
        </div>
        <div className="date-item">
          <span className="date-label">Fin:</span>
          <span className="date-value">{formatDate(project.planned_end_date)}</span>
        </div>
      </div>

      <div className="card-progress">
        <div className="progress-header">
          <span className="progress-label">Progreso</span>
          <span className="progress-percentage">{project.completion_percentage}%</span>
        </div>
        <div className="progress-bar">
          <div 
            className="progress-fill" 
            style={{ 
              width: `${project.completion_percentage}%`,
              backgroundColor: getProgressColor(project.completion_percentage)
            }}
          ></div>
        </div>
      </div>

      <div className="card-budget">
        <div className="budget-item">
          <span className="budget-label">Presupuesto:</span>
          <span className="budget-value">{formatCurrency(project.planned_budget)}</span>
        </div>
        <div className="budget-item">
          <span className="budget-label">Ejecutado:</span>
          <span className="budget-value">{formatCurrency(project.actual_budget)}</span>
        </div>
      </div>

      {project.is_overdue && (
        <div className="card-warning">
          ⚠️ Proyecto retrasado
        </div>
      )}
    </div>
  );
}
EOF

# 6. Crear ProjectCard.css
echo "🎨 Creando ProjectCard.css..."
cat > src/components/projects/ProjectCard.css << 'EOF'
.project-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
  border: 2px solid transparent;
}

.project-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border-color: #667eea;
}

.card-header {
  margin-bottom: 15px;
}

.card-title-section {
  margin-bottom: 10px;
}

.card-code {
  font-size: 0.85rem;
  color: #667eea;
  font-weight: 600;
  margin: 0 0 5px 0;
  text-transform: uppercase;
}

.card-title {
  font-size: 1.3rem;
  color: #333;
  margin: 0;
  line-height: 1.3;
}

.card-badges {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  color: white;
}

.card-description {
  color: #666;
  font-size: 0.95rem;
  line-height: 1.5;
  margin: 15px 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin: 15px 0;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 8px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  font-size: 0.9rem;
}

.info-label {
  color: #666;
  font-weight: 500;
}

.info-value {
  color: #333;
  font-weight: 600;
}

.card-dates {
  display: flex;
  justify-content: space-between;
  margin: 15px 0;
  padding: 10px 0;
  border-top: 1px solid #e9ecef;
  border-bottom: 1px solid #e9ecef;
}

.date-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.date-label {
  font-size: 0.8rem;
  color: #666;
}

.date-value {
  font-size: 0.9rem;
  color: #333;
  font-weight: 600;
}

.card-progress {
  margin: 15px 0;
}

.progress-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 0.9rem;
}

.progress-label {
  color: #666;
  font-weight: 500;
}

.progress-percentage {
  color: #333;
  font-weight: 700;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background: #e9ecef;
  border-radius: 10px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  transition: width 0.3s ease;
  border-radius: 10px;
}

.card-budget {
  display: flex;
  justify-content: space-between;
  margin: 15px 0;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 8px;
}

.budget-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.budget-label {
  font-size: 0.8rem;
  color: #666;
}

.budget-value {
  font-size: 1rem;
  color: #333;
  font-weight: 700;
}

.card-warning {
  margin-top: 12px;
  padding: 10px;
  background: #fff3cd;
  border: 1px solid #ffc107;
  border-radius: 6px;
  color: #856404;
  font-size: 0.85rem;
  font-weight: 600;
  text-align: center;
}
EOF

echo ""
echo "✅ Parte 1 del frontend creada (Lista y Cards)"
echo ""
echo "Continúa con el siguiente mensaje para:"
echo "  - ProjectStats component"
echo "  - ProjectDetailPage"
echo "  - ProjectFormPage"
echo "  - Actualización de rutas en App.jsx"