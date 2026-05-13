import React, { useState, useEffect } from 'react';
import { projectsAPI } from '../../services/projectsAPI';

export default function IncidentList({ projectId }) {
  const [incidents, setIncidents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    title: '', description: '', severity: 'MEDIA', status: 'ABIERTA'
  });

  useEffect(() => {
    fetchIncidents();
  }, [projectId]);

  const fetchIncidents = async () => {
    setLoading(true);
    try {
      const res = await projectsAPI.getIncidents(projectId);
      setIncidents(res.data);
    } catch (error) {
      console.error('Error fetching incidents:', error);
    }
    setLoading(false);
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await projectsAPI.createIncident({ ...formData, project: projectId });
      fetchIncidents();
      setShowForm(false);
      setFormData({ title: '', description: '', severity: 'MEDIA', status: 'ABIERTA' });
    } catch (error) {
      console.error('Error creating incident:', error);
      alert('Error al registrar la incidencia');
    }
  };

  const getSeverityColor = (sev) => {
    const colors = {
      'BAJA': '#28a745',
      'MEDIA': '#ffc107',
      'ALTA': '#fd7e14',
      'CRITICA': '#dc3545'
    };
    return colors[sev] || '#6c757d';
  };

  if (loading) return <div>Cargando incidencias...</div>;

  return (
    <div className="backlog-container">
      <div className="backlog-header">
        <h3>Registro de Incidencias</h3>
        <button className="btn-primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? 'Cancelar' : '+ Nueva Incidencia'}
        </button>
      </div>

      {showForm && (
        <form className="backlog-form" onSubmit={handleCreate}>
          <div className="form-row">
            <input type="text" placeholder="Título de la incidencia" value={formData.title} onChange={e => setFormData({...formData, title: e.target.value})} required />
            <select value={formData.severity} onChange={e => setFormData({...formData, severity: e.target.value})}>
              <option value="BAJA">Severidad: Baja</option>
              <option value="MEDIA">Severidad: Media</option>
              <option value="ALTA">Severidad: Alta</option>
              <option value="CRITICA">Severidad: Crítica</option>
            </select>
          </div>
          <textarea placeholder="Descripción detallada" value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} required />
          <button type="submit" className="btn-success">Registrar</button>
        </form>
      )}

      <div className="backlog-list">
        {incidents.length === 0 ? <p>No hay incidencias registradas.</p> : (
          <table>
            <thead>
              <tr>
                <th>Título</th>
                <th>Severidad</th>
                <th>Estado</th>
                <th>Reportado Por</th>
                <th>Asignado A</th>
              </tr>
            </thead>
            <tbody>
              {incidents.map(inc => (
                <tr key={inc.id}>
                  <td>{inc.title}</td>
                  <td>
                    <span style={{ color: getSeverityColor(inc.severity), fontWeight: 'bold' }}>
                      {inc.severity_display}
                    </span>
                  </td>
                  <td>{inc.status_display}</td>
                  <td>{inc.reported_by_name}</td>
                  <td>{inc.assigned_to_name || 'Sin asignar'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}