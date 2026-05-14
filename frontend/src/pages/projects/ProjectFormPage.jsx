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
                <div style={{ display: 'flex', gap: '8px' }}>
                  <select
                    id="category"
                    name="category"
                    value={formData.category}
                    onChange={handleChange}
                    disabled={submitting}
                    style={{ flexGrow: 1 }}
                  >
                    <option value="">Selecciona una categoría</option>
                    {categories.map(cat => (
                      <option key={cat.id} value={cat.id}>{cat.name}</option>
                    ))}
                  </select>
                  <button
                    type="button"
                    onClick={() => navigate('/categories')}
                    style={{ padding: '8px 12px', background: '#f3f4f6', border: '1px solid #d1d5db', borderRadius: '4px', cursor: 'pointer' }}
                    title="Administrar Categorías"
                  >
                    ⚙️
                  </button>
                </div>
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
