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
