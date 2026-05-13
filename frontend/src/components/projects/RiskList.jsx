import React, { useState, useEffect } from 'react';
import { projectsAPI } from '../../services/projectsAPI';

export default function RiskList({ projectId }) {
  const [risks, setRisks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    description: '', probability: 'MEDIA', impact: 'MEDIO', mitigation_plan: '', status: 'ABIERTO'
  });

  useEffect(() => {
    fetchRisks();
  }, [projectId]);

  const fetchRisks = async () => {
    setLoading(true);
    try {
      const res = await projectsAPI.getRisks(projectId);
      setRisks(res.data);
    } catch (error) {
      console.error('Error fetching risks:', error);
    }
    setLoading(false);
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await projectsAPI.createRisk({ ...formData, project: projectId });
      fetchRisks();
      setShowForm(false);
      setFormData({ description: '', probability: 'MEDIA', impact: 'MEDIO', mitigation_plan: '', status: 'ABIERTO' });
    } catch (error) {
      console.error('Error creating risk:', error);
      alert('Error al registrar el riesgo');
    }
  };

  const getRiskColor = (prob, imp) => {
    if (prob === 'ALTA' && imp === 'ALTO') return '#dc3545'; // Rojo
    if (prob === 'BAJA' && imp === 'BAJO') return '#28a745'; // Verde
    return '#ffc107'; // Amarillo
  };

  if (loading) return <div>Cargando riesgos...</div>;

  return (
    <div className="backlog-container">
      <div className="backlog-header">
        <h3>Registro de Riesgos</h3>
        <button className="btn-primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? 'Cancelar' : '+ Nuevo Riesgo'}
        </button>
      </div>

      {showForm && (
        <form className="backlog-form" onSubmit={handleCreate}>
          <textarea placeholder="Descripción del riesgo" value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} required />
          <div className="form-row">
            <select value={formData.probability} onChange={e => setFormData({...formData, probability: e.target.value})}>
              <option value="BAJA">Probabilidad: Baja</option>
              <option value="MEDIA">Probabilidad: Media</option>
              <option value="ALTA">Probabilidad: Alta</option>
            </select>
            <select value={formData.impact} onChange={e => setFormData({...formData, impact: e.target.value})}>
              <option value="BAJO">Impacto: Bajo</option>
              <option value="MEDIO">Impacto: Medio</option>
              <option value="ALTO">Impacto: Alto</option>
            </select>
          </div>
          <textarea placeholder="Plan de Mitigación" value={formData.mitigation_plan} onChange={e => setFormData({...formData, mitigation_plan: e.target.value})} />
          <button type="submit" className="btn-success">Registrar</button>
        </form>
      )}

      <div className="backlog-list">
        {risks.length === 0 ? <p>No hay riesgos registrados.</p> : (
          <table>
            <thead>
              <tr>
                <th>Severidad</th>
                <th>Descripción</th>
                <th>Probabilidad</th>
                <th>Impacto</th>
                <th>Estado</th>
                <th>Mitigación</th>
              </tr>
            </thead>
            <tbody>
              {risks.map(r => (
                <tr key={r.id}>
                  <td>
                    <div style={{ width: 15, height: 15, borderRadius: '50%', backgroundColor: getRiskColor(r.probability, r.impact) }}></div>
                  </td>
                  <td>{r.description}</td>
                  <td>{r.probability_display}</td>
                  <td>{r.impact_display}</td>
                  <td>{r.status_display}</td>
                  <td>{r.mitigation_plan || '-'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}