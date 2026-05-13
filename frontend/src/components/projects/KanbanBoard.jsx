import React, { useState, useEffect } from 'react';
import { projectsAPI } from '../../services/projectsAPI';
import './KanbanBoard.css';

const COLUMNS = [
  { id: 'PENDIENTE', title: 'Pendiente' },
  { id: 'EN_PROGRESO', title: 'En Progreso' },
  { id: 'BLOQUEADA', title: 'Bloqueada' },
  { id: 'COMPLETADA', title: 'Completada' }
];

export default function KanbanBoard({ projectId }) {
  const [sprints, setSprints] = useState([]);
  const [activeSprint, setActiveSprint] = useState('');
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    title: '', description: '', estimated_hours: 0, status: 'PENDIENTE'
  });

  useEffect(() => {
    fetchSprints();
  }, [projectId]);

  useEffect(() => {
    if (activeSprint) {
      fetchTasks();
    } else {
      setTasks([]);
    }
  }, [activeSprint]);

  const fetchSprints = async () => {
    try {
      const res = await projectsAPI.getSprints(projectId);
      setSprints(res.data);
      const active = res.data.find(s => s.status === 'ACTIVO');
      if (active) setActiveSprint(active.id);
      else if (res.data.length > 0) setActiveSprint(res.data[0].id);
    } catch (error) {
      console.error('Error fetching sprints:', error);
    }
    setLoading(false);
  };

  const fetchTasks = async () => {
    setLoading(true);
    try {
      const res = await projectsAPI.getTasks({ sprint: activeSprint });
      setTasks(res.data);
    } catch (error) {
      console.error('Error fetching tasks:', error);
    }
    setLoading(false);
  };

  const handleCreateTask = async (e) => {
    e.preventDefault();
    try {
      await projectsAPI.createTask({ ...formData, sprint: activeSprint });
      fetchTasks();
      setShowForm(false);
      setFormData({ title: '', description: '', estimated_hours: 0, status: 'PENDIENTE' });
    } catch (error) {
      console.error('Error creating task:', error);
      alert('Error al crear la tarea');
    }
  };

  const handleDragStart = (e, taskId) => {
    e.dataTransfer.setData('taskId', taskId);
  };

  const handleDrop = async (e, targetStatus) => {
    e.preventDefault();
    const taskId = e.dataTransfer.getData('taskId');
    if (!taskId) return;

    // Optimistic UI update
    setTasks(prev => prev.map(t => t.id == taskId ? { ...t, status: targetStatus } : t));

    try {
      await projectsAPI.updateTask(taskId, { status: targetStatus });
      fetchTasks();
    } catch (error) {
      console.error('Error updating task status:', error);
      fetchTasks(); // Revert on error
    }
  };

  const handleDragOver = (e) => {
    e.preventDefault();
  };

  if (loading && !sprints.length) return <div>Cargando Tablero...</div>;

  return (
    <div className="kanban-container">
      <div className="kanban-header">
        <div className="kanban-controls">
          <select value={activeSprint} onChange={e => setActiveSprint(e.target.value)}>
            <option value="">(Selecciona un Sprint)</option>
            {sprints.map(s => <option key={s.id} value={s.id}>{s.name} ({s.status_display})</option>)}
          </select>
          {activeSprint && (
            <button className="btn-primary" onClick={() => setShowForm(!showForm)}>
              {showForm ? 'Cancelar' : '+ Nueva Tarea'}
            </button>
          )}
        </div>
      </div>

      {showForm && activeSprint && (
        <form className="kanban-form" onSubmit={handleCreateTask}>
          <input type="text" placeholder="Título de la tarea" value={formData.title} onChange={e => setFormData({...formData, title: e.target.value})} required />
          <textarea placeholder="Descripción" value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} />
          <div className="form-row">
            <input type="number" placeholder="Horas" value={formData.estimated_hours} onChange={e => setFormData({...formData, estimated_hours: parseInt(e.target.value)})} min="0" />
            <select value={formData.status} onChange={e => setFormData({...formData, status: e.target.value})}>
              <option value="PENDIENTE">Pendiente</option>
              <option value="EN_PROGRESO">En Progreso</option>
              <option value="BLOQUEADA">Bloqueada</option>
              <option value="COMPLETADA">Completada</option>
            </select>
          </div>
          <button type="submit" className="btn-success">Guardar</button>
        </form>
      )}

      {!activeSprint ? (
        <p>No hay sprints disponibles. Crea uno primero.</p>
      ) : (
        <div className="kanban-board">
          {COLUMNS.map(col => (
            <div 
              key={col.id} 
              className="kanban-column"
              onDragOver={handleDragOver}
              onDrop={(e) => handleDrop(e, col.id)}
            >
              <h4>{col.title}</h4>
              <div className="kanban-tasks">
                {tasks.filter(t => t.status === col.id).map(task => (
                  <div 
                    key={task.id} 
                    className="kanban-task-card"
                    draggable
                    onDragStart={(e) => handleDragStart(e, task.id)}
                  >
                    <h5>{task.title}</h5>
                    <p>{task.description}</p>
                    <div className="task-meta">
                      <span className="task-hours">{task.estimated_hours}h</span>
                      {task.assigned_to_name && <span className="task-assignee">{task.assigned_to_name}</span>}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}