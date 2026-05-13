import React, { useState, useEffect } from 'react';
import { projectsAPI } from '../../services/projectsAPI';
import './BacklogList.css';

export default function SprintList({ projectId }) {
  const [sprints, setSprints] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    name: '', number: 1, start_date: '', end_date: '', goal: '', capacity: 0
  });

  useEffect(() => {
    fetchSprints();
  }, [projectId]);

  const fetchSprints = async () => {
    setLoading(true);
    try {
      const res = await projectsAPI.getSprints(projectId);
      setSprints(res.data);
      if (res.data.length > 0) {
        setFormData(prev => ({...prev, number: res.data.length + 1}));
      }
    } catch (error) {
      console.error('Error fetching sprints:', error);
    }
    setLoading(false);
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await projectsAPI.createSprint({ ...formData, project: projectId });
      fetchSprints();
      setShowForm(false);
      setFormData({ name: '', number: sprints.length + 2, start_date: '', end_date: '', goal: '', capacity: 0 });
    } catch (error) {
      console.error('Error creating sprint:', error);
      alert('Error al crear sprint');
    }
  };

  if (loading) return <div>Cargando sprints...</div>;

  return (
    <div className="sprint-container">
      <div className="backlog-header">
        <h3>Sprints</h3>
        <button className="btn-primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? 'Cancelar' : '+ Nuevo Sprint'}
        </button>
      </div>

      {showForm && (
        <form className="backlog-form" onSubmit={handleCreate}>
          <div className="form-row">
            <input type="number" placeholder="Número" value={formData.number} onChange={e => setFormData({...formData, number: parseInt(e.target.value)})} min="1" required />
            <input type="text" placeholder="Nombre (ej: Sprint 1)" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} required />
          </div>
          <input type="text" placeholder="Objetivo del Sprint" value={formData.goal} onChange={e => setFormData({...formData, goal: e.target.value})} />
          <div className="form-row">
            <input type="date" value={formData.start_date} onChange={e => setFormData({...formData, start_date: e.target.value})} required />
            <input type="date" value={formData.end_date} onChange={e => setFormData({...formData, end_date: e.target.value})} required />
            <input type="number" placeholder="Capacidad (Pts)" value={formData.capacity} onChange={e => setFormData({...formData, capacity: parseInt(e.target.value)})} min="0" />
          </div>
          <button type="submit" className="btn-success">Guardar</button>
        </form>
      )}

      <div className="backlog-list">
        {sprints.length === 0 ? <p>No hay sprints creados.</p> : (
          <table>
            <thead>
              <tr>
                <th>#</th>
                <th>Nombre</th>
                <th>Objetivo</th>
                <th>Fechas</th>
                <th>Estado</th>
                <th>Capacidad</th>
              </tr>
            </thead>
            <tbody>
              {sprints.map(s => (
                <tr key={s.id}>
                  <td>{s.number}</td>
                  <td>{s.name}</td>
                  <td>{s.goal || '-'}</td>
                  <td>{s.start_date} al {s.end_date}</td>
                  <td>{s.status_display}</td>
                  <td>{s.capacity} pts</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}