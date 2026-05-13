import { useState } from 'react';
import { Link } from 'react-router-dom';
import { authAPI } from '../services/api';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await authAPI.requestPasswordReset(email);
      setSuccess(true);
    } catch (err) {
      setError(err.response?.data?.detail || 'Error al solicitar recuperación de contraseña.');
    } finally {
      setLoading(false);
    }
  };

  if (success) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-800 to-slate-900 p-5">
        <div className="bg-white rounded-xl shadow-xl w-full max-w-md p-10 text-center">
          <div className="w-16 h-16 bg-green-100 text-green-600 rounded-full flex items-center justify-center text-3xl mx-auto mb-6">✓</div>
          <h1 className="text-2xl font-bold text-gray-800 mb-4">Email Enviado</h1>
          <p className="text-green-700 bg-green-50 p-4 rounded-md mb-4 text-sm">
            Si el email está registrado en nuestro sistema, recibirás instrucciones
            para recuperar tu contraseña.
          </p>
          <p className="text-gray-500 text-sm mb-8">
            Revisa tu bandeja de entrada y la carpeta de spam.
          </p>
          <Link to="/" className="inline-block bg-blue-700 text-white px-6 py-3 rounded-md font-semibold transition-all hover:bg-blue-800 hover:-translate-y-0.5 shadow-md hover:shadow-lg">
            Volver al inicio de sesión
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-800 to-slate-900 p-5">
      <div className="bg-white rounded-xl shadow-xl w-full max-w-md p-10">
        <div className="text-center mb-8">
          <h1 className="text-2xl font-bold text-blue-700 mb-2">¿Olvidaste tu contraseña?</h1>
          <p className="text-gray-500 text-sm">Ingresa tu email y te enviaremos instrucciones para recuperarla.</p>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-6">
          {error && <div className="bg-red-50 text-red-600 p-3 rounded-md border-l-4 border-red-600 text-sm">{error}</div>}

          <div className="flex flex-col gap-2">
            <label htmlFor="email" className="font-semibold text-gray-800 text-sm">Email</label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="correo@ejemplo.com"
              required
              disabled={loading}
              className="p-3 border-2 border-gray-200 rounded-md text-base focus:outline-none focus:border-blue-700 transition-colors disabled:bg-gray-100 disabled:cursor-not-allowed"
            />
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="bg-blue-700 text-white p-3.5 rounded-md text-base font-semibold cursor-pointer transition-all hover:-translate-y-0.5 shadow-md hover:shadow-lg disabled:opacity-60 disabled:cursor-not-allowed"
          >
            {loading ? 'Enviando...' : 'Enviar instrucciones'}
          </button>

          <Link to="/" className="text-center text-blue-700 text-sm font-semibold hover:underline mt-2">
            ← Volver al inicio de sesión
          </Link>
        </form>
      </div>
    </div>
  );
}
