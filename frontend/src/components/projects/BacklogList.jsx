import React, { useState, useEffect } from 'react';
import { projectsAPI } from '../../services/projectsAPI';
import './BacklogList.css';

export default function BacklogList({ projectId }) {
  const [items, setItems] = useState([]);
  const [sprints, setSprints] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    title: '', description: '', priority: 'MEDIA', story_points: 0, sprint: ''
  });

  useEffect(() => {
    fetchData();
  }, [projectId]);

  const fetchData = async () => {
    setLoading(true);
    try {
      const [backlogRes, sprintsRes] = await Promise.all([
        projectsAPI.getBacklogItems(projectId),
        projectsAPI.getSprints(projectId)
      ]);
      setItems(backlogRes.data);
      setSprints(sprintsRes.data);
    } catch (error) {
      console.error('Error fetching backlog:', error);
    }
    setLoading(false);
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      const data = { ...formData, project: projectId };
      if (!data.sprint) delete data.sprint; // null for unassigned
      await projectsAPI.createBacklogItem(data);
      fetchData();
      setShowForm(false);
      setFormData({ title: '', description: '', priority: 'MEDIA', story_points: 0, sprint: '' });
    } catch (error) {
      console.error('Error creating item:', error);
      alert('Error al crear historia');
    }
  };

  if (loading) return <div>Cargando backlog...</div>;

  return (
    <div className="backlog-container">
      <div className="backlog-header">
        <h3>Backlog (Historias de Usuario)</h3>
        <button className="btn-primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? 'Cancelar' : '+ Nueva Historia'}
        </button>
      </div>

      {showForm && (
        <form className="backlog-form" onSubmit={handleCreate}>
          <input type="text" placeholder="Título" value={formData.title} onChange={e => setFormData({...formData, title: e.target.value})} required />
          <textarea placeholder="Descripción" value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} />
          <div className="form-row">
            <select value={formData.priority} onChange={e => setFormData({...formData, priority: e.target.value})}>
              <option value="BAJA">Baja</option>
              <option value="MEDIA">Media</option>
              <option value="ALTA">Alta</option>
            </select>
            <input type="number" placeholder="Puntos" value={formData.story_points} onChange={e => setFormData({...formData, story_points: parseInt(e.target.value)})} min="0" />
            <select value={formData.sprint} onChange={e => setFormData({...formData, sprint: e.target.value})}>
              <option value="">(Sin Sprint)</option>
              {sprints.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
            </select>
          </div>
          <button type="submit" className="btn-success">Guardar</button>
        </form>
      )}

      <div className="backlog-list">
        {items.length === 0 ? <p>No hay historias en el backlog.</p> : (
          <table>
            <thead>
              <tr>
                <th>Título</th>
                <th>Prioridad</th>
                <th>Puntos</th>
                <th>Estado</th>
                <th>Sprint</th>
              </tr>
            </thead>
            <tbody>
              {items.map(item => (
                <tr key={item.id}>
                  <td>{item.title}</td>
                  <td>{item.priority_display}</td>
                  <td>{item.story_points}</td>
                  <td>{item.status_display}</td>
                  <td>{item.sprint_name || '-'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
