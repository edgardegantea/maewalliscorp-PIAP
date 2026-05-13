import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import { authAPI } from '../services/api';

export default function ProfilePage() {
  const navigate = useNavigate();
  const { user, updateProfile, logout } = useAuthStore();

  const [formData, setFormData] = useState({
    first_name: user?.first_name || '',
    last_name: user?.last_name || '',
    phone: user?.phone || '',
    position: user?.position || '',
    department: user?.department || ''
  });

  const [passwordData, setPasswordData] = useState({
    old_password: '',
    new_password: '',
    new_password_confirm: ''
  });

  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState('');
  const [errors, setErrors] = useState({});
  const [showPasswordForm, setShowPasswordForm] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handlePasswordChange = (e) => {
    const { name, value } = e.target;
    setPasswordData(prev => ({ ...prev, [name]: value }));
  };

  const handleProfileSubmit = async (e) => {
    e.preventDefault();
    setErrors({});
    setSuccess('');
    setLoading(true);

    try {
      await updateProfile(formData);
      setSuccess('Perfil actualizado exitosamente');
    } catch (error) {
      if (error.response?.data) {
        setErrors(error.response.data);
      } else {
        setErrors({ general: 'Error al actualizar perfil' });
      }
    } finally {
      setLoading(false);
    }
  };

  const handlePasswordSubmit = async (e) => {
    e.preventDefault();
    setErrors({});
    setSuccess('');
    setLoading(true);

    try {
      await authAPI.changePassword(passwordData);
      setSuccess('Contraseña cambiada exitosamente');
      setPasswordData({
        old_password: '',
        new_password: '',
        new_password_confirm: ''
      });
      setShowPasswordForm(false);
    } catch (error) {
      if (error.response?.data) {
        setErrors(error.response.data);
      } else {
        setErrors({ password: 'Error al cambiar contraseña' });
      }
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-gradient-to-br from-slate-800 to-slate-900 text-white py-5 shadow-md">
        <div className="w-full mx-auto px-10 flex justify-between items-center">
          <h1 className="text-2xl font-bold m-0">Mi Perfil</h1>
          <button 
            onClick={() => navigate('/dashboard')} 
            className="bg-white/20 text-white border border-white px-4 py-2 rounded-md cursor-pointer transition-colors hover:bg-white/30 text-sm font-medium"
          >
            ← Volver al Dashboard
          </button>
        </div>
      </header>

      <main className="w-full mx-auto px-10 py-10">
        <div className="flex flex-col gap-8">
          {/* Información del usuario */}
          <div className="bg-white rounded-xl shadow-sm p-8">
            <div className="flex justify-between items-center mb-6 pb-4 border-b border-gray-200">
              <h2 className="text-xl font-bold text-gray-800 m-0">Información Personal</h2>
            </div>

            {success && <div className="bg-green-50 text-green-700 p-3 rounded-md border-l-4 border-green-500 mb-6 text-sm">{success}</div>}
            {errors.general && <div className="bg-red-50 text-red-600 p-3 rounded-md border-l-4 border-red-500 mb-6 text-sm">{errors.general}</div>}

            <form onSubmit={handleProfileSubmit} className="flex flex-col gap-5">
              <div className="flex flex-col sm:flex-row gap-5">
                <div className="flex flex-col gap-2 flex-1">
                  <label className="font-semibold text-gray-700 text-sm">Usuario</label>
                  <input type="text" value={user?.username} disabled className="p-2.5 border-2 border-gray-200 rounded-md bg-gray-100 text-gray-500 cursor-not-allowed" />
                </div>

                <div className="flex flex-col gap-2 flex-1">
                  <label className="font-semibold text-gray-700 text-sm">Email</label>
                  <input type="email" value={user?.email} disabled className="p-2.5 border-2 border-gray-200 rounded-md bg-gray-100 text-gray-500 cursor-not-allowed" />
                </div>
              </div>

              <div className="flex flex-col sm:flex-row gap-5">
                <div className="flex flex-col gap-2 flex-1">
                  <label htmlFor="first_name" className="font-semibold text-gray-700 text-sm">Nombre</label>
                  <input
                    id="first_name"
                    name="first_name"
                    type="text"
                    value={formData.first_name}
                    onChange={handleChange}
                    disabled={loading}
                    className="p-2.5 border-2 border-gray-200 rounded-md focus:outline-none focus:border-blue-700 transition-colors"
                  />
                </div>

                <div className="flex flex-col gap-2 flex-1">
                  <label htmlFor="last_name" className="font-semibold text-gray-700 text-sm">Apellido</label>
                  <input
                    id="last_name"
                    name="last_name"
                    type="text"
                    value={formData.last_name}
                    onChange={handleChange}
                    disabled={loading}
                    className="p-2.5 border-2 border-gray-200 rounded-md focus:outline-none focus:border-blue-700 transition-colors"
                  />
                </div>
              </div>

              <div className="flex flex-col sm:flex-row gap-5">
                <div className="flex flex-col gap-2 flex-1">
                  <label htmlFor="phone" className="font-semibold text-gray-700 text-sm">Teléfono</label>
                  <input
                    id="phone"
                    name="phone"
                    type="tel"
                    value={formData.phone}
                    onChange={handleChange}
                    disabled={loading}
                    className="p-2.5 border-2 border-gray-200 rounded-md focus:outline-none focus:border-blue-700 transition-colors"
                  />
                </div>

                <div className="flex flex-col gap-2 flex-1">
                  <label htmlFor="position" className="font-semibold text-gray-700 text-sm">Cargo</label>
                  <input
                    id="position"
                    name="position"
                    type="text"
                    value={formData.position}
                    onChange={handleChange}
                    disabled={loading}
                    className="p-2.5 border-2 border-gray-200 rounded-md focus:outline-none focus:border-blue-700 transition-colors"
                  />
                </div>
              </div>

              <div className="flex flex-col gap-2">
                <label htmlFor="department" className="font-semibold text-gray-700 text-sm">Departamento</label>
                <input
                  id="department"
                  name="department"
                  type="text"
                  value={formData.department}
                  onChange={handleChange}
                  disabled={loading}
                  className="p-2.5 border-2 border-gray-200 rounded-md focus:outline-none focus:border-blue-700 transition-colors"
                />
              </div>

              <button 
                type="submit" 
                disabled={loading}
                className="mt-2 bg-blue-700 text-white font-semibold py-3 px-6 rounded-md hover:bg-blue-800 transition-colors disabled:opacity-60 disabled:cursor-not-allowed"
              >
                {loading ? 'Guardando...' : 'Guardar Cambios'}
              </button>
            </form>
          </div>

          {/* Cambio de contraseña */}
          <div className="bg-white rounded-xl shadow-sm p-8">
            <div className="flex justify-between items-center mb-6 pb-4 border-b border-gray-200">
              <h2 className="text-xl font-bold text-gray-800 m-0">Seguridad</h2>
              <button
                type="button"
                onClick={() => setShowPasswordForm(!showPasswordForm)}
                className="text-blue-700 font-semibold hover:text-indigo-800 transition-colors"
              >
                {showPasswordForm ? 'Cancelar' : 'Cambiar Contraseña'}
              </button>
            </div>

            {showPasswordForm && (
              <form onSubmit={handlePasswordSubmit} className="flex flex-col gap-5 mt-4">
                {errors.password && <div className="bg-red-50 text-red-600 p-3 rounded-md border-l-4 border-red-500 mb-2 text-sm">{errors.password}</div>}

                <div className="flex flex-col gap-2">
                  <label htmlFor="old_password" className="font-semibold text-gray-700 text-sm">Contraseña Actual</label>
                  <input
                    id="old_password"
                    name="old_password"
                    type="password"
                    value={passwordData.old_password}
                    onChange={handlePasswordChange}
                    required
                    disabled={loading}
                    className="p-2.5 border-2 border-gray-200 rounded-md focus:outline-none focus:border-blue-700 transition-colors"
                  />
                  {errors.old_password && (
                    <span className="text-red-500 text-xs">{errors.old_password}</span>
                  )}
                </div>

                <div className="flex flex-col gap-2">
                  <label htmlFor="new_password" className="font-semibold text-gray-700 text-sm">Nueva Contraseña</label>
                  <input
                    id="new_password"
                    name="new_password"
                    type="password"
                    value={passwordData.new_password}
                    onChange={handlePasswordChange}
                    required
                    disabled={loading}
                    className="p-2.5 border-2 border-gray-200 rounded-md focus:outline-none focus:border-blue-700 transition-colors"
                  />
                  {errors.new_password && (
                    <span className="text-red-500 text-xs">{errors.new_password}</span>
                  )}
                </div>

                <div className="flex flex-col gap-2">
                  <label htmlFor="new_password_confirm" className="font-semibold text-gray-700 text-sm">Confirmar Nueva Contraseña</label>
                  <input
                    id="new_password_confirm"
                    name="new_password_confirm"
                    type="password"
                    value={passwordData.new_password_confirm}
                    onChange={handlePasswordChange}
                    required
                    disabled={loading}
                    className="p-2.5 border-2 border-gray-200 rounded-md focus:outline-none focus:border-blue-700 transition-colors"
                  />
                </div>

                <button 
                  type="submit" 
                  disabled={loading}
                  className="mt-2 bg-blue-700 text-white font-semibold py-3 px-6 rounded-md hover:bg-blue-800 transition-colors disabled:opacity-60 disabled:cursor-not-allowed"
                >
                  {loading ? 'Cambiando...' : 'Cambiar Contraseña'}
                </button>
              </form>
            )}
          </div>

          {/* Acciones de cuenta */}
          <div className="bg-white rounded-xl shadow-sm p-8">
            <div className="flex justify-between items-center mb-6 pb-4 border-b border-gray-200">
              <h2 className="text-xl font-bold text-gray-800 m-0">Cuenta</h2>
            </div>
            <button 
              onClick={handleLogout} 
              className="bg-red-500 text-white font-semibold py-2.5 px-6 rounded-md hover:bg-red-600 transition-colors"
            >
              Cerrar Sesión
            </button>
          </div>
        </div>
      </main>
    </div>
  );
}