#!/bin/bash

# Script para crear el frontend del módulo de Proyectos - Parte 2
# Ejecutar desde: /Users/edegantea/development/maewalliscorp/gestionproyectos/frontend/

echo "🚀 Creando frontend del módulo de Proyectos - Parte 2..."

# 1. Crear ProjectStats.jsx
echo "📄 Creando ProjectStats.jsx..."
cat > src/components/projects/ProjectStats.jsx << 'EOF'
import './ProjectStats.css';

export default function ProjectStats({ stats }) {
  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount);
  };

  const budgetVariance = stats.total_budget_planned - stats.total_budget_actual;
  const budgetVariancePercentage = stats.total_budget_planned > 0 
    ? ((budgetVariance / stats.total_budget_planned) * 100).toFixed(1)
    : 0;

  return (
    <div className="project-stats">
      <div className="stats-grid">
        <div className="stat-card stat-total">
          <div className="stat-icon">📊</div>
          <div className="stat-content">
            <h3>{stats.total_projects}</h3>
            <p>Total Proyectos</p>
          </div>
        </div>

        <div className="stat-card stat-completion">
          <div className="stat-icon">✓</div>
          <div className="stat-content">
            <h3>{stats.avg_completion?.toFixed(1)}%</h3>
            <p>Completitud Promedio</p>
          </div>
        </div>

        <div className="stat-card stat-budget">
          <div className="stat-icon">💰</div>
          <div className="stat-content">
            <h3>{formatCurrency(stats.total_budget_planned)}</h3>
            <p>Presupuesto Total</p>
          </div>
        </div>

        <div className="stat-card stat-overdue">
          <div className="stat-icon">⚠️</div>
          <div className="stat-content">
            <h3>{stats.overdue_projects}</h3>
            <p>Proyectos Retrasados</p>
          </div>
        </div>
      </div>

      <div className="stats-details">
        <div className="detail-section">
          <h4>Por Estado</h4>
          <div className="status-list">
            {Object.entries(stats.by_status || {}).map(([status, count]) => (
              <div key={status} className="status-item">
                <span className="status-name">{status}</span>
                <span className="status-count">{count}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="detail-section">
          <h4>Por Prioridad</h4>
          <div className="priority-list">
            {Object.entries(stats.by_priority || {}).map(([priority, count]) => (
              <div key={priority} className="priority-item">
                <span className="priority-name">{priority}</span>
                <span className="priority-count">{count}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="detail-section">
          <h4>Presupuesto</h4>
          <div className="budget-details">
            <div className="budget-row">
              <span>Planificado:</span>
              <strong>{formatCurrency(stats.total_budget_planned)}</strong>
            </div>
            <div className="budget-row">
              <span>Ejecutado:</span>
              <strong>{formatCurrency(stats.total_budget_actual)}</strong>
            </div>
            <div className="budget-row budget-variance">
              <span>Variación:</span>
              <strong className={budgetVariance >= 0 ? 'positive' : 'negative'}>
                {budgetVariance >= 0 ? '+' : ''}{formatCurrency(budgetVariance)} ({budgetVariancePercentage}%)
              </strong>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
EOF

# 2. Crear ProjectStats.css
echo "🎨 Creando ProjectStats.css..."
cat > src/components/projects/ProjectStats.css << 'EOF'
.project-stats {
  background: white;
  border-radius: 10px;
  padding: 25px;
  margin-bottom: 30px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 20px;
  border-radius: 10px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  transition: transform 0.3s;
}

.stat-card:hover {
  transform: translateY(-3px);
}

.stat-total {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.stat-completion {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  color: white;
}

.stat-budget {
  background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%);
  color: white;
}

.stat-overdue {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
  color: white;
}

.stat-icon {
  font-size: 2.5rem;
  opacity: 0.9;
}

.stat-content h3 {
  font-size: 2rem;
  margin: 0 0 5px 0;
  font-weight: 700;
}

.stat-content p {
  margin: 0;
  font-size: 0.9rem;
  opacity: 0.9;
}

.stats-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 25px;
  padding-top: 20px;
  border-top: 2px solid #e9ecef;
}

.detail-section h4 {
  color: #333;
  margin: 0 0 15px 0;
  font-size: 1.1rem;
}

.status-list, .priority-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.status-item, .priority-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  background: #f8f9fa;
  border-radius: 6px;
  font-size: 0.9rem;
}

.status-name, .priority-name {
  color: #666;
}

.status-count, .priority-count {
  font-weight: 700;
  color: #333;
  background: white;
  padding: 4px 12px;
  border-radius: 20px;
}

.budget-details {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.budget-row {
  display: flex;
  justify-content: space-between;
  padding: 10px;
  background: #f8f9fa;
  border-radius: 6px;
  font-size: 0.9rem;
}

.budget-row span {
  color: #666;
}

.budget-row strong {
  color: #333;
}

.budget-variance {
  background: #e7f5ff;
  border: 1px solid #339af0;
}

.budget-variance strong.positive {
  color: #28a745;
}

.budget-variance strong.negative {
  color: #dc3545;
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr 1fr;
  }
  
  .stats-details {
    grid-template-columns: 1fr;
  }
}
EOF

# 3. Crear ProjectDetailPage.jsx
echo "📄 Creando ProjectDetailPage.jsx..."
cat > src/pages/projects/ProjectDetailPage.jsx << 'EOF'
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useProjectsStore } from '../../stores/projectsStore';
import './ProjectDetailPage.css';

export default function ProjectDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { currentProject, loading, fetchProject, deleteProject, updateProgress } = useProjectsStore();
  
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [editingProgress, setEditingProgress] = useState(false);
  const [newProgress, setNewProgress] = useState(0);

  useEffect(() => {
    loadProject();
  }, [id]);

  const loadProject = async () => {
    try {
      await fetchProject(id);
    } catch (error) {
      console.error('Error loading project:', error);
      navigate('/projects');
    }
  };

  const handleDelete = async () => {
    try {
      await deleteProject(id);
      navigate('/projects');
    } catch (error) {
      console.error('Error deleting project:', error);
      alert('Error al eliminar el proyecto');
    }
  };

  const handleUpdateProgress = async () => {
    try {
      await updateProgress(id, newProgress);
      setEditingProgress(false);
    } catch (error) {
      console.error('Error updating progress:', error);
      alert('Error al actualizar el progreso');
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('es-MX', { 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
  };

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(amount);
  };

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

  if (loading || !currentProject) {
    return (
      <div className="loading-page">
        <div className="spinner"></div>
        <p>Cargando proyecto...</p>
      </div>
    );
  }

  return (
    <div className="project-detail-page">
      <header className="detail-header">
        <div className="header-content">
          <div className="header-left">
            <button onClick={() => navigate('/projects')} className="btn-back">
              ← Volver
            </button>
            <div className="header-info">
              <h1>{currentProject.name}</h1>
              <p className="project-code">{currentProject.code}</p>
            </div>
          </div>
          <div className="header-actions">
            <button 
              onClick={() => navigate(`/projects/${id}/edit`)} 
              className="btn-edit"
            >
              ✏️ Editar
            </button>
            <button 
              onClick={() => setShowDeleteConfirm(true)} 
              className="btn-delete"
            >
              🗑️ Eliminar
            </button>
          </div>
        </div>
      </header>

      <main className="detail-main">
        <div className="detail-grid">
          {/* Columna izquierda */}
          <div className="detail-column">
            {/* Información general */}
            <div className="detail-section">
              <h2>Información General</h2>
              <div className="info-grid">
                <div className="info-item">
                  <span className="label">Estado:</span>
                  <span 
                    className="badge" 
                    style={{ backgroundColor: getStatusColor(currentProject.status) }}
                  >
                    {currentProject.status_display}
                  </span>
                </div>
                <div className="info-item">
                  <span className="label">Prioridad:</span>
                  <span 
                    className="badge" 
                    style={{ backgroundColor: getPriorityColor(currentProject.priority) }}
                  >
                    {currentProject.priority_display}
                  </span>
                </div>
                <div className="info-item">
                  <span className="label">Director:</span>
                  <span className="value">
                    {currentProject.director?.first_name} {currentProject.director?.last_name}
                  </span>
                </div>
                {currentProject.sponsor && (
                  <div className="info-item">
                    <span className="label">Patrocinador:</span>
                    <span className="value">
                      {currentProject.sponsor?.first_name} {currentProject.sponsor?.last_name}
                    </span>
                  </div>
                )}
                <div className="info-item">
                  <span className="label">Categoría:</span>
                  <span className="value">{currentProject.category?.name}</span>
                </div>
              </div>

              <div className="description-section">
                <h3>Descripción</h3>
                <p>{currentProject.description}</p>
              </div>
            </div>

            {/* Fechas */}
            <div className="detail-section">
              <h2>📅 Fechas</h2>
              <div className="dates-grid">
                <div className="date-card">
                  <span className="date-label">Inicio Planificado</span>
                  <span className="date-value">{formatDate(currentProject.planned_start_date)}</span>
                </div>
                <div className="date-card">
                  <span className="date-label">Fin Planificado</span>
                  <span className="date-value">{formatDate(currentProject.planned_end_date)}</span>
                </div>
                {currentProject.actual_start_date && (
                  <div className="date-card">
                    <span className="date-label">Inicio Real</span>
                    <span className="date-value">{formatDate(currentProject.actual_start_date)}</span>
                  </div>
                )}
                {currentProject.actual_end_date && (
                  <div className="date-card">
                    <span className="date-label">Fin Real</span>
                    <span className="date-value">{formatDate(currentProject.actual_end_date)}</span>
                  </div>
                )}
              </div>
              <div className="duration-info">
                <p><strong>Duración planificada:</strong> {currentProject.duration_days} días</p>
                {currentProject.actual_duration_days && (
                  <p><strong>Duración real:</strong> {currentProject.actual_duration_days} días</p>
                )}
              </div>
            </div>

            {/* Presupuesto */}
            <div className="detail-section">
              <h2>💰 Presupuesto</h2>
              <div className="budget-grid">
                <div className="budget-card">
                  <span className="budget-label">Planificado</span>
                  <span className="budget-value">{formatCurrency(currentProject.planned_budget)}</span>
                </div>
                <div className="budget-card">
                  <span className="budget-label">Ejecutado</span>
                  <span className="budget-value">{formatCurrency(currentProject.actual_budget)}</span>
                </div>
                <div className="budget-card variance">
                  <span className="budget-label">Variación</span>
                  <span className={`budget-value ${currentProject.budget_variance >= 0 ? 'positive' : 'negative'}`}>
                    {formatCurrency(currentProject.budget_variance)} ({currentProject.budget_variance_percentage}%)
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* Columna derecha */}
          <div className="detail-column">
            {/* Progreso */}
            <div className="detail-section progress-section">
              <div className="section-header">
                <h2>📊 Progreso</h2>
                <button 
                  onClick={() => {
                    setNewProgress(currentProject.completion_percentage);
                    setEditingProgress(true);
                  }}
                  className="btn-small"
                >
                  Actualizar
                </button>
              </div>
              
              {editingProgress ? (
                <div className="progress-editor">
                  <input
                    type="range"
                    min="0"
                    max="100"
                    value={newProgress}
                    onChange={(e) => setNewProgress(parseInt(e.target.value))}
                  />
                  <div className="progress-value">{newProgress}%</div>
                  <div className="progress-actions">
                    <button onClick={handleUpdateProgress} className="btn-save">
                      Guardar
                    </button>
                    <button onClick={() => setEditingProgress(false)} className="btn-cancel">
                      Cancelar
                    </button>
                  </div>
                </div>
              ) : (
                <div className="progress-display">
                  <div className="progress-circle">
                    <svg viewBox="0 0 100 100">
                      ircle cx="50" cy="50" r="45" fill="none" stroke="#e9ecef" strokeWidth="10" />
                      ircle 
                        cx="50" 
                        cy="50" 
                        r="45" 
                        fill="none" 
                        stroke="#667eea" 
                        strokeWidth="10"
                        strokeDasharray={`${currentProject.completion_percentage * 2.83} 283`}
                        strokeLinecap="round"
                        transform="rotate(-90 50 50)"
                      />
                      <text x="50" y="50" textAnchor="middle" dy="7" fontSize="20" fill="#333">
                        {currentProject.completion_percentage}%
                      </text>
                    </svg>
                  </div>
                </div>
              )}
            </div>

            {/* Objetivos */}
            {currentProject.objectives && (
              <div className="detail-section">
                <h2>🎯 Objetivos</h2>
                <div className="text-content">
                  {currentProject.objectives}
                </div>
              </div>
            )}

            {/* Alcance */}
            {currentProject.scope && (
              <div className="detail-section">
                <h2>📋 Alcance</h2>
                <div className="text-content">
                  {currentProject.scope}
                </div>
              </div>
            )}

            {/* Entregables */}
            {currentProject.deliverables && (
              <div className="detail-section">
                <h2>📦 Entregables</h2>
                <div className="text-content">
                  {currentProject.deliverables}
                </div>
              </div>
            )}

            {/* Riesgos */}
            {currentProject.identified_risks && (
              <div className="detail-section risk-section">
                <h2>⚠️ Riesgos Identificados</h2>
                <div className="text-content">
                  {currentProject.identified_risks}
                </div>
              </div>
            )}

            {/* Hitos */}
            {currentProject.milestones && currentProject.milestones.length > 0 && (
              <div className="detail-section">
                <h2>🏁 Hitos</h2>
                <div className="milestones-list">
                  {currentProject.milestones.map(milestone => (
                    <div key={milestone.id} className={`milestone-item ${milestone.is_completed ? 'completed' : ''}`}>
                      <div className="milestone-icon">
                        {milestone.is_completed ? '✅' : '⭕'}
                      </div>
                      <div className="milestone-content">
                        <h4>{milestone.name}</h4>
                        <p className="milestone-date">
                          Planificado: {formatDate(milestone.planned_date)}
                          {milestone.actual_date && ` | Completado: ${formatDate(milestone.actual_date)}`}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </main>

      {/* Modal de confirmación de eliminación */}
      {showDeleteConfirm && (
        <div className="modal-overlay" onClick={() => setShowDeleteConfirm(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h2>¿Eliminar Proyecto?</h2>
            <p>Esta acción no se puede deshacer. ¿Estás seguro de que deseas eliminar este proyecto?</p>
            <div className="modal-actions">
              <button onClick={() => setShowDeleteConfirm(false)} className="btn-cancel">
                Cancelar
              </button>
              <button onClick={handleDelete} className="btn-delete">
                Eliminar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
EOF

# Continuará en el siguiente bloque...
echo "📄 Creando ProjectDetailPage.css..."
cat > src/pages/projects/ProjectDetailPage.css << 'EOF'
.project-detail-page {
  min-height: 100vh;
  background-color: #f5f7fa;
}

.detail-header {
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

.header-left {
  display: flex;
  align-items: center;
  gap: 20px;
}

.btn-back {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 1px solid white;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-back:hover {
  background: rgba(255, 255, 255, 0.3);
}

.header-info h1 {
  margin: 0 0 5px 0;
  font-size: 2rem;
}

.project-code {
  margin: 0;
  opacity: 0.9;
  font-size: 0.9rem;
  text-transform: uppercase;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.btn-edit, .btn-delete {
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 0.95rem;
}

.btn-edit {
  background: white;
  color: #667eea;
}

.btn-edit:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.btn-delete {
  background: #dc3545;
  color: white;
}

.btn-delete:hover {
  background: #c82333;
}

.detail-main {
  max-width: 1400px;
  margin: 0 auto;
  padding: 30px 20px;
}

.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 30px;
}

@media (max-width: 1024px) {
  .detail-grid {
    grid-template-columns: 1fr;
  }
}

.detail-section {
  background: white;
  border-radius: 10px;
  padding: 25px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  margin-bottom: 20px;
}

.detail-section h2 {
  color: #333;
  margin: 0 0 20px 0;
  font-size: 1.4rem;
  border-bottom: 2px solid #e9ecef;
  padding-bottom: 10px;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin-bottom: 20px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.label {
  color: #666;
  font-size: 0.85rem;
  font-weight: 500;
}

.value {
  color: #333;
  font-size: 1rem;
  font-weight: 600;
}

.badge {
  display: inline-block;
  padding: 5px 15px;
  border-radius: 20px;
  color: white;
  font-size: 0.85rem;
  font-weight: 600;
}

.description-section {
  margin-top: 20px;
}

.description-section h3 {
  color: #333;
  margin: 0 0 10px 0;
  font-size: 1.1rem;
}

.description-section p {
  color: #666;
  line-height: 1.6;
}

.dates-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin-bottom: 15px;
}

.date-card {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
}

.date-label {
  color: #666;
  font-size: 0.85rem;
}

.date-value {
  color: #333;
  font-size: 1rem;
  font-weight: 600;
}

.duration-info {
  padding: 15px;
  background: #e7f5ff;
  border-left: 4px solid #339af0;
  border-radius: 4px;
}

.duration-info p {
  margin: 5px 0;
  color: #333;
}

.budget-grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 15px;
}

.budget-card {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
  text-align: center;
}

.budget-card.variance {
  background: linear-gradient(135deg, #e7f5ff 0%, #d0ebff 100%);
}

.budget-label {
  color: #666;
  font-size: 0.85rem;
}

.budget-value {
  color: #333;
  font-size: 1.2rem;
  font-weight: 700;
}

.budget-value.positive {
  color: #28a745;
}

.budget-value.negative {
  color: #dc3545;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-header h2 {
  margin: 0;
  border: none;
  padding: 0;
}

.btn-small {
  padding: 6px 15px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-small:hover {
  background: #5568d3;
}

.progress-display {
  display: flex;
  justify-content: center;
  padding: 20px;
}

.progress-circle {
  width: 200px;
  height: 200px;
}

.progress-circle svg {
  width: 100%;
  height: 100%;
}

.progress-editor {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.progress-editor input[type="range"] {
  width: 100%;
  height: 8px;
  border-radius: 5px;
  background: #e9ecef;
  outline: none;
}

.progress-value {
  text-align: center;
  font-size: 2rem;
  font-weight: 700;
  color: #667eea;
}

.progress-actions {
  display: flex;
  gap: 10px;
  justify-content: center;
}

.btn-save {
  padding: 10px 25px;
  background: #28a745;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
}

.btn-save:hover {
  background: #218838;
}

.btn-cancel {
  padding: 10px 25px;
  background: #6c757d;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
}

.btn-cancel:hover {
  background: #5a6268;
}

.text-content {
  color: #666;
  line-height: 1.8;
  white-space: pre-line;
}

.risk-section {
  background: #fff3cd;
  border-left: 4px solid #ffc107;
}

.milestones-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.milestone-item {
  display: flex;
  gap: 15px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid #667eea;
}

.milestone-item.completed {
  background: #d4edda;
  border-left-color: #28a745;
}

.milestone-icon {
  font-size: 1.5rem;
}

.milestone-content h4 {
  margin: 0 0 5px 0;
  color: #333;
}

.milestone-date {
  margin: 0;
  color: #666;
  font-size: 0.85rem;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 30px;
  border-radius: 10px;
  max-width: 500px;
  width: 90%;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
}

.modal-content h2 {
  color: #333;
  margin: 0 0 15px 0;
}

.modal-content p {
  color: #666;
  margin: 0 0 25px 0;
  line-height: 1.6;
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.loading-page {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  color: #666;
}

.spinner {
  width: 60px;
  height: 60px;
  border: 5px solid #f3f3f3;
  border-top: 5px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
EOF

echo ""
echo "✅ Parte 2 del frontend creada (Stats y Detail)"
echo ""
echo "Continúa con el siguiente mensaje para:"
echo "  - ProjectFormPage (crear/editar)"
echo "  - Actualización de App.jsx y DashboardPage"
echo "  - Configuración final"