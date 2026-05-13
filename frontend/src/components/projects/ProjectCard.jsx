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
