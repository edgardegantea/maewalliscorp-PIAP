import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';

export default function LoginPage() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  
  const navigate = useNavigate();
  const login = useAuthStore(state => state.login);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await login(username, password);
      navigate('/dashboard');
    } catch (err) {
      setError(err.message || 'Error al iniciar sesión');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-800 to-slate-900 p-5">
      <div className="bg-white rounded-xl shadow-xl w-full max-w-md p-10">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-blue-700 mb-2">PIAP</h1>
          <p className="text-gray-500 text-sm">Plataforma Interna de Administración de Proyectos</p>
        </div>
        
        <form onSubmit={handleSubmit} className="flex flex-col gap-5">
          {error && <div className="bg-red-50 text-red-600 p-3 rounded-md border-l-4 border-red-600 text-sm">{error}</div>}
          
          <div className="flex flex-col gap-2">
            <label htmlFor="username" className="font-semibold text-gray-800 text-sm">Usuario</label>
            <input
              id="username"
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="Ingresa tu usuario"
              required
              disabled={loading}
              className="p-3 border-2 border-gray-200 rounded-md text-base transition-colors focus:outline-none focus:border-blue-700 disabled:bg-gray-100 disabled:cursor-not-allowed"
            />
          </div>

          <div className="flex flex-col gap-2">
            <label htmlFor="password" className="font-semibold text-gray-800 text-sm">Contraseña</label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Ingresa tu contraseña"
              required
              disabled={loading}
              className="p-3 border-2 border-gray-200 rounded-md text-base transition-colors focus:outline-none focus:border-blue-700 disabled:bg-gray-100 disabled:cursor-not-allowed"
            />
          </div>

          <div className="text-right -mt-2">
            <Link to="/forgot-password" className="text-blue-700 text-sm hover:underline">¿Olvidaste tu contraseña?</Link>
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="bg-gradient-to-br from-slate-800 to-slate-900 text-white border-none p-3.5 rounded-md text-base font-semibold cursor-pointer transition-all hover:-translate-y-0.5 hover:shadow-lg hover:shadow-blue-700/40 disabled:opacity-60 disabled:cursor-not-allowed disabled:transform-none disabled:shadow-none"
          >
            {loading ? 'Iniciando sesión...' : 'Iniciar Sesión'}
          </button>

          <div className="text-center text-gray-500 text-sm mt-2">
            ¿No tienes cuenta? <Link to="/register" className="text-blue-700 font-semibold hover:underline">Regístrate aquí</Link>
          </div>
        </form>
      </div>
    </div>
  );
}
