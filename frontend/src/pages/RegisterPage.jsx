import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';

export default function RegisterPage() {
  const navigate = useNavigate();
  const register = useAuthStore(state => state.register);
  
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    password_confirm: '',
    first_name: '',
    last_name: '',
    phone: '',
    position: '',
    department: ''
  });
  
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: null }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrors({});
    setLoading(true);

    try {
      await register(formData);
      navigate('/dashboard');
    } catch (error) {
      if (error.response?.data) {
        setErrors(error.response.data);
      } else {
        setErrors({ general: 'Error al registrar usuario. Intenta nuevamente.' });
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-800 to-slate-900 p-5 py-10">
      <div className="bg-white rounded-xl shadow-xl w-full max-w-2xl p-8 sm:p-10">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-blue-700 mb-2">Crear Cuenta</h1>
          <p className="text-gray-500 text-sm">Plataforma Interna de Administración de Proyectos</p>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-6">
          {errors.general && (
            <div className="bg-red-50 text-red-600 p-3 rounded-md border-l-4 border-red-600 text-sm">
              {errors.general}
            </div>
          )}

          <div className="flex flex-col sm:flex-row gap-5">
            <div className="flex flex-col gap-2 flex-1">
              <label htmlFor="username" className="font-semibold text-gray-800 text-sm">Usuario *</label>
              <input
                id="username"
                name="username"
                type="text"
                value={formData.username}
                onChange={handleChange}
                placeholder="Nombre de usuario"
                required
                disabled={loading}
                className="p-3 border-2 border-gray-200 rounded-md text-base transition-colors focus:outline-none focus:border-blue-700 disabled:bg-gray-100 disabled:cursor-not-allowed"
              />
              {errors.username && <span className="text-red-500 text-xs mt-1">{errors.username}</span>}
            </div>

            <div className="flex flex-col gap-2 flex-1">
              <label htmlFor="email" className="font-semibold text-gray-800 text-sm">Email *</label>
              <input
                id="email"
                name="email"
                type="email"
                value={formData.email}
                onChange={handleChange}
                placeholder="correo@ejemplo.com"
                required
                disabled={loading}
                className="p-3 border-2 border-gray-200 rounded-md text-base transition-colors focus:outline-none focus:border-blue-700 disabled:bg-gray-100 disabled:cursor-not-allowed"
              />
              {errors.email && <span className="text-red-500 text-xs mt-1">{errors.email}</span>}
            </div>
          </div>

          <div className="flex flex-col sm:flex-row gap-5">
            <div className="flex flex-col gap-2 flex-1">
              <label htmlFor="first_name" className="font-semibold text-gray-800 text-sm">Nombre</label>
              <input
                id="first_name"
                name="first_name"
                type="text"
                value={formData.first_name}
                onChange={handleChange}
                placeholder="Nombre"
                disabled={loading}
                className="p-3 border-2 border-gray-200 rounded-md text-base transition-colors focus:outline-none focus:border-blue-700 disabled:bg-gray-100 disabled:cursor-not-allowed"
              />
            </div>

            <div className="flex flex-col gap-2 flex-1">
              <label htmlFor="last_name" className="font-semibold text-gray-800 text-sm">Apellido</label>
              <input
                id="last_name"
                name="last_name"
                type="text"
                value={formData.last_name}
                onChange={handleChange}
                placeholder="Apellido"
                disabled={loading}
                className="p-3 border-2 border-gray-200 rounded-md text-base transition-colors focus:outline-none focus:border-blue-700 disabled:bg-gray-100 disabled:cursor-not-allowed"
              />
            </div>
          </div>

          <div className="flex flex-col sm:flex-row gap-5">
            <div className="flex flex-col gap-2 flex-1">
              <label htmlFor="password" className="font-semibold text-gray-800 text-sm">Contraseña *</label>
              <input
                id="password"
                name="password"
                type="password"
                value={formData.password}
                onChange={handleChange}
                placeholder="Mínimo 8 caracteres"
                required
                disabled={loading}
                className="p-3 border-2 border-gray-200 rounded-md text-base transition-colors focus:outline-none focus:border-blue-700 disabled:bg-gray-100 disabled:cursor-not-allowed"
              />
              {errors.password && <span className="text-red-500 text-xs mt-1">{errors.password}</span>}
            </div>

            <div className="flex flex-col gap-2 flex-1">
              <label htmlFor="password_confirm" className="font-semibold text-gray-800 text-sm">Confirmar Contraseña *</label>
              <input
                id="password_confirm"
                name="password_confirm"
                type="password"
                value={formData.password_confirm}
                onChange={handleChange}
                placeholder="Confirma tu contraseña"
                required
                disabled={loading}
                className="p-3 border-2 border-gray-200 rounded-md text-base transition-colors focus:outline-none focus:border-blue-700 disabled:bg-gray-100 disabled:cursor-not-allowed"
              />
            </div>
          </div>

          <div className="flex flex-col sm:flex-row gap-5">
            <div className="flex flex-col gap-2 flex-1">
              <label htmlFor="phone" className="font-semibold text-gray-800 text-sm">Teléfono</label>
              <input
                id="phone"
                name="phone"
                type="tel"
                value={formData.phone}
                onChange={handleChange}
                placeholder="(555) 123-4567"
                disabled={loading}
                className="p-3 border-2 border-gray-200 rounded-md text-base transition-colors focus:outline-none focus:border-blue-700 disabled:bg-gray-100 disabled:cursor-not-allowed"
              />
            </div>

            <div className="flex flex-col gap-2 flex-1">
              <label htmlFor="position" className="font-semibold text-gray-800 text-sm">Cargo</label>
              <input
                id="position"
                name="position"
                type="text"
                value={formData.position}
                onChange={handleChange}
                placeholder="Ej: Desarrollador"
                disabled={loading}
                className="p-3 border-2 border-gray-200 rounded-md text-base transition-colors focus:outline-none focus:border-blue-700 disabled:bg-gray-100 disabled:cursor-not-allowed"
              />
            </div>
          </div>

          <div className="flex flex-col gap-2">
            <label htmlFor="department" className="font-semibold text-gray-800 text-sm">Departamento</label>
            <input
              id="department"
              name="department"
              type="text"
              value={formData.department}
              onChange={handleChange}
              placeholder="Ej: Tecnología"
              disabled={loading}
              className="p-3 border-2 border-gray-200 rounded-md text-base transition-colors focus:outline-none focus:border-blue-700 disabled:bg-gray-100 disabled:cursor-not-allowed"
            />
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="bg-gradient-to-br from-slate-800 to-slate-900 text-white border-none p-3.5 rounded-md text-base font-semibold cursor-pointer transition-all hover:-translate-y-0.5 hover:shadow-lg hover:shadow-blue-700/40 disabled:opacity-60 disabled:cursor-not-allowed mt-2"
          >
            {loading ? 'Registrando...' : 'Crear Cuenta'}
          </button>

          <div className="text-center text-gray-500 text-sm mt-2">
            ¿Ya tienes cuenta? <Link to="/" className="text-blue-700 font-semibold hover:underline">Inicia sesión aquí</Link>
          </div>
        </form>
      </div>
    </div>
  );
}
