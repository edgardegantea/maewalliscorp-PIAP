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
