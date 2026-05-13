import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useProjectsStore } from '../../stores/projectsStore';
import BacklogList from '../../components/projects/BacklogList';
import SprintList from '../../components/projects/SprintList';
import KanbanBoard from '../../components/projects/KanbanBoard';
import RiskList from '../../components/projects/RiskList';
import IncidentList from '../../components/projects/IncidentList';
import MemberList from '../../components/projects/MemberList';
import DocumentList from '../../components/projects/DocumentList';
import ReportList from '../../components/projects/ReportList';
import LegalDocumentList from '../../components/projects/LegalDocumentList';
import ClientDataTab from '../../components/projects/ClientDataTab';
import './ProjectDetailPage.css';

export default function ProjectDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { currentProject, loading, fetchProject, deleteProject, updateProgress } = useProjectsStore();
  
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [editingProgress, setEditingProgress] = useState(false);
  const [newProgress, setNewProgress] = useState(0);
  const [activeTab, setActiveTab] = useState('resumen');

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
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <header className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-30">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-6">
          <div className="flex flex-col md:flex-row md:justify-between md:items-start gap-4 mb-6">
            <div className="flex items-start gap-4">
              <button 
                onClick={() => navigate('/projects')} 
                className="mt-1 text-gray-400 hover:text-gray-700 transition-colors p-1.5 rounded-md hover:bg-gray-100"
                title="Volver"
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                </svg>
              </button>
              <div>
                <h1 className="text-3xl font-bold text-gray-900 m-0 leading-tight">{currentProject.name}</h1>
                <p className="text-gray-500 font-mono text-sm mt-1 mb-0 flex items-center gap-2">
                  <span className="bg-gray-100 text-gray-600 px-2 py-0.5 rounded text-xs">{currentProject.code}</span>
                  <span>|</span>
                  <span>{currentProject.category?.name}</span>
                </p>
              </div>
            </div>
            
            <div className="flex items-center gap-3 self-start">
              <button 
                onClick={() => navigate(`/projects/${id}/edit`)} 
                className="flex items-center gap-2 px-4 py-2 bg-white border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium text-sm shadow-sm"
              >
                ✏️ Editar
              </button>
              <button 
                onClick={() => setShowDeleteConfirm(true)} 
                className="flex items-center gap-2 px-4 py-2 bg-white border border-red-200 text-red-600 rounded-lg hover:bg-red-50 transition-colors font-medium text-sm shadow-sm"
              >
                🗑️ Eliminar
              </button>
            </div>
          </div>
          
          <div className="flex overflow-x-auto hide-scrollbar gap-1">
            {[
              { id: 'resumen', label: 'Resumen', icon: '📊' },
              { id: 'backlog', label: 'Backlog', icon: '📋' },
              { id: 'sprints', label: 'Sprints', icon: '🏃' },
              { id: 'kanban', label: 'Kanban', icon: '🚥' },
              { id: 'equipo', label: 'Equipo', icon: '👥' },
              { id: 'riesgos', label: 'Riesgos', icon: '⚠️' },
              { id: 'incidencias', label: 'Incidencias', icon: '🐛' },
              { id: 'documentos', label: 'Docs', icon: '📁' },
              { id: 'cliente', label: 'Cliente', icon: '🏢' },
              { id: 'legal', label: 'Legal', icon: '⚖️' },
              { id: 'reportes', label: 'Reportes', icon: '📈' }
            ].map((tab) => (
              <button 
                key={tab.id}
                className={`flex items-center gap-2 px-4 py-3 whitespace-nowrap border-b-2 font-medium text-sm transition-colors ${
                  activeTab === tab.id 
                    ? 'border-blue-600 text-blue-700 bg-blue-50/50' 
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 hover:bg-gray-50'
                }`} 
                onClick={() => setActiveTab(tab.id)}
              >
                <span>{tab.icon}</span> {tab.label}
              </button>
            ))}
          </div>
        </div>
      </header>

      <main className="flex-grow max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'backlog' && <BacklogList projectId={id} />}
        {activeTab === 'sprints' && <SprintList projectId={id} />}
        {activeTab === 'kanban' && <KanbanBoard projectId={id} />}
        {activeTab === 'equipo' && <MemberList projectId={id} />}
        {activeTab === 'riesgos' && <RiskList projectId={id} />}
        {activeTab === 'incidencias' && <IncidentList projectId={id} />}
        {activeTab === 'documentos' && <DocumentList projectId={id} />}
        {activeTab === 'cliente' && <ClientDataTab projectId={id} initialData={currentProject} onUpdate={fetchProject} />}
        {activeTab === 'legal' && <LegalDocumentList projectId={id} />}
        {activeTab === 'reportes' && <ReportList projectId={id} />}
        {activeTab === 'resumen' && (
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
                      <circle cx="50" cy="50" r="45" fill="none" stroke="#e9ecef" strokeWidth="10" />
                      <circle 
                        cx="50" 
                        cy="50" 
                        r="45" 
                        fill="none" 
                        stroke="#1e40af" 
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
        )}
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
