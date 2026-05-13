import React, { useState, useEffect } from 'react';
import { projectsAPI } from '../../services/projectsAPI';

export default function DocumentList({ projectId }) {
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    name: '', description: ''
  });
  const [file, setFile] = useState(null);

  useEffect(() => {
    fetchDocuments();
  }, [projectId]);

  const fetchDocuments = async () => {
    setLoading(true);
    try {
      const res = await projectsAPI.getDocuments(projectId);
      setDocuments(res.data);
    } catch (error) {
      console.error('Error fetching documents:', error);
    }
    setLoading(false);
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    if (!file) {
      alert("Por favor selecciona un archivo.");
      return;
    }
    try {
      const data = { ...formData, project: projectId, file: file };
      await projectsAPI.uploadDocument(data);
      fetchDocuments();
      setShowForm(false);
      setFormData({ name: '', description: '' });
      setFile(null);
    } catch (error) {
      console.error('Error uploading document:', error);
      alert('Error al subir documento');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('¿Seguro que deseas eliminar este documento?')) return;
    try {
      await projectsAPI.deleteDocument(id);
      fetchDocuments();
    } catch (error) {
      console.error('Error deleting document:', error);
      alert('Error al eliminar documento');
    }
  };

  if (loading) return <div>Cargando documentos...</div>;

  return (
    <div className="backlog-container">
      <div className="backlog-header">
        <h3>Repositorio de Documentos</h3>
        <button className="btn-primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? 'Cancelar' : '+ Subir Documento'}
        </button>
      </div>

      {showForm && (
        <form className="backlog-form" onSubmit={handleCreate}>
          <div className="form-row">
            <input type="text" placeholder="Nombre del documento" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} required />
            <input type="file" onChange={e => setFile(e.target.files[0])} required />
          </div>
          <textarea placeholder="Descripción (opcional)" value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} />
          <button type="submit" className="btn-success">Subir Archivo</button>
        </form>
      )}

      <div className="backlog-list">
        {documents.length === 0 ? <p>No hay documentos subidos.</p> : (
          <table>
            <thead>
              <tr>
                <th>Nombre</th>
                <th>Descripción</th>
                <th>Subido Por</th>
                <th>Fecha</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {documents.map(d => (
                <tr key={d.id}>
                  <td>
                    <a href={d.file_url} target="_blank" rel="noopener noreferrer" style={{color: '#1d4ed8', textDecoration: 'none'}}>
                      📄 {d.name}
                    </a>
                  </td>
                  <td>{d.description || '-'}</td>
                  <td>{d.uploaded_by?.first_name} {d.uploaded_by?.last_name}</td>
                  <td>{new Date(d.uploaded_at).toLocaleDateString()}</td>
                  <td>
                    <button onClick={() => handleDelete(d.id)} className="btn-small" style={{background: '#dc3545'}}>
                      Eliminar
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