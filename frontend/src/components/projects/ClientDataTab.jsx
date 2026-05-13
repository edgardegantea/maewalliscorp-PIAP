import React, { useState, useEffect } from 'react';
import { projectsAPI } from '../../services/projectsAPI';

export default function ClientDataTab({ projectId, initialData, onUpdate }) {
  const [isEditing, setIsEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [successMsg, setSuccessMsg] = useState('');
  const [errorMsg, setErrorMsg] = useState('');

  const [formData, setFormData] = useState({
    client_name: '',
    client_representative: '',
    client_email: '',
    client_phone: '',
    client_address: '',
    client_rfc: '',
    client_tax_regime: '',
    client_cfdi_usage: '',
    client_billing_email: '',
    client_zip_code: '',
    developer_representative: '',
    project_manager_name: ''
  });

  // Si no hay nombre de cliente inicial, forzamos el modo edición por defecto
  useEffect(() => {
    if (initialData) {
      setFormData({
        client_name: initialData.client_name || '',
        client_representative: initialData.client_representative || '',
        client_email: initialData.client_email || '',
        client_phone: initialData.client_phone || '',
        client_address: initialData.client_address || '',
        client_rfc: initialData.client_rfc || '',
        client_tax_regime: initialData.client_tax_regime || '',
        client_cfdi_usage: initialData.client_cfdi_usage || '',
        client_billing_email: initialData.client_billing_email || '',
        client_zip_code: initialData.client_zip_code || '',
        developer_representative: initialData.developer_representative || '',
        project_manager_name: initialData.project_manager_name || ''
      });
      
      if (!initialData.client_name) {
        setIsEditing(true);
      }
    }
  }, [initialData]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setSuccessMsg('');
    setErrorMsg('');

    try {
      const response = await projectsAPI.updateProject(projectId, formData);
      setSuccessMsg('Datos guardados correctamente.');
      setIsEditing(false); // Volvemos al modo vista tras guardar
      if (onUpdate) {
        onUpdate(response.data);
      }
    } catch (error) {
      console.error("Error actualizando datos de cliente:", error);
      setErrorMsg('Ocurrió un error al guardar los datos.');
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
    // Si cancela, devolvemos el formulario a los datos iniciales
    if (initialData && initialData.client_name) {
      setFormData({
        client_name: initialData.client_name || '',
        client_representative: initialData.client_representative || '',
        client_email: initialData.client_email || '',
        client_phone: initialData.client_phone || '',
        client_address: initialData.client_address || '',
        client_rfc: initialData.client_rfc || '',
        client_tax_regime: initialData.client_tax_regime || '',
        client_cfdi_usage: initialData.client_cfdi_usage || '',
        client_billing_email: initialData.client_billing_email || '',
        client_zip_code: initialData.client_zip_code || '',
        developer_representative: initialData.developer_representative || '',
        project_manager_name: initialData.project_manager_name || ''
      });
      setIsEditing(false);
      setSuccessMsg('');
      setErrorMsg('');
    }
  };

  if (!isEditing) {
    return (
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 mt-6 max-w-4xl mx-auto transition-all">
        <div className="flex justify-between items-center mb-6">
          <h3 className="text-2xl font-bold text-gray-800 m-0">Detalles del Cliente y Facturación</h3>
          <button 
            className="flex items-center gap-2 px-4 py-2 border border-blue-600 text-blue-600 font-medium rounded-lg hover:bg-blue-50 transition-colors" 
            onClick={() => setIsEditing(true)}
          >
            <span>✏️</span> Modificar Datos
          </button>
        </div>
        
        {successMsg && (
          <div className="p-4 bg-green-50 text-green-800 border border-green-200 rounded-lg mb-6">
            {successMsg}
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-6">
          <div>
            <h5 className="text-lg font-semibold text-gray-800 border-b border-gray-200 pb-3 mb-4">Responsables (Nuestra Empresa)</h5>
            <div className="space-y-4">
              <div>
                <span className="block text-sm font-medium text-gray-500 mb-1">Representante Legal</span>
                <span className="text-gray-900">{formData.developer_representative || <span className="text-gray-400 italic">No especificado</span>}</span>
              </div>
              <div>
                <span className="block text-sm font-medium text-gray-500 mb-1">Responsable del Proyecto</span>
                <span className="text-gray-900">{formData.project_manager_name || <span className="text-gray-400 italic">No especificado</span>}</span>
              </div>
            </div>

            <h5 className="text-lg font-semibold text-gray-800 border-b border-gray-200 pb-3 mb-4 mt-8">Información General</h5>
            <div className="space-y-4">
              <div>
                <span className="block text-sm font-medium text-gray-500 mb-1">Empresa o Cliente</span>
                <span className="text-gray-900">{formData.client_name || <span className="text-gray-400 italic">No especificado</span>}</span>
              </div>
              <div>
                <span className="block text-sm font-medium text-gray-500 mb-1">Representante Legal</span>
                <span className="text-gray-900">{formData.client_representative || <span className="text-gray-400 italic">No especificado</span>}</span>
              </div>
              <div>
                <span className="block text-sm font-medium text-gray-500 mb-1">Correo de Contacto</span>
                <span className="text-gray-900">{formData.client_email || <span className="text-gray-400 italic">No especificado</span>}</span>
              </div>
              <div>
                <span className="block text-sm font-medium text-gray-500 mb-1">Teléfono</span>
                <span className="text-gray-900">{formData.client_phone || <span className="text-gray-400 italic">No especificado</span>}</span>
              </div>
              <div>
                <span className="block text-sm font-medium text-gray-500 mb-1">Dirección</span>
                <span className="text-gray-900">{formData.client_address || <span className="text-gray-400 italic">No especificado</span>}</span>
              </div>
            </div>
          </div>
          
          <div>
            <h5 className="text-lg font-semibold text-gray-800 border-b border-gray-200 pb-3 mb-4">Datos de Facturación</h5>
            <div className="space-y-4">
              <div>
                <span className="block text-sm font-medium text-gray-500 mb-1">RFC</span>
                <span className="text-gray-900 font-mono">{formData.client_rfc || <span className="text-gray-400 italic font-sans">No especificado</span>}</span>
              </div>
              <div>
                <span className="block text-sm font-medium text-gray-500 mb-1">Régimen Fiscal</span>
                <span className="text-gray-900">{formData.client_tax_regime || <span className="text-gray-400 italic">No especificado</span>}</span>
              </div>
              <div>
                <span className="block text-sm font-medium text-gray-500 mb-1">Uso de CFDI</span>
                <span className="text-gray-900">{formData.client_cfdi_usage || <span className="text-gray-400 italic">No especificado</span>}</span>
              </div>
              <div>
                <span className="block text-sm font-medium text-gray-500 mb-1">Código Postal</span>
                <span className="text-gray-900">{formData.client_zip_code || <span className="text-gray-400 italic">No especificado</span>}</span>
              </div>
              <div>
                <span className="block text-sm font-medium text-gray-500 mb-1">Correo de Facturación</span>
                <span className="text-gray-900">{formData.client_billing_email || <span className="text-gray-400 italic">No especificado</span>}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 mt-6 max-w-4xl mx-auto transition-all">
      <h3 className="text-2xl font-bold text-gray-800 mb-2">Modificar Datos del Cliente</h3>
      <p className="text-gray-500 mb-8">Ingresa la información general y fiscal del cliente para la generación de contratos y facturación.</p>
      
      {errorMsg && (
        <div className="p-4 bg-red-50 text-red-800 border border-red-200 rounded-lg mb-6">
          {errorMsg}
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        <div>
          <h5 className="text-lg font-semibold text-gray-800 border-b border-gray-200 pb-2 mb-4">Responsables (Nuestra Empresa)</h5>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Representante Legal (Firma Contratos)</label>
              <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="developer_representative" value={formData.developer_representative} onChange={handleChange} placeholder="Ej. Edgar Degante Aguilar" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Responsable del Proyecto</label>
              <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="project_manager_name" value={formData.project_manager_name} onChange={handleChange} placeholder="Ej. Ana Gómez" />
            </div>
          </div>
        </div>

        <div>
          <h5 className="text-lg font-semibold text-gray-800 border-b border-gray-200 pb-2 mb-4 mt-8">Información General del Cliente</h5>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Nombre de la Empresa o Cliente</label>
              <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="client_name" value={formData.client_name} onChange={handleChange} placeholder="Ej. Acme Corp S.A. de C.V." />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Representante Legal o Apoderado</label>
              <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="client_representative" value={formData.client_representative} onChange={handleChange} placeholder="Ej. Juan Pérez" />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Correo de Contacto</label>
              <input type="email" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="client_email" value={formData.client_email} onChange={handleChange} placeholder="contacto@empresa.com" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Teléfono</label>
              <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="client_phone" value={formData.client_phone} onChange={handleChange} placeholder="55 1234 5678" />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Dirección</label>
            <textarea className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="client_address" value={formData.client_address} onChange={handleChange} rows="2" placeholder="Calle, Número, Colonia, C.P., Ciudad"></textarea>
          </div>
        </div>

        <div>
          <h5 className="text-lg font-semibold text-gray-800 border-b border-gray-200 pb-2 mb-4 mt-8">Datos de Facturación</h5>
          <div className="grid grid-cols-1 md:grid-cols-12 gap-6 mb-6">
            <div className="md:col-span-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">RFC</label>
              <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all font-mono uppercase" name="client_rfc" value={formData.client_rfc} onChange={handleChange} placeholder="ABC123456T1" />
            </div>
            <div className="md:col-span-8">
              <label className="block text-sm font-medium text-gray-700 mb-1">Régimen Fiscal</label>
              <select className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all bg-white" name="client_tax_regime" value={formData.client_tax_regime} onChange={handleChange}>
                <option value="">Selecciona un Régimen...</option>
                <option value="601 - General de Ley Personas Morales">601 - General de Ley Personas Morales</option>
                <option value="605 - Sueldos y Salarios e Ingresos Asimilados a Salarios">605 - Sueldos y Salarios e Ingresos Asimilados a Salarios</option>
                <option value="606 - Arrendamiento">606 - Arrendamiento</option>
                <option value="612 - Personas Físicas con Actividades Empresariales y Profesionales">612 - Personas Físicas con Actividades Empresariales y Profesionales</option>
                <option value="616 - Sin obligaciones fiscales">616 - Sin obligaciones fiscales</option>
                <option value="626 - Régimen Simplificado de Confianza">626 - Régimen Simplificado de Confianza</option>
              </select>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Uso de CFDI</label>
              <select className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all bg-white" name="client_cfdi_usage" value={formData.client_cfdi_usage} onChange={handleChange}>
                <option value="">Selecciona Uso...</option>
                <option value="G01 - Adquisición de mercancias">G01 - Adquisición de mercancias</option>
                <option value="G03 - Gastos en general">G03 - Gastos en general</option>
                <option value="S01 - Sin efectos fiscales">S01 - Sin efectos fiscales</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Código Postal Fiscal</label>
              <input type="text" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="client_zip_code" value={formData.client_zip_code} onChange={handleChange} placeholder="00000" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Correo de Facturación</label>
              <input type="email" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" name="client_billing_email" value={formData.client_billing_email} onChange={handleChange} placeholder="facturas@empresa.com" />
            </div>
          </div>
        </div>

        <div className="flex justify-end gap-3 mt-8 pt-6 border-t border-gray-100">
          {initialData && initialData.client_name && (
            <button 
              type="button" 
              className="px-6 py-2.5 rounded-lg font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 transition-colors" 
              onClick={handleCancel} 
              disabled={saving}
            >
              Cancelar
            </button>
          )}
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
              'Guardar Datos'
            )}
          </button>
        </div>
      </form>
    </div>
  );
}
