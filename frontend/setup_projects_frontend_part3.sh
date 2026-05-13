#!/bin/bash

# Script para crear el frontend del módulo de Proyectos - Parte 3 Final
# Ejecutar desde: /Users/edegantea/development/maewalliscorp/gestionproyectos/frontend/

echo "🚀 Creando frontend del módulo de Proyectos - Parte 3 Final..."

# 1. Crear ProjectFormPage.jsx
echo "📄 Creando ProjectFormPage.jsx..."
cat > src/pages/projects/ProjectFormPage.jsx << 'EOF'
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useProjectsStore } from '../../stores/projectsStore';
import { useAuthStore } from '../../stores/authStore';
import './ProjectFormPage.css';

export default function ProjectFormPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEditMode = !!id;
  const user = useAuthStore(state => state.user);
  
  const { 
    currentProject, 
    categories, 
    loading, 
    fetchProject, 
    fetchCategories,
    createProject, 
    updateProject 
  } = useProjectsStore();

  const [formData, setFormData] = useState({
    code: '',
    name: '',
    description: '',
    category: '',
    status: 'INICIACION',
    priority: 'MEDIA',
    director: user?.id || '',
    sponsor: '',
    planned_start_date: '',
    planned_end_date: '',
    actual_start_date: '',
    actual_end_date: '',
    planned_budget: '',
    actual_budget: '0',
    objectives: '',
    scope: '',
    deliverables: '',
    identified_risks: '',
    constraints: '',
    assumptions: '',
    completion_percentage: 0,
    is_active: true,
    notes: ''
  });

  const [errors, setErrors] = useState({});
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    loadInitialData();
  }, [id]);

  const loadInitialData = async () => {
    try {
      await fetchCategories();
      
      if (isEditMode) {
        const project = await fetchProject(id);
        setFormData({
          code: project.code || '',
          name: project.name || '',
          description: project.description || '',
          category: project.category?.id || '',
          status: project.status || 'INICIACION',
          priority: project.priority || 'MEDIA',
          director: project.director?.id || user?.id || '',
          sponsor: project.sponsor?.id || '',
          planned_start_date: project.planned_start_date || '',
          planned_end_date: project.planned_end_date || '',
          actual_start_date: project.actual_start_date || '',
          actual_end_date: project.actual_end_date || '',
          planned_budget: project.planned_budget || '',
          actual_budget: project.actual_budget || '0',
          objectives: project.objectives || '',
          scope: project.scope || '',
          deliverables: project.deliverables || '',
          identified_risks: project.identified_risks || '',
          constraints: project.constraints || '',
          assumptions: project.assumptions || '',
          completion_percentage: project.completion_percentage || 0,
          is_active: project.is_active ?? true,
          notes: project.notes || ''
        });
      }
    } catch (error) {
      console.error('Error loading data:', error);
    }
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    
    // Limpiar error del campo
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: null }));
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.code.trim()) newErrors.code = 'El código es requerido';
    if (!formData.name.trim()) newErrors.name = 'El nombre es requerido';
    if (!formData.description.trim()) newErrors.description = 'La descripción es requerida';
    if (!formData.category) newErrors.category = 'La categoría es requerida';
    if (!formData.director) newErrors.director = 'El director es requerido';
    if (!formData.planned_start_date) newErrors.planned_start_date = 'La fecha de inicio es requerida';
    if (!formData.planned_end_date) newErrors.planned_end_date = 'La fecha de fin es requerida';
    if (!formData.planned_budget) newErrors.planned_budget = 'El presupuesto es requerido';
    if (!formData.objectives.trim()) newErrors.objectives = 'Los objetivos son requeridos';
    if (!formData.scope.trim()) newErrors.scope = 'El alcance es requerido';

    // Validar fechas
    if (formData.planned_start_date && formData.planned_end_date) {
      if (new Date(formData.planned_end_date) < new Date(formData.planned_start_date)) {
        newErrors.planned_end_date = 'La fecha de fin debe ser posterior a la de inicio';
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      window.scrollTo({ top: 0, behavior: 'smooth' });
      return;
    }

    setSubmitting(true);

    try {
      // Preparar datos para enviar
      const submitData = {
        ...formData,
        category: parseInt(formData.category),
        director: parseInt(formData.director),
        sponsor: formData.sponsor ? parseInt(formData.sponsor) : null,
        planned_budget: parseFloat(formData.planned_budget),
        actual_budget: parseFloat(formData.actual_budget || 0),
        completion_percentage: parseInt(formData.completion_percentage),
        actual_start_date: formData.actual_start_date || null,
        actual_end_date: formData.actual_end_date || null
      };

      if (isEditMode) {
        await updateProject(id, submitData);
      } else {
        await createProject(submitData);
      }

      navigate('/projects');
    } catch (error) {
      console.error('Error saving project:', error);
      if (error.response?.data) {
        setErrors(error.response.data);
      } else {
        setErrors({ general: 'Error al guardar el proyecto. Intenta nuevamente.' });
      }
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="project-form-page">
      <header className="form-header">
        <div className="header-content">
          <div className="header-left">
            <button onClick={() => navigate('/projects')} className="btn-back">
              ← Volver
            </button>
            <h1>{isEditMode ? 'Editar Proyecto' : 'Nuevo Proyecto'}</h1>
          </div>
        </div>
      </header>

      <main className="form-main">
        <form onSubmit={handleSubmit} className="project-form">
          {errors.general && (
            <div className="error-banner">
              <span className="error-icon">⚠️</span>
              {errors.general}
            </div>
          )}

          {/* Sección: Información Básica */}
          <div className="form-section">
            <h2 className="section-title">📋 Información Básica</h2>
            
            <div className="form-row">
              <div className="form-group">
                <label  htmlFor="code">Código del Proyecto *</label>
                <input
                  id="code"
                  name="code"
                  type="text"
                  value={formData.code}
                  onChange={handleChange}
                  placeholder="Ej: PIAP-2026-001"
                  disabled={submitting}
                />
                {errors.code && <span className="error-text">{errors.code}</span>}
              </div>

              <div className="form-group">
                <label  htmlFor="category">Categoría *</label>
                <select
                  id="category"
                  name="category"
                  value={formData.category}
                  onChange={handleChange}
                  disabled={submitting}
                >
                  <option value="">Selecciona una categoría</option>
                  {categories.map(cat => (
                    <option key={cat.id} value={cat.id}>{cat.name}</option>
                  ))}
                </select>
                {errors.category && <span className="error-text">{errors.category}</span>}
              </div>
            </div>

            <div className="form-group">
              <label  htmlFor="name">Nombre del Proyecto *</label>
              <input
                id="name"
                name="name"
                type="text"
                value={formData.name}
                onChange={handleChange}
                placeholder="Nombre descriptivo del proyecto"
                disabled={submitting}
              />
              {errors.name && <span className="error-text">{errors.name}</span>}
            </div>

            <div className="form-group">
              <label  htmlFor="description">Descripción *</label>
              <textarea
                id="description"
                name="description"
                value={formData.description}
                onChange={handleChange}
                placeholder="Describe el proyecto de manera general"
                rows="4"
                disabled={submitting}
              />
              {errors.description && <span className="error-text">{errors.description}</span>}
            </div>
          </div>

          {/* Sección: Clasificación */}
          <div className="form-section">
            <h2 className="section-title">🏷️ Clasificación</h2>
            
            <div className="form-row">
              <div className="form-group">
                <label  htmlFor="status">Estado</label>
                <select
                  id="status"
                  name="status"
                  value={formData.status}
                  onChange={handleChange}
                  disabled={submitting}
                >
                  <option value="INICIACION">Iniciación</option>
                  <option value="PLANIFICACION">Planificación</option>
                  <option value="EJECUCION">Ejecución</option>
                  <option value="MONITOREO">Monitoreo y Control</option>
                  <option value="CIERRE">Cierre</option>
                  <option value="PAUSADO">Pausado</option>
                  <option value="CANCELADO">Cancelado</option>
                </select>
              </div>

              <div className="form-group">
                <label  htmlFor="priority">Prioridad</label>
                <select
                  id="priority"
                  name="priority"
                  value={formData.priority}
                  onChange={handleChange}
                  disabled={submitting}
                >
                  <option value="BAJA">Baja</option>
                  <option value="MEDIA">Media</option>
                  <option value="ALTA">Alta</option>
                  <option value="CRITICA">Crítica</option>
                </select>
              </div>

              <div className="form-group">
                <label  htmlFor="completion_percentage">% Completitud</label>
                <input
                  id="completion_percentage"
                  name="completion_percentage"
                  type="number"
                  min="0"
                  max="100"
                  value={formData.completion_percentage}
                  onChange={handleChange}
                  disabled={submitting}
                />
              </div>
            </div>
          </div>

          {/* Sección: Fechas */}
          <div className="form-section">
            <h2 className="section-title">📅 Fechas</h2>
            
            <div className="form-row">
              <div className="form-group">
                <label  htmlFor="planned_start_date">Fecha de Inicio Planificada *</label>
                <input
                  id="planned_start_date"
                  name="planned_start_date"
                  type="date"
                  value={formData.planned_start_date}
                  onChange={handleChange}
                  disabled={submitting}
                />
                {errors.planned_start_date && <span className="error-text">{errors.planned_start_date}</span>}
              </div>

              <div className="form-group">
                <label  htmlFor="planned_end_date">Fecha de Fin Planificada *</label>
                <input
                  id="planned_end_date"
                  name="planned_end_date"
                  type="date"
                  value={formData.planned_end_date}
                  onChange={handleChange}
                  disabled={submitting}
                />
                {errors.planned_end_date && <span className="error-text">{errors.planned_end_date}</span>}
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label  htmlFor="actual_start_date">Fecha de Inicio Real</label>
                <input
                  id="actual_start_date"
                  name="actual_start_date"
                  type="date"
                  value={formData.actual_start_date}
                  onChange={handleChange}
                  disabled={submitting}
                />
              </div>

              <div className="form-group">
                <label  htmlFor="actual_end_date">Fecha de Fin Real</label>
                <input
                  id="actual_end_date"
                  name="actual_end_date"
                  type="date"
                  value={formData.actual_end_date}
                  onChange={handleChange}
                  disabled={submitting}
                />
              </div>
            </div>
          </div>

          {/* Sección: Presupuesto */}
          <div className="form-section">
            <h2 className="section-title">💰 Presupuesto</h2>
            
            <div className="form-row">
              <div className="form-group">
                <label  htmlFor="planned_budget">Presupuesto Planificado *</label>
                <input
                  id="planned_budget"
                  name="planned_budget"
                  type="number"
                  step="0.01"
                  value={formData.planned_budget}
                  onChange={handleChange}
                  placeholder="0.00"
                  disabled={submitting}
                />
                {errors.planned_budget && <span className="error-text">{errors.planned_budget}</span>}
              </div>

              <div className="form-group">
                <label  htmlFor="actual_budget">Presupuesto Ejecutado</label>
                <input
                  id="actual_budget"
                  name="actual_budget"
                  type="number"
                  step="0.01"
                  value={formData.actual_budget}
                  onChange={handleChange}
                  placeholder="0.00"
                  disabled={submitting}
                />
              </div>
            </div>
          </div>

          {/* Sección: Alcance y Objetivos */}
          <div className="form-section">
            <h2 className="section-title">🎯 Alcance y Objetivos</h2>
            
            <div className="form-group">
              <label  htmlFor="objectives">Objetivos del Proyecto *</label>
              <textarea
                id="objectives"
                name="objectives"
                value={formData.objectives}
                onChange={handleChange}
                placeholder="Define los objetivos SMART del proyecto"
                rows="4"
                disabled={submitting}
              />
              {errors.objectives && <span className="error-text">{errors.objectives}</span>}
            </div>

            <div className="form-group">
              <label  htmlFor="scope">Alcance del Proyecto *</label>
              <textarea
                id="scope"
                name="scope"
                value={formData.scope}
                onChange={handleChange}
                placeholder="Define qué está incluido y qué no está incluido en el proyecto"
                rows="4"
                disabled={submitting}
              />
              {errors.scope && <span className="error-text">{errors.scope}</span>}
            </div>

            <div className="form-group">
              <label  htmlFor="deliverables">Entregables Principales</label>
              <textarea
                id="deliverables"
                name="deliverables"
                value={formData.deliverables}
                onChange={handleChange}
                placeholder="Lista los principales entregables del proyecto"
                rows="3"
                disabled={submitting}
              />
            </div>
          </div>

          {/* Sección: Riesgos y Restricciones */}
          <div className="form-section">
            <h2 className="section-title">⚠️ Riesgos y Restricciones</h2>
            
            <div className="form-group">
              <label  htmlFor="identified_risks">Riesgos Identificados</label>
              <textarea
                id="identified_risks"
                name="identified_risks"
                value={formData.identified_risks}
                onChange={handleChange}
                placeholder="Identifica los principales riesgos del proyecto"
                rows="3"
                disabled={submitting}
              />
            </div>

            <div className="form-group">
              <label  htmlFor="constraints">Restricciones</label>
              <textarea
                id="constraints"
                name="constraints"
                value={formData.constraints}
                onChange={handleChange}
                placeholder="Define las restricciones del proyecto (presupuesto, tiempo, recursos, etc.)"
                rows="3"
                disabled={submitting}
              />
            </div>

            <div className="form-group">
              <label  htmlFor="assumptions">Supuestos</label>
              <textarea
                id="assumptions"
                name="assumptions"
                value={formData.assumptions}
                onChange={handleChange}
                placeholder="Lista los supuestos sobre los que se basa el proyecto"
                rows="3"
                disabled={submitting}
              />
            </div>
          </div>

          {/* Sección: Notas Adicionales */}
          <div className="form-section">
            <h2 className="section-title">📝 Notas Adicionales</h2>
            
            <div className="form-group">
              <label  htmlFor="notes">Notas</label>
              <textarea
                id="notes"
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                placeholder="Notas adicionales sobre el proyecto"
                rows="3"
                disabled={submitting}
              />
            </div>

            <div className="form-group checkbox-group">
              <label >
                <input
                  type="checkbox"
                  name="is_active"
                  checked={formData.is_active}
                  onChange={handleChange}
                  disabled={submitting}
                />
                <span>Proyecto activo</span>
              </label>
            </div>
          </div>

          {/* Botones de acción */}
          <div className="form-actions">
            <button
              type="button"
              onClick={() => navigate('/projects')}
              className="btn-cancel"
              disabled={submitting}
            >
              Cancelar
            </button>
            <button
              type="submit"
              className="btn-submit"
              disabled={submitting}
            >
              {submitting ? 'Guardando...' : isEditMode ? 'Actualizar Proyecto' : 'Crear Proyecto'}
            </button>
          </div>
        </form>
      </main>
    </div>
  );
}
EOF

# 2. Crear ProjectFormPage.css
echo "🎨 Creando ProjectFormPage.css..."
cat > src/pages/projects/ProjectFormPage.css << 'EOF'
.project-form-page {
  min-height: 100vh;
  background-color: #f5f7fa;
}

.form-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 25px 0;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.form-header .header-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.form-header .header-left {
  display: flex;
  align-items: center;
  gap: 20px;
}

.form-header h1 {
  margin: 0;
  font-size: 1.8rem;
}

.form-main {
  max-width: 1200px;
  margin: 0 auto;
  padding: 30px 20px;
}

.project-form {
  background: white;
  border-radius: 10px;
  padding: 40px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.error-banner {
  background: #f8d7da;
  border: 1px solid #f5c6cb;
  color: #721c24;
  padding: 15px;
  border-radius: 6px;
  margin-bottom: 30px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.error-icon {
  font-size: 1.5rem;
}

.form-section {
  margin-bottom: 40px;
  padding-bottom: 30px;
  border-bottom: 2px solid #e9ecef;
}

.form-section:last-of-type {
  border-bottom: none;
}

.section-title {
  color: #333;
  font-size: 1.4rem;
  margin: 0 0 25px 0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  color: #333;
  font-weight: 600;
  font-size: 0.95rem;
}

.form-group input,
.form-group select,
.form-group textarea {
  padding: 12px;
  border: 2px solid #e0e0e0;
  border-radius: 6px;
  font-size: 1rem;
  font-family: inherit;
  transition: border-color 0.3s;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #667eea;
}

.form-group input:disabled,
.form-group select:disabled,
.form-group textarea:disabled {
  background-color: #f5f5f5;
  cursor: not-allowed;
  opacity: 0.7;
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
}

.error-text {
  color: #dc3545;
  font-size: 0.85rem;
  font-weight: 500;
}

.checkbox-group {
  flex-direction: row;
  align-items: center;
  gap: 10px;
}

.checkbox-group label {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  font-weight: 500;
}

.checkbox-group input[type="checkbox"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

.form-actions {
  display: flex;
  gap: 15px;
  justify-content: flex-end;
  margin-top: 40px;
  padding-top: 30px;
  border-top: 2px solid #e9ecef;
}

.btn-cancel,
.btn-submit {
  padding: 14px 30px;
  border: none;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-cancel {
  background: #6c757d;
  color: white;
}

.btn-cancel:hover:not(:disabled) {
  background: #5a6268;
}

.btn-submit {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-submit:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.btn-cancel:disabled,
.btn-submit:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

@media (max-width: 768px) {
  .project-form {
    padding: 25px;
  }
  
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .btn-cancel,
  .btn-submit {
    width: 100%;
  }
}
EOF

# 3. Actualizar DashboardPage.jsx para incluir enlace a proyectos
echo "📄 Actualizando DashboardPage.jsx..."
cat > src/pages/DashboardPage.jsx << 'EOF'
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import './DashboardPage.css';

export default function DashboardPage() {
  const navigate = useNavigate();
  const { user, logout } = useAuthStore();

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <div className="dashboard-container">
      <header className="dashboard-header">
        <div className="header-content">
          <h1>PIAP - Dashboard</h1>
          <div className="user-info">
            <button onClick={() => navigate('/profile')} className="profile-button">
              👤 {user?.username || 'Usuario'}
            </button>
            <button onClick={handleLogout} className="logout-button">
              Cerrar Sesión
            </button>
          </div>
        </div>
      </header>

      <main className="dashboard-main">
        <div className="welcome-banner">
          <h2>Bienvenido, {user?.first_name || user?.username}! 👋</h2>
          <p>Gestiona tus proyectos de manera eficiente con PIAP</p>
        </div>

        <div className="dashboard-grid">
          <div 
            className="dashboard-card clickable" 
            onClick={() => navigate('/projects')}
          >
            <div className="card-icon">📊</div>
            <h2>Proyectos</h2>
            <p className="card-number">0</p>
            <p className="card-description">Gestiona tus proyectos</p>
            <button className="card-action-btn">Ver Proyectos →</button>
          </div>

          <div className="dashboard-card">
            <div className="card-icon">✅</div>
            <h2>Tareas</h2>
            <p className="card-number">0</p>
            <p className="card-description">Próximamente</p>
          </div>

          <div className="dashboard-card">
            <div className="card-icon">👥</div>
            <h2>Equipo</h2>
            <p className="card-number">0</p>
            <p className="card-description">Próximamente</p>
          </div>

          <div className="dashboard-card">
            <div className="card-icon">⚠️</div>
            <h2>Incidencias</h2>
            <p className="card-number">0</p>
            <p className="card-description">Próximamente</p>
          </div>
        </div>

        <div className="quick-actions">
          <h3>Acciones Rápidas</h3>
          <div className="actions-grid">
            <button 
              className="action-btn"
              onClick={() => navigate('/projects/new')}
            >
              <span className="action-icon">➕</span>
              <span>Nuevo Proyecto</span>
            </button>
            <button 
              className="action-btn"
              onClick={() => navigate('/projects')}
            >
              <span className="action-icon">📋</span>
              <span>Ver Proyectos</span>
            </button>
            <button 
              className="action-btn"
              onClick={() => navigate('/profile')}
            >
              <span className="action-icon">⚙️</span>
              <span>Mi Perfil</span>
            </button>
          </div>
        </div>

        <div className="info-section">
          <h3>Sistema de Gestión de Proyectos</h3>
          <p>
            PIAP (Plataforma Interna de Administración de Proyectos) te permite centralizar
            la gestión de proyectos, tareas, equipos y recursos en un solo lugar.
          </p>
          <p className="version-info">
            <strong>Version:</strong> Release 0 - Sprint 1 | MVP en construcción
          </p>
        </div>
      </main>
    </div>
  );
}
EOF

# 4. Actualizar DashboardPage.css
echo "🎨 Actualizando DashboardPage.css..."
cat >> src/pages/DashboardPage.css << 'EOF'

.welcome-banner {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 30px;
  border-radius: 10px;
  margin-bottom: 30px;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.welcome-banner h2 {
  margin: 0 0 10px 0;
  font-size: 1.8rem;
}

.welcome-banner p {
  margin: 0;
  opacity: 0.9;
}

.dashboard-card.clickable {
  cursor: pointer;
  border: 2px solid transparent;
}

.dashboard-card.clickable:hover {
  border-color: #667eea;
}

.card-icon {
  font-size: 3rem;
  margin-bottom: 15px;
}

.card-action-btn {
  margin-top: 15px;
  padding: 10px 20px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.card-action-btn:hover {
  background: #5568d3;
  transform: translateX(5px);
}

.quick-actions {
  background: white;
  padding: 30px;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  margin-bottom: 30px;
}

.quick-actions h3 {
  margin: 0 0 20px 0;
  color: #333;
}

.actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 15px 20px;
  background: #f8f9fa;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 1rem;
  transition: all 0.3s;
}

.action-btn:hover {
  background: #667eea;
  color: white;
  border-color: #667eea;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.action-icon {
  font-size: 1.5rem;
}

.info-section {
  background: white;
  padding: 30px;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.info-section h3 {
  margin: 0 0 15px 0;
  color: #667eea;
}

.info-section p {
  color: #666;
  line-height: 1.6;
  margin-bottom: 10px;
}

.version-info {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #e9ecef;
  font-size: 0.9rem;
  font-style: italic;
}
EOF

# 5. Actualizar App.jsx con las rutas completas
echo "⚛️ Actualizando App.jsx..."
cat > src/App.jsx << 'EOF'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useAuthStore } from './stores/authStore';

// Auth pages
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import ForgotPasswordPage from './pages/ForgotPasswordPage';
import ResetPasswordPage from './pages/ResetPasswordPage';

// Main pages
import DashboardPage from './pages/DashboardPage';
import ProfilePage from './pages/ProfilePage';

// Projects pages
import ProjectsListPage from './pages/projects/ProjectsListPage';
import ProjectDetailPage from './pages/projects/ProjectDetailPage';
import ProjectFormPage from './pages/projects/ProjectFormPage';

function PrivateRoute({ children }) {
  const isAuthenticated = useAuthStore(state => state.isAuthenticated);
  return isAuthenticated ? children : <Navigate to="/" />;
}

function PublicRoute({ children }) {
  const isAuthenticated = useAuthStore(state => state.isAuthenticated);
  return !isAuthenticated ? children : <Navigate to="/dashboard" />;
}

function App() {
  return (
    <Router>
      <Routes>
        {/* Rutas públicas */}
        <Route path="/" element={<PublicRoute><LoginPage /></PublicRoute>} />
        <Route path="/register" element={<PublicRoute><RegisterPage /></PublicRoute>} />
        <Route path="/forgot-password" element={<PublicRoute><ForgotPasswordPage /></PublicRoute>} />
        <Route path="/reset-password" element={<PublicRoute><ResetPasswordPage /></PublicRoute>} />
        
        {/* Rutas privadas - Dashboard */}
        <Route 
          path="/dashboard" 
          element={<PrivateRoute><DashboardPage /></PrivateRoute>} 
        />
        <Route 
          path="/profile" 
          element={<PrivateRoute><ProfilePage /></PrivateRoute>} 
        />
        
        {/* Rutas privadas - Proyectos */}
        <Route 
          path="/projects" 
          element={<PrivateRoute><ProjectsListPage /></PrivateRoute>} 
        />
        <Route 
          path="/projects/new" 
          element={<PrivateRoute><ProjectFormPage /></PrivateRoute>} 
        />
        <Route 
          path="/projects/:id" 
          element={<PrivateRoute><ProjectDetailPage /></PrivateRoute>} 
        />
        <Route 
          path="/projects/:id/edit" 
          element={<PrivateRoute><ProjectFormPage /></PrivateRoute>} 
        />
        
        {/* Ruta 404 */}
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </Router>
  );
}

export default App;
EOF

echo ""
echo "✅ ¡Módulo de Proyectos COMPLETO!"
echo ""
echo "==================== RESUMEN ===================="
echo ""
echo "Backend creado:"
echo "  ✓ Models (Project, Category, Milestone, Document, Comment)"
echo "  ✓ Serializers"
echo "  ✓ ViewSets con filtros y búsqueda"
echo "  ✓ Permisos personalizados"
echo "  ✓ URLs configuradas"
echo "  ✓ Admin de Django completo"
echo ""
echo "Frontend creado:"
echo "  ✓ Lista de proyectos con filtros"
echo "  ✓ Cards de proyectos"
echo "  ✓ Estadísticas visuales"
echo "  ✓ Detalle de proyecto completo"
echo "  ✓ Formulario de creación/edición"
echo "  ✓ Store de Zustand"
echo "  ✓ API service"
echo "  ✓ Rutas configuradas"
echo "  ✓ Dashboard actualizado"
echo ""
echo "==================== PRÓXIMOS PASOS ===================="
echo ""
echo "1. Backend:"
echo "   cd backend"
echo "   python manage.py makemigrations projects"
echo "   python manage.py migrate"
echo "   python manage.py runserver"
echo ""
echo "2. Frontend:"
echo "   cd frontend"
echo "   npm run dev"
echo ""
echo "3. Crear datos de prueba:"
echo "   - Accede al admin: http://localhost:8000/admin/"
echo "   - Crea una categoría"
echo "   - Crea un proyecto de prueba"
echo ""
echo "4. Probar el módulo:"
echo "   - Login: http://localhost:5173/"
echo "   - Dashboard: http://localhost:5173/dashboard"
echo "   - Proyectos: http://localhost:5173/projects"
echo ""
echo "¡El módulo de Proyectos está listo para usar! 🎉"