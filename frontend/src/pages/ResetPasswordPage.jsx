import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import { authAPI } from '../services/api';

export default function ResetPasswordPage() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const token = searchParams.get('token');

  const [formData, setFormData] = useState({
    new_password: '',
    new_password_confirm: ''
  });
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [errors, setErrors] = useState({});

  useEffect(() => {
    if (!token) {
      navigate('/');
    }
  }, [token, navigate]);

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
      await authAPI.confirmPasswordReset({
        token,
        ...formData
      });
      setSuccess(true);
      setTimeout(() => navigate('/'), 3000);
    } catch (error) {
      if (error.response?.data) {
        setErrors(error.response.data);
      } else {
        setErrors({ general: 'Error al restablecer contraseña.' });
      }
    } finally {
      setLoading(false);
    }
  };

  if (success) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-800 to-slate-900 p-5">
        <div className="bg-white rounded-xl shadow-xl w-full max-w-md p-10 text-center">
          <div className="w-16 h-16 bg-green-100 text-green-600 rounded-full flex items-center justify-center text-3xl mx-auto mb-6">✓</div>
          <h1 className="text-2xl font-bold text-gray-800 mb-4">Contraseña Restablecida</h1>
          <p className="text-green-700 bg-green-50 p-4 rounded-md mb-4 text-sm">
            Tu contraseña ha sido restablecida exitosamente.
          </p>
          <p className="text-gray-500 text-sm">
            Serás redirigido al inicio de sesión en unos segundos...
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-800 to-slate-900 p-5">
      <div className="bg-white rounded-xl shadow-xl w-full max-w-md p-10">
        <div className="text-center mb-8">
          <h1 className="text-2xl font-bold text-blue-700 mb-2">Nueva Contraseña</h1>
          <p className="text-gray-500 text-sm">Ingresa tu nueva contraseña para tu cuenta</p>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-6">
          {(errors.general || errors.detail) && (
            <div className="bg-red-50 text-red-600 p-3 rounded-md border-l-4 border-red-600 text-sm">
              {errors.general || errors.detail}
            </div>
          )}

          <div className="flex flex-col gap-2">
            <label htmlFor="new_password" className="font-semibold text-gray-800 text-sm">Nueva Contraseña</label>
            <input
              id="new_password"
              name="new_password"
              type="password"
              value={formData.new_password}
              onChange={handleChange}
              placeholder="Mínimo 8 caracteres"
              required
              disabled={loading}
              className="p-3 border-2 border-gray-200 rounded-md text-base focus:outline-none focus:border-blue-700 transition-colors disabled:bg-gray-100"
            />
            {errors.new_password && (
              <span className="text-red-500 text-xs mt-1">{errors.new_password}</span>
            )}
          </div>

          <div className="flex flex-col gap-2">
            <label htmlFor="new_password_confirm" className="font-semibold text-gray-800 text-sm">Confirmar Contraseña</label>
            <input
              id="new_password_confirm"
              name="new_password_confirm"
              type="password"
              value={formData.new_password_confirm}
              onChange={handleChange}
              placeholder="Confirma tu nueva contraseña"
              required
              disabled={loading}
              className="p-3 border-2 border-gray-200 rounded-md text-base focus:outline-none focus:border-blue-700 transition-colors disabled:bg-gray-100"
            />
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="bg-blue-700 text-white p-3.5 rounded-md text-base font-semibold cursor-pointer transition-all hover:-translate-y-0.5 shadow-md hover:shadow-lg disabled:opacity-60 disabled:cursor-not-allowed"
          >
            {loading ? 'Restableciendo...' : 'Restablecer Contraseña'}
          </button>

          <Link to="/" className="text-center text-blue-700 text-sm font-semibold hover:underline mt-2">
            ← Volver al inicio de sesión
          </Link>
        </form>
      </div>
    </div>
  );
}
