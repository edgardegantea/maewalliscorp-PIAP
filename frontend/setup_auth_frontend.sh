#!/bin/bash

# Script para configurar el frontend completo de autenticación PIAP
# Ejecutar desde: /Users/edegantea/development/maewalliscorp/gestionproyectos/frontend/

echo "🚀 Configurando sistema completo de autenticación..."

# Crear estructura de directorios
echo "📁 Verificando estructura de directorios..."
mkdir -p src/pages
mkdir -p src/stores
mkdir -p src/services
mkdir -p src/components

# 1. Actualizar authStore.js con funcionalidades completas
echo "🗄️ Actualizando authStore.js..."
cat > src/stores/authStore.js << 'EOF'
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import api from '../services/api';

export const useAuthStore = create(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isAuthenticated: false,

      login: async (username, password) => {
        try {
          const response = await api.post('/auth/login/', {
            username,
            password
          });

          const { tokens, user } = response.data;

          set({
            user,
            token: tokens.access,
            isAuthenticated: true
          });

          localStorage.setItem('refreshToken', tokens.refresh);
          return response.data;
        } catch (error) {
          console.error('Login error:', error);
          throw new Error(
            error.response?.data?.detail || 
            'Error al iniciar sesión. Verifica tus credenciales.'
          );
        }
      },

      register: async (userData) => {
        try {
          const response = await api.post('/auth/register/', userData);
          const { tokens, user } = response.data;

          set({
            user,
            token: tokens.access,
            isAuthenticated: true
          });

          localStorage.setItem('refreshToken', tokens.refresh);
          return response.data;
        } catch (error) {
          console.error('Register error:', error);
          throw error;
        }
      },

      logout: () => {
        const refreshToken = localStorage.getItem('refreshToken');
        
        if (refreshToken) {
          api.post('/auth/logout/', { refresh: refreshToken })
            .catch(err => console.error('Logout error:', err));
        }

        localStorage.removeItem('refreshToken');
        set({
          user: null,
          token: null,
          isAuthenticated: false
        });
      },

      updateProfile: async (profileData) => {
        try {
          const response = await api.patch('/auth/profile/update/', profileData);
          set({ user: response.data.user });
          return response.data;
        } catch (error) {
          console.error('Update profile error:', error);
          throw error;
        }
      },

      refreshUserData: async () => {
        try {
          const response = await api.get('/auth/profile/');
          set({ user: response.data });
          return response.data;
        } catch (error) {
          console.error('Refresh user data error:', error);
          throw error;
        }
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

# 2. Actualizar api.js con endpoints completos
echo "🌐 Actualizando api.js..."
cat > src/services/api.js << 'EOF'
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8000/api',
  headers: {
    'Content-Type': 'application/json'
  }
});

// Interceptor para agregar el token a todas las peticiones
api.interceptors.request.use(
  (config) => {
    const authData = localStorage.getItem('auth-storage');
    if (authData) {
      try {
        const { state } = JSON.parse(authData);
        if (state?.token) {
          config.headers.Authorization = `Bearer ${state.token}`;
        }
      } catch (e) {
        console.error('Error parsing auth data:', e);
      }
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interceptor para manejar errores de respuesta
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
        
        // Actualizar token en localStorage
        const authData = localStorage.getItem('auth-storage');
        if (authData) {
          const parsed = JSON.parse(authData);
          parsed.state.token = access;
          localStorage.setItem('auth-storage', JSON.stringify(parsed));
        }

        originalRequest.headers.Authorization = `Bearer ${access}`;
        return api(originalRequest);
      } catch (refreshError) {
        localStorage.removeItem('auth-storage');
        localStorage.removeItem('refreshToken');
        window.location.href = '/';
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default api;

// Funciones auxiliares para autenticación
export const authAPI = {
  register: (data) => api.post('/auth/register/', data),
  login: (data) => api.post('/auth/login/', data),
  logout: (refresh) => api.post('/auth/logout/', { refresh }),
  changePassword: (data) => api.post('/auth/change-password/', data),
  requestPasswordReset: (email) => api.post('/auth/password-reset/request/', { email }),
  confirmPasswordReset: (data) => api.post('/auth/password-reset/confirm/', data),
  verifyEmail: (token) => api.post('/auth/verify-email/', { token }),
  getProfile: () => api.get('/auth/profile/'),
  updateProfile: (data) => api.patch('/auth/profile/update/', data),
};
EOF

# 3. Crear RegisterPage.jsx
echo "📄 Creando RegisterPage.jsx..."
cat > src/pages/RegisterPage.jsx << 'EOF'
import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import './RegisterPage.css';

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
    // Limpiar error del campo
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
    <div className="register-container">
      <div className="register-card">
        <div className="register-header">
          <h1>Crear Cuenta</h1>
          <p>Plataforma Interna de Administración de Proyectos</p>
        </div>

        <form onSubmit={handleSubmit} className="register-form">
          {errors.general && (
            <div className="error-message">{errors.general}</div>
          )}

          <div className="form-row">
            <div className="form-group">
              abel htmlFor="username">Usuario *</label>
              <input
                id="username"
                name="username"
                type="text"
                value={formData.username}
                onChange={handleChange}
                placeholder="Nombre de usuario"
                required
                disabled={loading}
              />
              {errors.username && <span className="error-text">{errors.username}</span>}
            </div>

            <div className="form-group">
              abel htmlFor="email">Email *</label>
              <input
                id="email"
                name="email"
                type="email"
                value={formData.email}
                onChange={handleChange}
                placeholder="correo@ejemplo.com"
                required
                disabled={loading}
              />
              {errors.email && <span className="error-text">{errors.email}</span>}
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              abel htmlFor="first_name">Nombre</label>
              <input
                id="first_name"
                name="first_name"
                type="text"
                value={formData.first_name}
                onChange={handleChange}
                placeholder="Nombre"
                disabled={loading}
              />
            </div>

            <div className="form-group">
              abel htmlFor="last_name">Apellido</label>
              <input
                id="last_name"
                name="last_name"
                type="text"
                value={formData.last_name}
                onChange={handleChange}
                placeholder="Apellido"
                disabled={loading}
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              abel htmlFor="password">Contraseña *</label>
              <input
                id="password"
                name="password"
                type="password"
                value={formData.password}
                onChange={handleChange}
                placeholder="Mínimo 8 caracteres"
                required
                disabled={loading}
              />
              {errors.password && <span className="error-text">{errors.password}</span>}
            </div>

            <div className="form-group">
              abel htmlFor="password_confirm">Confirmar Contraseña *</label>
              <input
                id="password_confirm"
                name="password_confirm"
                type="password"
                value={formData.password_confirm}
                onChange={handleChange}
                placeholder="Confirma tu contraseña"
                required
                disabled={loading}
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              abel htmlFor="phone">Teléfono</label>
              <input
                id="phone"
                name="phone"
                type="tel"
                value={formData.phone}
                onChange={handleChange}
                placeholder="(555) 123-4567"
                disabled={loading}
              />
            </div>

            <div className="form-group">
              abel htmlFor="position">Cargo</label>
              <input
                id="position"
                name="position"
                type="text"
                value={formData.position}
                onChange={handleChange}
                placeholder="Ej: Desarrollador"
                disabled={loading}
              />
            </div>
          </div>

          <div className="form-group">
            abel htmlFor="department">Departamento</label>
            <input
              id="department"
              name="department"
              type="text"
              value={formData.department}
              onChange={handleChange}
              placeholder="Ej: Tecnología"
              disabled={loading}
            />
          </div>

          <button type="submit" className="register-button" disabled={loading}>
            {loading ? 'Registrando...' : 'Crear Cuenta'}
          </button>

          <div className="login-link">
            ¿Ya tienes cuenta? <Link to="/">Inicia sesión aquí</Link>
          </div>
        </form>
      </div>
    </div>
  );
}
EOF

# 4. Crear RegisterPage.css
echo "🎨 Creando RegisterPage.css..."
cat > src/pages/RegisterPage.css << 'EOF'
.register-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px 20px;
}

.register-card {
  background: white;
  border-radius: 10px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 800px;
  padding: 40px;
}

.register-header {
  text-align: center;
  margin-bottom: 30px;
}

.register-header h1 {
  font-size: 2rem;
  color: #667eea;
  margin-bottom: 10px;
}

.register-header p {
  color: #666;
  font-size: 0.9rem;
}

.register-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }
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

.error-text {
  color: #c33;
  font-size: 0.85rem;
}

.error-message {
  background-color: #fee;
  color: #c33;
  padding: 12px;
  border-radius: 6px;
  border-left: 4px solid #c33;
  font-size: 0.9rem;
}

.register-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 14px;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  margin-top: 10px;
}

.register-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.register-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.login-link {
  text-align: center;
  color: #666;
  font-size: 0.9rem;
}

.login-link a {
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
}

.login-link a:hover {
  text-decoration: underline;
}
EOF

# 5. Crear ForgotPasswordPage.jsx
echo "📄 Creando ForgotPasswordPage.jsx..."
cat > src/pages/ForgotPasswordPage.jsx << 'EOF'
import { useState } from 'react';
import { Link } from 'react-router-dom';
import { authAPI } from '../services/api';
import './ForgotPasswordPage.css';

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
      <div className="forgot-password-container">
        <div className="forgot-password-card">
          <div className="success-icon">✓</div>
          <h1>Email Enviado</h1>
          <p className="success-message">
            Si el email está registrado en nuestro sistema, recibirás instrucciones
            para recuperar tu contraseña.
          </p>
          <p className="info-text">
            Revisa tu bandeja de entrada y la carpeta de spam.
          </p>
          <Link to="/" className="back-button">
            Volver al inicio de sesión
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="forgot-password-container">
      <div className="forgot-password-card">
        <div className="forgot-password-header">
          <h1>¿Olvidaste tu contraseña?</h1>
          <p>Ingresa tu email y te enviaremos instrucciones para recuperarla.</p>
        </div>

        <form onSubmit={handleSubmit} className="forgot-password-form">
          {error && <div className="error-message">{error}</div>}

          <div className="form-group">
            abel htmlFor="email">Email</label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="correo@ejemplo.com"
              required
              disabled={loading}
            />
          </div>

          <button type="submit" className="submit-button" disabled={loading}>
            {loading ? 'Enviando...' : 'Enviar instrucciones'}
          </button>

          <Link to="/" className="back-link">
            ← Volver al inicio de sesión
          </Link>
        </form>
      </div>
    </div>
  );
}
EOF

# 6. Crear ForgotPasswordPage.css
echo "🎨 Creando ForgotPasswordPage.css..."
cat > src/pages/ForgotPasswordPage.css << 'EOF'
.forgot-password-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.forgot-password-card {
  background: white;
  border-radius: 10px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 450px;
  padding: 40px;
}

.forgot-password-header {
  text-align: center;
  margin-bottom: 30px;
}

.forgot-password-header h1 {
  font-size: 1.8rem;
  color: #333;
  margin-bottom: 10px;
}

.forgot-password-header p {
  color: #666;
  font-size: 0.95rem;
  line-height: 1.5;
}

.forgot-password-form {
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

.error-message {
  background-color: #fee;
  color: #c33;
  padding: 12px;
  border-radius: 6px;
  border-left: 4px solid #c33;
  font-size: 0.9rem;
}

.submit-button {
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

.submit-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.submit-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.back-link {
  text-align: center;
  color: #667eea;
  text-decoration: none;
  font-size: 0.9rem;
  font-weight: 500;
}

.back-link:hover {
  text-decoration: underline;
}

.success-icon {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-size: 3rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  margin: 0 auto 20px;
}

.success-message {
  color: #333;
  text-align: center;
  margin-bottom: 15px;
  line-height: 1.6;
}

.info-text {
  color: #666;
  text-align: center;
  font-size: 0.9rem;
  margin-bottom: 25px;
}

.back-button {
  display: block;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  text-align: center;
  padding: 14px;
  border-radius: 6px;
  text-decoration: none;
  font-weight: 600;
  transition: transform 0.2s, box-shadow 0.2s;
}

.back-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}
EOF

# 7. Crear ResetPasswordPage.jsx
echo "📄 Creando ResetPasswordPage.jsx..."
cat > src/pages/ResetPasswordPage.jsx << 'EOF'
import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import { authAPI } from '../services/api';
import './ResetPasswordPage.css';

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
      <div className="reset-password-container">
        <div className="reset-password-card">
          <div className="success-icon">✓</div>
          <h1>Contraseña Restablecida</h1>
          <p className="success-message">
            Tu contraseña ha sido restablecida exitosamente.
          </p>
          <p className="info-text">
            Serás redirigido al inicio de sesión en unos segundos...
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="reset-password-container">
      <div className="reset-password-card">
        <div className="reset-password-header">
          <h1>Nueva Contraseña</h1>
          <p>Ingresa tu nueva contraseña para tu cuenta</p>
        </div>

        <form onSubmit={handleSubmit} className="reset-password-form">
          {errors.general && (
            <div className="error-message">{errors.general}</div>
          )}
          {errors.detail && (
            <div className="error-message">{errors.detail}</div>
          )}

          <div className="form-group">
            abel htmlFor="new_password">Nueva Contraseña</label>
            <input
              id="new_password"
              name="new_password"
              type="password"
              value={formData.new_password}
              onChange={handleChange}
              placeholder="Mínimo 8 caracteres"
              required
              disabled={loading}
            />
            {errors.new_password && (
              <span className="error-text">{errors.new_password}</span>
            )}
          </div>

          <div className="form-group">
            abel htmlFor="new_password_confirm">Confirmar Contraseña</label>
            <input
              id="new_password_confirm"
              name="new_password_confirm"
              type="password"
              value={formData.new_password_confirm}
              onChange={handleChange}
              placeholder="Confirma tu nueva contraseña"
              required
              disabled={loading}
            />
          </div>

          <button type="submit" className="submit-button" disabled={loading}>
            {loading ? 'Restableciendo...' : 'Restablecer Contraseña'}
          </button>

          <Link to="/" className="back-link">
            ← Volver al inicio de sesión
          </Link>
        </form>
      </div>
    </div>
  );
}
EOF

# 8. Crear ResetPasswordPage.css
echo "🎨 Creando ResetPasswordPage.css..."
cat > src/pages/ResetPasswordPage.css << 'EOF'
.reset-password-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.reset-password-card {
  background: white;
  border-radius: 10px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 450px;
  padding: 40px;
}

.reset-password-header {
  text-align: center;
  margin-bottom: 30px;
}

.reset-password-header h1 {
  font-size: 1.8rem;
  color: #333;
  margin-bottom: 10px;
}

.reset-password-header p {
  color: #666;
  font-size: 0.95rem;
}

.reset-password-form {
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

.error-text {
  color: #c33;
  font-size: 0.85rem;
}

.error-message {
  background-color: #fee;
  color: #c33;
  padding: 12px;
  border-radius: 6px;
  border-left: 4px solid #c33;
  font-size: 0.9rem;
}

.submit-button {
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

.submit-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.submit-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.back-link {
  text-align: center;
  color: #667eea;
  text-decoration: none;
  font-size: 0.9rem;
  font-weight: 500;
}

.back-link:hover {
  text-decoration: underline;
}

.success-icon {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-size: 3rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  margin: 0 auto 20px;
}

.success-message {
  color: #333;
  text-align: center;
  margin-bottom: 15px;
  line-height: 1.6;
}

.info-text {
  color: #666;
  text-align: center;
  font-size: 0.9rem;
}
EOF

# 9. Actualizar LoginPage.jsx con link a registro y recuperación
echo "📄 Actualizando LoginPage.jsx..."
cat > src/pages/LoginPage.jsx << 'EOF'
import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
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

          <div className="forgot-password-link">
            <Link to="/forgot-password">¿Olvidaste tu contraseña?</Link>
          </div>

          <button type="submit" className="login-button" disabled={loading}>
            {loading ? 'Iniciando sesión...' : 'Iniciar Sesión'}
          </button>

          <div className="register-link">
            ¿No tienes cuenta? <Link to="/register">Regístrate aquí</Link>
          </div>
        </form>
      </div>
    </div>
  );
}
EOF

# 10. Actualizar LoginPage.css
echo "🎨 Actualizando LoginPage.css..."
cat >> src/pages/LoginPage.css << 'EOF'

.forgot-password-link {
  text-align: right;
  margin-top: -10px;
}

.forgot-password-link a {
  color: #667eea;
  text-decoration: none;
  font-size: 0.85rem;
}

.forgot-password-link a:hover {
  text-decoration: underline;
}

.register-link {
  text-align: center;
  color: #666;
  font-size: 0.9rem;
  margin-top: 10px;
}

.register-link a {
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
}

.register-link a:hover {
  text-decoration: underline;
}
EOF

# 11. Crear ProfilePage.jsx
echo "📄 Creando ProfilePage.jsx..."
cat > src/pages/ProfilePage.jsx << 'EOF'
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import { authAPI } from '../services/api';
import './ProfilePage.css';

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
    <div className="profile-container">
      <header className="profile-header">
        <div className="header-content">
          <h1>Mi Perfil</h1>
          <button onClick={() => navigate('/dashboard')} className="back-button">
            ← Volver al Dashboard
          </button>
        </div>
      </header>

      <main className="profile-main">
        <div className="profile-content">
          {/* Información del usuario */}
          <div className="profile-section">
            <div className="section-header">
              <h2>Información Personal</h2>
            </div>

            {success && <div className="success-message">{success}</div>}
            {errors.general && <div className="error-message">{errors.general}</div>}

            <form onSubmit={handleProfileSubmit} className="profile-form">
              <div className="form-row">
                <div className="form-group">
                  abel>Usuario</label>
                  <input type="text" value={user?.username} disabled />
                </div>

                <div className="form-group">
                  abel>Email</label>
                  <input type="email" value={user?.email} disabled />
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  abel htmlFor="first_name">Nombre</label>
                  <input
                    id="first_name"
                    name="first_name"
                    type="text"
                    value={formData.first_name}
                    onChange={handleChange}
                    disabled={loading}
                  />
                </div>

                <div className="form-group">
                  abel htmlFor="last_name">Apellido</label>
                  <input
                    id="last_name"
                    name="last_name"
                    type="text"
                    value={formData.last_name}
                    onChange={handleChange}
                    disabled={loading}
                  />
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  abel htmlFor="phone">Teléfono</label>
                  <input
                    id="phone"
                    name="phone"
                    type="tel"
                    value={formData.phone}
                    onChange={handleChange}
                    disabled={loading}
                  />
                </div>

                <div className="form-group">
                  abel htmlFor="position">Cargo</label>
                  <input
                    id="position"
                    name="position"
                    type="text"
                    value={formData.position}
                    onChange={handleChange}
                    disabled={loading}
                  />
                </div>
              </div>

              <div className="form-group">
                abel htmlFor="department">Departamento</label>
                <input
                  id="department"
                  name="department"
                  type="text"
                  value={formData.department}
                  onChange={handleChange}
                  disabled={loading}
                />
              </div>

              <button type="submit" className="save-button" disabled={loading}>
                {loading ? 'Guardando...' : 'Guardar Cambios'}
              </button>
            </form>
          </div>

          {/* Cambio de contraseña */}
          <div className="profile-section">
            <div className="section-header">
              <h2>Seguridad</h2>
              <button
                type="button"
                onClick={() => setShowPasswordForm(!showPasswordForm)}
                className="toggle-button"
              >
                {showPasswordForm ? 'Cancelar' : 'Cambiar Contraseña'}
              </button>
            </div>

            {showPasswordForm && (
              <form onSubmit={handlePasswordSubmit} className="password-form">
                {errors.password && <div className="error-message">{errors.password}</div>}

                <div className="form-group">
                  abel htmlFor="old_password">Contraseña Actual</label>
                  <input
                    id="old_password"
                    name="old_password"
                    type="password"
                    value={passwordData.old_password}
                    onChange={handlePasswordChange}
                    required
                    disabled={loading}
                  />
                  {errors.old_password && (
                    <span className="error-text">{errors.old_password}</span>
                  )}
                </div>

                <div className="form-group">
                  abel htmlFor="new_password">Nueva Contraseña</label>
                  <input
                    id="new_password"
                    name="new_password"
                    type="password"
                    value={passwordData.new_password}
                    onChange={handlePasswordChange}
                    required
                    disabled={loading}
                  />
                  {errors.new_password && (
                    <span className="error-text">{errors.new_password}</span>
                  )}
                </div>

                <div className="form-group">
                  abel htmlFor="new_password_confirm">Confirmar Nueva Contraseña</label>
                  <input
                    id="new_password_confirm"
                    name="new_password_confirm"
                    type="password"
                    value={passwordData.new_password_confirm}
                    onChange={handlePasswordChange}
                    required
                    disabled={loading}
                  />
                </div>

                <button type="submit" className="save-button" disabled={loading}>
                  {loading ? 'Cambiando...' : 'Cambiar Contraseña'}
                </button>
              </form>
            )}
          </div>

          {/* Acciones de cuenta */}
          <div className="profile-section">
            <div className="section-header">
              <h2>Cuenta</h2>
            </div>
            <button onClick={handleLogout} className="logout-button">
              Cerrar Sesión
            </button>
          </div>
        </div>
      </main>
    </div>
  );
}
EOF

# 12. Crear ProfilePage.css
echo "🎨 Creando ProfilePage.css..."
cat > src/pages/ProfilePage.css << 'EOF'
.profile-container {
  min-height: 100vh;
  background-color: #f5f7fa;
}

.profile-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px 0;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.header-content {
  max-width: 900px;
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

.back-button {
  background-color: rgba(255, 255, 255, 0.2);
  color: white;
  border: 1px solid white;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.back-button:hover {
  background-color: rgba(255, 255, 255, 0.3);
}

.profile-main {
  max-width: 900px;
  margin: 0 auto;
  padding: 40px 20px;
}

.profile-content {
  display: flex;
  flex-direction: column;
  gap: 25px;
}

.profile-section {
  background: white;
  border-radius: 10px;
  padding: 30px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 2px solid #f0f0f0;
}

.section-header h2 {
  color: #333;
  font-size: 1.3rem;
  margin: 0;
}

.toggle-button {
  background-color: #667eea;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.toggle-button:hover {
  background-color: #5568d3;
}

.profile-form,
.password-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }
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

.error-text {
  color: #c33;
  font-size: 0.85rem;
}

.error-message {
  background-color: #fee;
  color: #c33;
  padding: 12px;
  border-radius: 6px;
  border-left: 4px solid #c33;
  font-size: 0.9rem;
  margin-bottom: 15px;
}

.success-message {
  background-color: #e7f7ef;
  color: #0d8a4d;
  padding: 12px;
  border-radius: 6px;
  border-left: 4px solid #0d8a4d;
  font-size: 0.9rem;
  margin-bottom: 15px;
}

.save-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  align-self: flex-start;
}

.save-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.save-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.logout-button {
  background-color: #dc3545;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.3s;
}

.logout-button:hover {
  background-color: #c82333;
}
EOF

# 13. Actualizar DashboardPage.jsx con enlace a perfil
echo "📄 Actualizando DashboardPage.jsx..."
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
            <button onClick={() => navigate('/profile')} className="profile-button">
              👤 {user?.username || 'Usuario'}
            </button>
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

# 14. Actualizar DashboardPage.css
echo "🎨 Actualizando DashboardPage.css..."
cat >> src/pages/DashboardPage.css << 'EOF'

.profile-button {
  background-color: rgba(255, 255, 255, 0.2);
  color: white;
  border: 1px solid white;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.3s;
  font-size: 0.9rem;
}

.profile-button:hover {
  background-color: rgba(255, 255, 255, 0.3);
}
EOF

# 15. Actualizar App.jsx con todas las rutas
echo "⚛️ Actualizando App.jsx..."
cat > src/App.jsx << 'EOF'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useAuthStore } from './stores/authStore';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import ForgotPasswordPage from './pages/ForgotPasswordPage';
import ResetPasswordPage from './pages/ResetPasswordPage';
import DashboardPage from './pages/DashboardPage';
import ProfilePage from './pages/ProfilePage';

function PrivateRoute({ children }) {
  const isAuthenticated = useAuthStore(state => state.isAuthenticated);
  return isAuthenticated ? children : <Navigate to="/" />;
}

function PublicRoute({ children }) {
  const isAuthenticated = useAuthStore(state => state.isAuthenticated);
  return !isAuthenticated ? children : <Navigate to="/dashboard" />;
}

function App() {
  return (
    <Router>
      <Routes>
        {/* Rutas públicas */}
        <Route path="/" element={<PublicRoute><LoginPage /></PublicRoute>} />
        <Route path="/register" element={<PublicRoute><RegisterPage /></PublicRoute>} />
        <Route path="/forgot-password" element={<PublicRoute><ForgotPasswordPage /></PublicRoute>} />
        <Route path="/reset-password" element={<PublicRoute><ResetPasswordPage /></PublicRoute>} />
        
        {/* Rutas privadas */}
        <Route 
          path="/dashboard" 
          element={
            <PrivateRoute>
              <DashboardPage />
            </PrivateRoute>
          } 
        />
        <Route 
          path="/profile" 
          element={
            <PrivateRoute>
              <ProfilePage />
            </PrivateRoute>
          } 
        />
        
        {/* Ruta 404 */}
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </Router>
  );
}

export default App;
EOF

echo ""
echo "✅ ¡Sistema completo de autenticación configurado!"
echo ""
echo "Páginas creadas:"
echo "  ✓ LoginPage - Inicio de sesión"
echo "  ✓ RegisterPage - Registro de usuarios"
echo "  ✓ ForgotPasswordPage - Solicitar recuperación"
echo "  ✓ ResetPasswordPage - Restablecer contraseña"
echo "  ✓ DashboardPage - Panel principal"
echo "  ✓ ProfilePage - Perfil y cambio de contraseña"
echo ""
echo "Servicios actualizados:"
echo "  ✓ authStore.js - Estado de autenticación"
echo "  ✓ api.js - Cliente HTTP con interceptores"
echo "  ✓ App.jsx - Rutas públicas y privadas"
echo ""
echo "Para iniciar el frontend:"
echo "  cd /Users/edegantea/development/maewalliscorp/gestionproyectos/frontend"
echo "  npm run dev"
echo ""
echo "Para el backend asegúrate de:"
echo "  1. Ejecutar migraciones: python manage.py makemigrations && python manage.py migrate"
echo "  2. Crear superusuario: python manage.py createsuperuser"
echo "  3. Iniciar servidor: python manage.py runserver"