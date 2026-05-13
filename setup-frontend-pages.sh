#!/bin/bash

cd /Users/edegantea/development/maewalliscorp/gestionproyectos/frontend

echo "🎨 Creando páginas del frontend..."

# 1. Crear LoginPage.jsx
cat > src/pages/LoginPage.jsx << 'EOF'
import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import './LoginPage.css';

const LoginPage = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const { login, loading, error, clearError } = useAuthStore();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    clearError();
    try {
      await login(username, password);
      navigate('/dashboard');
    } catch (err) {
      console.error('Login error:', err);
    }
  };

  return (
    <div className="login-container">
      <div className="login-box">
        <div className="login-header">
          <h1>PIAP</h1>
          <p>Plataforma Interna de Administración de Proyectos</p>
        </div>

        <form onSubmit={handleSubmit} className="login-form">
          <div className="form-group">
            abel htmlFor="username">Usuario</label>
            <input
              type="text"
              id="username"
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
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Ingresa tu contraseña"
              required
              disabled={loading}
            />
          </div>

          {error && (
            <div className="error-message">
              {typeof error === 'string' ? error : 'Error al iniciar sesión'}
            </div>
          )}

          <button type="submit" disabled={loading} className="login-button">
            {loading ? 'Iniciando sesión...' : 'Iniciar Sesión'}
          </button>
        </form>

        <div className="login-footer">
          <p>¿No tienes cuenta? <Link to="/register">Registrarse</Link></p>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
EOF

echo "✅ Creado: src/pages/LoginPage.jsx"

# 2. Crear LoginPage.css
cat > src/pages/LoginPage.css << 'EOF'
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-box {
  background: white;
  border-radius: 12px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  padding: 40px;
  width: 100%;
  max-width: 420px;
}

.login-header {
  text-align: center;
  margin-bottom: 32px;
}

.login-header h1 {
  font-size: 32px;
  font-weight: 700;
  color: #333;
  margin-bottom: 8px;
}

.login-header p {
  font-size: 14px;
  color: #666;
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
  font-size: 14px;
  font-weight: 500;
  color: #333;
}

.form-group input {
  padding: 12px 16px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 14px;
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

.error-message {
  background-color: #fee;
  border: 1px solid #fcc;
  color: #c33;
  padding: 12px;
  border-radius: 8px;
  font-size: 14px;
}

.login-button {
  padding: 14px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

.login-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(102, 126, 234, 0.4);
}

.login-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.login-footer {
  text-align: center;
  margin-top: 24px;
  font-size: 14px;
  color: #666;
}

.login-footer a {
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
}

.login-footer a:hover {
  text-decoration: underline;
}
EOF

echo "✅ Creado: src/pages/LoginPage.css"

# 3. Crear DashboardPage.jsx
cat > src/pages/DashboardPage.jsx << 'EOF'
import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import './DashboardPage.css';

const DashboardPage = () => {
  const { user, logout, isAuthenticated } = useAuthStore();
  const navigate = useNavigate();

  useEffect(() => {
    if (!isAuthenticated) {
      navigate('/login');
    }
  }, [isAuthenticated, navigate]);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const getRoleName = (role) => {
    const roles = {
      'ADMIN': 'Administrador',
      'DIRECTOR': 'Director',
      'PM': 'Project Manager',
      'TEAM_MEMBER': 'Miembro del equipo'
    };
    return roles[role] || role;
  };

  return (
    <div className="dashboard-container">
      <nav className="dashboard-navbar">
        <div className="navbar-brand">
          <h1>PIAP</h1>
        </div>
        <div className="navbar-user">
          <span className="user-name">{user?.full_name || user?.username}</span>
          <button onClick={handleLogout} className="logout-button">
            Cerrar Sesión
          </button>
        </div>
      </nav>

      <main className="dashboard-content">
        <div className="welcome-section">
          <h2>Bienvenido, {user?.full_name || user?.username}</h2>
          <div className="user-info-card">
            <div className="info-item">
              abel>Usuario:</label>
              <span>{user?.username}</span>
            </div>
            <div className="info-item">
              abel>Email:</label>
              <span>{user?.email}</span>
            </div>
            <div className="info-item">
              abel>Rol:</label>
              <span className="role-badge">{getRoleName(user?.role)}</span>
            </div>
            <div className="info-item">
              abel>Estado:</label>
              <span className={`status-badge ${user?.is_active ? 'active' : 'inactive'}`}>
                {user?.is_active ? 'Activo' : 'Inactivo'}
              </span>
            </div>
          </div>
        </div>

        <div className="status-section">
          <h3>🎉 Release 0 - Sprint 0 Completado</h3>
          <div className="status-grid">
            <div className="status-card">
              <div className="status-icon">✓</div>
              <h4>Backend Django</h4>
              <p>API REST + MySQL configurado</p>
            </div>
            <div className="status-card">
              <div className="status-icon">✓</div>
              <h4>Frontend React</h4>
              <p>Vite + Zustand configurado</p>
            </div>
            <div className="status-card">
              <div className="status-icon">✓</div>
              <h4>Autenticación JWT</h4>
              <p>Login y registro funcional</p>
            </div>
            <div className="status-card">
              <div className="status-icon">✓</div>
              <h4>Base Técnica</h4>
              <p>Proyecto listo para desarrollo</p>
            </div>
          </div>
        </div>

        <div className="next-steps-section">
          <h3>📋 Próximos Pasos</h3>
          <ul className="next-steps-list">
            >Release 1 - MVP Core: Gestión básica de proyectos</li>
            >Implementar CRUD de proyectos</li>
            >Sistema de tareas y sprints</li>
            >Dashboard de métricas</li>
            >Gestión de usuarios y permisos</li>
          </ul>
        </div>
      </main>
    </div>
  );
};

export default DashboardPage;
EOF

echo "✅ Creado: src/pages/DashboardPage.jsx"

# 4. Crear DashboardPage.css
cat > src/pages/DashboardPage.css << 'EOF'
.dashboard-container {
  min-height: 100vh;
  background-color: #f5f7fa;
}

.dashboard-navbar {
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 16px 32px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.navbar-brand h1 {
  font-size: 24px;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.navbar-user {
  display: flex;
  align-items: center;
  gap: 16px;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
}

.logout-button {
  padding: 8px 16px;
  background-color: #dc3545;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.3s;
}

.logout-button:hover {
  background-color: #c82333;
}

.dashboard-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 32px;
}

.welcome-section {
  margin-bottom: 32px;
}

.welcome-section h2 {
  font-size: 28px;
  font-weight: 700;
  color: #333;
  margin-bottom: 20px;
}

.user-info-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.info-item label {
  font-size: 12px;
  font-weight: 600;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.info-item span {
  font-size: 14px;
  color: #333;
}

.role-badge {
  display: inline-block;
  padding: 4px 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 600;
}

.status-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 600;
}

.status-badge.active {
  background-color: #d4edda;
  color: #155724;
}

.status-badge.inactive {
  background-color: #f8d7da;
  color: #721c24;
}

.status-section {
  margin-bottom: 32px;
}

.status-section h3 {
  font-size: 20px;
  font-weight: 700;
  color: #333;
  margin-bottom: 20px;
}

.status-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.status-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  text-align: center;
  transition: transform 0.3s, box-shadow 0.3s;
}

.status-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
}

.status-icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  margin: 0 auto 16px;
}

.status-card h4 {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
}

.status-card p {
  font-size: 14px;
  color: #666;
}

.next-steps-section {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.next-steps-section h3 {
  font-size: 20px;
  font-weight: 700;
  color: #333;
  margin-bottom: 16px;
}

.next-steps-list {
  list-style: none;
  padding: 0;
}

.next-steps-list li {
  padding: 12px;
  border-bottom: 1px solid #e0e0e0;
  color: #555;
  font-size: 14px;
}

.next-steps-list li:last-child {
  border-bottom: none;
}

.next-steps-list li::before {
  content: "→ ";
  color: #667eea;
  font-weight: 700;
  margin-right: 8px;
}
EOF

echo "✅ Creado: src/pages/DashboardPage.css"

# 5. Actualizar App.jsx
cat > src/App.jsx << 'EOF'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import { useAuthStore } from './stores/authStore';

const ProtectedRoute = ({ children }) => {
  const { isAuthenticated } = useAuthStore();
  return isAuthenticated ? children : <Navigate to="/login" />;
};

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <DashboardPage />
            </ProtectedRoute>
          }
        />
        <Route path="/" element={<Navigate to="/dashboard" />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
EOF

echo "✅ Actualizado: src/App.jsx"

# 6. Actualizar index.css
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
EOF

echo "✅ Actualizado: src/index.css"

echo ""
echo "🎉 ¡Frontend completo creado!"
echo ""
echo "📋 Para ejecutar:"
echo "1. npm run dev"
echo "2. Abrir http://localhost:5173"
echo "3. Iniciar sesión con tu usuario"