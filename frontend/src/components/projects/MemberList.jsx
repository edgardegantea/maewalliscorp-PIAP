import React, { useState, useEffect } from 'react';
import { projectsAPI } from '../../services/projectsAPI';

export default function MemberList({ projectId }) {
  const [members, setMembers] = useState([]);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    user: '', role: 'DESARROLLADOR'
  });

  useEffect(() => {
    fetchData();
  }, [projectId]);

  const fetchData = async () => {
    setLoading(true);
    try {
      const [membersRes, usersRes] = await Promise.all([
        projectsAPI.getMembers(projectId),
        projectsAPI.getUsers()
      ]);
      setMembers(membersRes.data);
      setUsers(usersRes.data);
    } catch (error) {
      console.error('Error fetching members or users:', error);
    }
    setLoading(false);
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await projectsAPI.createMember({ ...formData, project: projectId });
      fetchData();
      setShowForm(false);
      setFormData({ user: '', role: 'DESARROLLADOR' });
    } catch (error) {
      console.error('Error creating member:', error);
      alert('Error al agregar miembro (asegúrate de que no esté ya agregado)');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('¿Seguro que deseas remover este miembro?')) return;
    try {
      await projectsAPI.deleteMember(id);
      fetchData();
    } catch (error) {
      console.error('Error deleting member:', error);
      alert('Error al remover miembro');
    }
  };

  if (loading) return <div>Cargando equipo...</div>;

  return (
    <div className="backlog-container">
      <div className="backlog-header">
        <h3>Equipo del Proyecto</h3>
        <button className="btn-primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? 'Cancelar' : '+ Agregar Miembro'}
        </button>
      </div>

      {showForm && (
        <form className="backlog-form" onSubmit={handleCreate}>
          <div className="form-row">
            <select value={formData.user} onChange={e => setFormData({...formData, user: e.target.value})} required>
              <option value="">Selecciona un Usuario</option>
              {users.map(u => (
                <option key={u.id} value={u.id}>
                  {u.first_name ? `${u.first_name} ${u.last_name}` : u.username} ({u.email})
                </option>
              ))}
            </select>
            <select value={formData.role} onChange={e => setFormData({...formData, role: e.target.value})} required>
              <option value="PM">Project Manager</option>
              <option value="DESARROLLADOR">Desarrollador</option>
              <option value="TESTER">Tester</option>
              <option value="ANALISTA">Analista</option>
              <option value="STAKEHOLDER">Stakeholder</option>
            </select>
            <button type="submit" className="btn-success">Agregar</button>
          </div>
        </form>
      )}

      <div className="backlog-list">
        {members.length === 0 ? <p>No hay miembros asignados.</p> : (
          <table>
            <thead>
              <tr>
                <th>Nombre</th>
                <th>Usuario</th>
                <th>Rol</th>
                <th>Asignado En</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {members.map(m => (
                <tr key={m.id}>
                  <td>{m.user_data?.first_name} {m.user_data?.last_name}</td>
                  <td>{m.user_data?.username}</td>
                  <td><span className="badge">{m.role_display}</span></td>
                  <td>{new Date(m.assigned_at).toLocaleDateString()}</td>
                  <td>
                    <button onClick={() => handleDelete(m.id)} className="btn-small" style={{background: '#dc3545'}}>
                      Remover
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}