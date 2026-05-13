#!/bin/bash

# Script completo para configurar frontend de PIAP
# Ejecutar desde: /Users/edegantea/development/maewalliscorp/gestionproyectos/frontend/

echo "🚀 Configurando frontend completo de PIAP..."

# Crear estructura de directorios
echo "📁 Creando estructura de directorios..."
mkdir -p src/pages
mkdir -p src/stores
mkdir -p src/services

# 1. Crear authStore.js
echo "🗄️ Creando authStore.js..."
cat > src/stores/authStore.js << 'EOF'
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import api from '../services/api';

export const useAuthStore = create(
  persist(
    (set) => ({
      user: null,
      token: null,
      isAuthenticated: false,

      login: async (username, password) => {
        try {
          const response = await api.post('/auth/login/', {
            username,
            password
          });

          const { access, refresh, user } = response.data;

          set({
            user,
            token: access,
            isAuthenticated: true
          });

          localStorage.setItem('refreshToken', refresh);
          return response.data;
        } catch (error) {
          console.error('Login error:', error);
          throw new Error(
            error.response?.data?.detail || 
            'Error al iniciar sesión. Verifica tus credenciales.'
          );
        }
      },

      logout: () => {
        localStorage.removeItem('refreshToken');
        set({
          user: null,
          token: null,
          isAuthenticated: false
        });
      }
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        isAuthenticated: state.isAuthenticated
      })
    }
  )
);
EOF

# 2. Crear api.js
echo "🌐 Creando api.js..."
cat > src/services/api.js << 'EOF'
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8000/api',
  headers: {
    'Content-Type': 'application/json'
  }
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = localStorage.getItem('refreshToken');
        const response = await axios.post(
          'http://localhost:8000/api/auth/token/refresh/',
          { refresh: refreshToken }
        );

        const { access } = response.data;
        localStorage.setItem('token', access);

        originalRequest.headers.Authorization = `Bearer ${access}`;
        return api(originalRequest);
      } catch (refreshError) {
        localStorage.removeItem('token');
        localStorage.removeItem('refreshToken');
        window.location.href = '/';
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default api;
EOF

# 3. Crear LoginPage.jsx
echo "📄 Creando LoginPage.jsx..."
cat > src/pages/LoginPage.jsx << 'EOF'
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import './LoginPage.css';

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
    <div className="login-container">
      <div className="login-card">
        <div className="login-header">
          <h1>PIAP</h1>
          <p>Plataforma Interna de Administración de Proyectos</p>
        </div>
        
        <form onSubmit={handleSubmit} className="login-form">
          {error && <div className="error-message">{error}</div>}
          
          <div className="form-group">
            abel htmlFor="username">Usuario</label>
            <input
              id="username"
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="Ingresa tu usuario"
              required
              disabled={loading}
            />
          </div>

          <div className="form-group">
            abel htmlFor="password">Contraseña</label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Ingresa tu contraseña"
              required
              disabled={loading}
            />
          </div>

          <button type="submit" className="login-button" disabled={loading}>
            {loading ? 'Iniciando sesión...' : 'Iniciar Sesión'}
          </button>
        </form>
      </div>
    </div>
  );
}
EOF

# 4. Crear LoginPage.css
echo "🎨 Creando LoginPage.css..."
cat > src/pages/LoginPage.css << 'EOF'
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-card {
  background: white;
  border-radius: 10px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 400px;
  padding: 40px;
}

.login-header {
  text-align: center;
  margin-bottom: 30px;
}

.login-header h1 {
  font-size: 2.5rem;
  color: #667eea;
  margin-bottom: 10px;
}

.login-header p {
  color: #666;
  font-size: 0.9rem;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  font-weight: 600;
  color: #333;
  font-size: 0.9rem;
}

.form-group input {
  padding: 12px;
  border: 2px solid #e0e0e0;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.3s;
}

.form-group input:focus {
  outline: none;
  border-color: #667eea;
}

.form-group input:disabled {
  background-color: #f5f5f5;
  cursor: not-allowed;
}

.login-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 14px;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

.login-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.login-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error-message {
  background-color: #fee;
  color: #c33;
  padding: 12px;
  border-radius: 6px;
  border-left: 4px solid #c33;
  font-size: 0.9rem;
}
EOF

# 5. Crear DashboardPage.jsx
echo "📄 Creando DashboardPage.jsx..."
cat > src/pages/DashboardPage.jsx << 'EOF'
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import './DashboardPage.css';

export default function DashboardPage() {
  const navigate = useNavigate();
  const { user, logout } = useAuthStore();

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <div className="dashboard-container">
      <header className="dashboard-header">
        <div className="header-content">
          <h1>PIAP - Dashboard</h1>
          <div className="user-info">
            <span>Bienvenido, {user?.username || 'Usuario'}</span>
            <button onClick={handleLogout} className="logout-button">
              Cerrar Sesión
            </button>
          </div>
        </div>
      </header>

      <main className="dashboard-main">
        <div className="dashboard-grid">
          <div className="dashboard-card">
            <h2>📊 Proyectos</h2>
            <p className="card-number">0</p>
            <p className="card-description">Proyectos activos</p>
          </div>

          <div className="dashboard-card">
            <h2>✅ Tareas</h2>
            <p className="card-number">0</p>
            <p className="card-description">Tareas pendientes</p>
          </div>

          <div className="dashboard-card">
            <h2>👥 Equipo</h2>
            <p className="card-number">0</p>
            <p className="card-description">Miembros activos</p>
          </div>

          <div className="dashboard-card">
            <h2>⚠️ Incidencias</h2>
            <p className="card-number">0</p>
            <p className="card-description">Incidencias abiertas</p>
          </div>
        </div>

        <div className="welcome-section">
          <h2>Bienvenido a PIAP</h2>
          <p>
            Plataforma Interna de Administración de Proyectos - Tu herramienta centralizada
            para gestionar proyectos, tareas, equipos y mucho más.
          </p>
          <p className="info-text">
            Release 0 - Sprint 0 | MVP en construcción
          </p>
        </div>
      </main>
    </div>
  );
}
EOF

# 6. Crear DashboardPage.css
echo "🎨 Creando DashboardPage.css..."
cat > src/pages/DashboardPage.css << 'EOF'
.dashboard-container {
  min-height: 100vh;
  background-color: #f5f7fa;
}

.dashboard-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px 0;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-content h1 {
  font-size: 1.8rem;
  margin: 0;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.logout-button {
  background-color: rgba(255, 255, 255, 0.2);
  color: white;
  border: 1px solid white;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.logout-button:hover {
  background-color: rgba(255, 255, 255, 0.3);
}

.dashboard-main {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 40px;
}

.dashboard-card {
  background: white;
  border-radius: 10px;
  padding: 30px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s, box-shadow 0.3s;
}

.dashboard-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
}

.dashboard-card h2 {
  font-size: 1.2rem;
  margin-bottom: 15px;
  color: #333;
}

.card-number {
  font-size: 3rem;
  font-weight: bold;
  color: #667eea;
  margin: 10px 0;
}

.card-description {
  color: #666;
  font-size: 0.9rem;
}

.welcome-section {
  background: white;
  border-radius: 10px;
  padding: 40px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.welcome-section h2 {
  color: #667eea;
  margin-bottom: 15px;
}

.welcome-section p {
  color: #666;
  line-height: 1.6;
  margin-bottom: 10px;
}

.info-text {
  font-style: italic;
  color: #999;
  font-size: 0.9rem;
}
EOF

# 7. Actualizar App.jsx
echo "⚛️ Actualizando App.jsx..."
cat > src/App.jsx << 'EOF'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useAuthStore } from './stores/authStore';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';

function PrivateRoute({ children }) {
  const isAuthenticated = useAuthStore(state => state.isAuthenticated);
  return isAuthenticated ? children : <Navigate to="/" />;
}

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<LoginPage />} />
        <Route 
          path="/dashboard" 
          element={
            <PrivateRoute>
              <DashboardPage />
            </PrivateRoute>
          } 
        />
      </Routes>
    </Router>
  );
}

export default App;
EOF

# 8. Actualizar index.css
echo "🎨 Actualizando index.css..."
cat > src/index.css << 'EOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}

#root {
  min-height: 100vh;
}
EOF

echo ""
echo "✅ ¡Todos los archivos creados exitosamente!"
echo ""
echo "Verifica que tengas instaladas las dependencias:"
echo "  npm install react-router-dom zustand axios"
echo ""
echo "Luego inicia el servidor:"
echo "  npm run dev"