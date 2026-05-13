import React, { useState, useEffect } from 'react';
import { projectsAPI } from '../../services/projectsAPI';

export default function CompanySettingsModal({ onClose }) {
  const [formData, setFormData] = useState({
    name: '',
    legal_name: '',
    representative_name: '',
    rfc: '',
    tax_regime: '',
    address: '',
    zip_code: '',
    email: '',
    phone: '',
    website: ''
  });
  
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });

  useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = async () => {
    try {
      setLoading(true);
      const response = await projectsAPI.getCompanySettings();
      const data = Array.isArray(response.data) ? response.data[0] : response.data;
      if (data) {
        setFormData({
          name: data.name || '',
          legal_name: data.legal_name || '',
          representative_name: data.representative_name || '',
          rfc: data.rfc || '',
          tax_regime: data.tax_regime || '',
          address: data.address || '',
          zip_code: data.zip_code || '',
          email: data.email || '',
          phone: data.phone || '',
          website: data.website || ''
        });
      }
    } catch (error) {
      console.error("Error loading company settings:", error);
      setMessage({ type: 'danger', text: 'Error al cargar la configuración.' });
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setMessage({ type: '', text: '' });

    try {
      await projectsAPI.updateCompanySettings(formData);
      setMessage({ type: 'success', text: 'Configuración guardada correctamente.' });
      setTimeout(() => {
        onClose();
      }, 1500);
    } catch (error) {
      console.error("Error updating company settings:", error);
      setMessage({ type: 'danger', text: 'Ocurrió un error al guardar los datos.' });
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex justify-center items-center z-50 p-4">
      <div className="bg-white rounded-xl w-full max-w-4xl max-h-[90vh] overflow-y-auto shadow-2xl flex flex-col">
        
        <div className="sticky top-0 bg-white z-10 px-8 py-6 border-b border-gray-100 flex justify-between items-center">
          <div>
            <h4 className="text-2xl font-bold text-gray-800 flex items-center gap-2">
              <span>🏢</span> Configuración de la Empresa (Desarrollador)
            </h4>
            <p className="text-gray-500 text-sm mt-1 mb-0">
              Información por defecto para generación de contratos y documentación legal.
            </p>
          </div>
          <button 
            className="text-gray-400 hover:text-gray-700 transition-colors p-2 rounded-full hover:bg-gray-100" 
            onClick={onClose}
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div className="p-8">
          {message.text && (
            <div className={`p-4 rounded-lg mb-6 ${message.type === 'success' ? 'bg-green-50 text-green-800 border border-green-200' : 'bg-red-50 text-red-800 border border-red-200'}`}>
              {message.text}
            </div>
          )}

          {loading ? (
            <div className="flex justify-center items-center py-12">
              <div className="w-12 h-12 border-4 border-gray-200 border-t-blue-600 rounded-full animate-spin"></div>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-6">
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Nombre Comercial</label>
                  <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="name" value={formData.name} onChange={handleChange} required placeholder="Ej. Maewallis Corp" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Razón Social (Legal)</label>
                  <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="legal_name" value={formData.legal_name} onChange={handleChange} required />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Representante Legal (Firma por defecto)</label>
                  <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="representative_name" value={formData.representative_name} onChange={handleChange} />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">RFC</label>
                  <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="rfc" value={formData.rfc} onChange={handleChange} />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-12 gap-6">
                <div className="md:col-span-8">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Régimen Fiscal</label>
                  <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="tax_regime" value={formData.tax_regime} onChange={handleChange} />
                </div>
                <div className="md:col-span-4">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Código Postal</label>
                  <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="zip_code" value={formData.zip_code} onChange={handleChange} />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Dirección Fiscal</label>
                <textarea className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="address" value={formData.address} onChange={handleChange} rows="2"></textarea>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Correo de Contacto</label>
                  <input type="email" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="email" value={formData.email} onChange={handleChange} />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Teléfono</label>
                  <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="phone" value={formData.phone} onChange={handleChange} />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Sitio Web</label>
                  <input type="url" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="website" value={formData.website} onChange={handleChange} />
                </div>
              </div>

              <div className="flex justify-end gap-3 mt-8 pt-6 border-t border-gray-100">
                <button 
                  type="button" 
                  className="px-6 py-2.5 rounded-lg font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 transition-colors" 
                  onClick={onClose} 
                  disabled={saving}
                >
                  Cancelar
                </button>
                <button 
                  type="submit" 
                  className="px-6 py-2.5 rounded-lg font-medium text-white bg-blue-600 hover:bg-blue-700 transition-colors shadow-md shadow-blue-500/30 flex items-center gap-2" 
                  disabled={saving}
                >
                  {saving ? (
                    <>
                      <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                      Guardando...
                    </>
                  ) : (
                    'Guardar Configuración'
                  )}
                </button>
              </div>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
