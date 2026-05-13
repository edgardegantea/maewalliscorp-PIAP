import React, { useState, useEffect } from 'react';
import { projectsAPI } from '../../services/projectsAPI';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

export default function ReportList({ projectId }) {
  const [sprints, setSprints] = useState([]);
  const [activeSprint, setActiveSprint] = useState('');
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);

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

  // Build basic burndown data
  const generateBurndownData = () => {
    const sprint = sprints.find(s => s.id === activeSprint);
    if (!sprint) return [];

    const start = new Date(sprint.start_date);
    const end = new Date(sprint.end_date);
    const days = Math.ceil((end - start) / (1000 * 60 * 60 * 24));
    
    let totalHours = tasks.reduce((sum, task) => sum + task.estimated_hours, 0);
    const dailyBurn = totalHours / (days > 0 ? days : 1);

    const data = [];
    let currentIdeal = totalHours;
    
    // Calculate actual remaining hours. For a real burndown, we would need historical tracking of task status changes.
    // For this MVP, we will simplify: count completed tasks as burned, open tasks as remaining.
    let remainingActual = totalHours;
    let completedHours = tasks.filter(t => t.status === 'COMPLETADA').reduce((sum, t) => sum + t.estimated_hours, 0);

    for (let i = 0; i <= days; i++) {
      let d = new Date(start);
      d.setDate(d.getDate() + i);
      
      data.push({
        day: d.toLocaleDateString('es-MX', { day: '2-digit', month: 'short' }),
        ideal: Math.round(currentIdeal),
        actual: i === days ? (totalHours - completedHours) : (i === 0 ? totalHours : null) // Simplified visualization
      });
      currentIdeal -= dailyBurn;
    }
    
    return data;
  };

  if (loading && !sprints.length) return <div>Cargando Reportes...</div>;

  return (
    <div className="backlog-container">
      <div className="backlog-header">
        <h3>Reportes del Proyecto (Burndown)</h3>
        <select value={activeSprint} onChange={e => setActiveSprint(e.target.value)} style={{padding: '8px', borderRadius: '4px'}}>
          <option value="">(Selecciona un Sprint)</option>
          {sprints.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
        </select>
      </div>

      {!activeSprint ? (
        <p>No hay sprints disponibles para generar reporte.</p>
      ) : (
        <div style={{ width: '100%', height: 400, marginTop: '20px' }}>
          <ResponsiveContainer>
            <LineChart
              data={generateBurndownData()}
              margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
            >
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="day" />
              <YAxis label={{ value: 'Horas Restantes', angle: -90, position: 'insideLeft' }} />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="ideal" stroke="#8884d8" name="Burn Ideal" strokeDasharray="5 5" />
              <Line type="monotone" dataKey="actual" stroke="#82ca9d" name="Burn Real" connectNulls />
            </LineChart>
          </ResponsiveContainer>
        </div>
      )}
    </div>
  );
}