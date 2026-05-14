import React, { useState, useEffect } from 'react';
import { useProjectsStore } from '../../stores/projectsStore';

export default function CategoriesModal({ onClose }) {
  const { categories, fetchCategories, createCategory, updateCategory, deleteCategory } = useProjectsStore();
  const [loading, setLoading] = useState(true);
  const [isEditingModalOpen, setIsEditingModalOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);
  
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    color: '#667eea',
    is_active: true
  });
  
  const [saving, setSaving] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  useEffect(() => {
    loadCategories();
  }, []);

  const loadCategories = async () => {
    setLoading(true);
    try {
      await fetchCategories();
    } catch (error) {
      console.error(error);
    }
    setLoading(false);
  };

  const handleOpenEditModal = (category = null) => {
    setErrorMsg('');
    if (category) {
      setEditingCategory(category);
      setFormData({
        name: category.name,
        description: category.description || '',
        color: category.color || '#667eea',
        is_active: category.is_active
      });
    } else {
      setEditingCategory(null);
      setFormData({
        name: '',
        description: '',
        color: '#667eea',
        is_active: true
      });
    }
    setIsEditingModalOpen(true);
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setErrorMsg('');
    
    try {
      if (editingCategory) {
        await updateCategory(editingCategory.id, formData);
      } else {
        await createCategory(formData);
      }
      setIsEditingModalOpen(false);
    } catch (error) {
      setErrorMsg('Ocurrió un error al guardar. Verifica que el nombre no esté duplicado.');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('¿Estás seguro de eliminar esta categoría? Solo podrás eliminarla si no tiene proyectos asociados.')) {
      try {
        await deleteCategory(id);
      } catch (error) {
        alert('No se pudo eliminar la categoría. Es posible que tenga proyectos asociados.');
      }
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50 p-4">
      <div className="bg-white rounded-xl w-full max-w-4xl max-h-[90vh] overflow-y-auto shadow-2xl flex flex-col">
        
        <div className="sticky top-0 bg-white z-10 px-8 py-6 border-b border-gray-100 flex justify-between items-center">
          <div>
            <h4 className="text-2xl font-bold text-gray-800 flex items-center gap-2">
              <span>🏷️</span> Administrar Categorías
            </h4>
            <p className="text-gray-500 text-sm mt-1 mb-0">
              Gestiona las categorías de tus proyectos
            </p>
          </div>
          <div className="flex items-center gap-4">
            <button 
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium text-sm shadow-sm"
              onClick={() => handleOpenEditModal()}
            >
              <span>➕</span> Nueva Categoría
            </button>
            <button 
              className="text-gray-400 hover:text-gray-700 transition-colors p-2 rounded-full hover:bg-gray-100" 
              onClick={onClose}
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        <div className="p-8">
          {loading ? (
            <div className="flex justify-center items-center py-12">
              <div className="w-12 h-12 border-4 border-gray-200 border-t-blue-600 rounded-full animate-spin"></div>
            </div>
          ) : (
            <div className="border border-gray-200 rounded-lg overflow-hidden">
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="bg-gray-50 border-b border-gray-200">
                      <th className="px-6 py-4 font-semibold text-gray-700 text-sm">Color</th>
                      <th className="px-6 py-4 font-semibold text-gray-700 text-sm">Nombre</th>
                      <th className="px-6 py-4 font-semibold text-gray-700 text-sm hidden md:table-cell">Descripción</th>
                      <th className="px-6 py-4 font-semibold text-gray-700 text-sm">Estado</th>
                      <th className="px-6 py-4 font-semibold text-gray-700 text-sm text-right">Acciones</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {categories.map(category => (
                      <tr key={category.id} className="hover:bg-gray-50/50 transition-colors">
                        <td className="px-6 py-4">
                          <div 
                            className="w-6 h-6 rounded-full shadow-sm border border-gray-200" 
                            style={{ backgroundColor: category.color || '#667eea' }}
                          ></div>
                        </td>
                        <td className="px-6 py-4">
                          <div className="font-medium text-gray-900">{category.name}</div>
                          <div className="text-xs text-gray-500 mt-1">{category.projects_count || 0} proyectos</div>
                        </td>
                        <td className="px-6 py-4 text-gray-600 text-sm hidden md:table-cell max-w-xs truncate">
                          {category.description || '-'}
                        </td>
                        <td className="px-6 py-4">
                          <span className={`px-3 py-1 rounded-full text-xs font-medium ${category.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}`}>
                            {category.is_active ? 'Activa' : 'Inactiva'}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-right">
                          <button 
                            onClick={() => handleOpenEditModal(category)}
                            className="text-blue-600 hover:text-blue-900 p-2 hover:bg-blue-50 rounded transition-colors mr-2"
                            title="Editar"
                          >
                            ✏️
                          </button>
                          <button 
                            onClick={() => handleDelete(category.id)}
                            className="text-red-600 hover:text-red-900 p-2 hover:bg-red-50 rounded transition-colors"
                            title="Eliminar"
                          >
                            🗑️
                          </button>
                        </td>
                      </tr>
                    ))}
                    
                    {categories.length === 0 && (
                      <tr>
                        <td colSpan="5" className="px-6 py-8 text-center text-gray-500">
                          No hay categorías creadas.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Modal Secundario de Edición/Creación */}
      {isEditingModalOpen && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-[60] p-4">
          <div className="bg-white rounded-xl w-full max-w-lg shadow-2xl flex flex-col overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50">
              <h3 className="text-lg font-bold text-gray-800 m-0">
                {editingCategory ? 'Editar Categoría' : 'Nueva Categoría'}
              </h3>
              <button 
                onClick={() => setIsEditingModalOpen(false)}
                className="text-gray-400 hover:text-gray-700 transition-colors"
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-6">
              {errorMsg && (
                <div className="p-3 bg-red-50 text-red-800 border border-red-200 rounded-lg mb-4 text-sm">
                  {errorMsg}
                </div>
              )}
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Nombre</label>
                  <input 
                    type="text" 
                    name="name" 
                    value={formData.name} 
                    onChange={handleChange} 
                    required 
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all"
                    placeholder="Ej. Desarrollo Web"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Descripción</label>
                  <textarea 
                    name="description" 
                    value={formData.description} 
                    onChange={handleChange} 
                    rows="2"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all"
                  ></textarea>
                </div>
                
                <div className="flex gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Color Identificador</label>
                    <input 
                      type="color" 
                      name="color" 
                      value={formData.color} 
                      onChange={handleChange} 
                      className="h-10 w-20 cursor-pointer rounded border border-gray-300 p-1"
                    />
                  </div>
                  
                  <div className="flex items-center pt-6">
                    <label className="flex items-center cursor-pointer">
                      <input 
                        type="checkbox" 
                        name="is_active" 
                        checked={formData.is_active} 
                        onChange={handleChange} 
                        className="w-5 h-5 text-blue-600 rounded border-gray-300 focus:ring-blue-500"
                      />
                      <span className="ml-2 text-sm font-medium text-gray-700">Categoría Activa</span>
                    </label>
                  </div>
                </div>
              </div>
              
              <div className="flex justify-end gap-3 mt-8 pt-4 border-t border-gray-100">
                <button 
                  type="button" 
                  onClick={() => setIsEditingModalOpen(false)}
                  className="px-4 py-2 rounded-lg font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 transition-colors"
                  disabled={saving}
                >
                  Cancelar
                </button>
                <button 
                  type="submit" 
                  className="px-4 py-2 rounded-lg font-medium text-white bg-blue-600 hover:bg-blue-700 transition-colors shadow-sm flex items-center gap-2"
                  disabled={saving}
                >
                  {saving ? 'Guardando...' : 'Guardar Categoría'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}