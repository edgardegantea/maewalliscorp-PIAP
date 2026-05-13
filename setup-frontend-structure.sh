#!/bin/bash

cd /Users/edegantea/development/maewalliscorp/gestionproyectos/frontend

echo "⚡ Configurando frontend React + Vite..."

# 1. Configurar vite.config.js
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      }
    }
  }
})
EOF

echo "✅ Creado: vite.config.js"

# 2. Crear .env
cat > .env << 'EOF'
VITE_API_URL=http://localhost:8000/api
VITE_APP_NAME=PIAP
EOF

echo "✅ Creado: .env"

# 3. Crear servicio de API - src/services/api.js
cat > src/services/api.js << 'EOF'
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para agregar token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor para refrescar token
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        const refreshToken = localStorage.getItem('refresh_token');
        const response = await axios.post(
          `${import.meta.env.VITE_API_URL}/auth/token/refresh/`,
          { refresh: refreshToken }
        );
        
        const { access } = response.data;
        localStorage.setItem('access_token', access);
        
        originalRequest.headers.Authorization = `Bearer ${access}`;
        return api(originalRequest);
      } catch (refreshError) {
        localStorage.removeItem('access_token');
        localStorage.removeItem('refresh_token');
        localStorage.removeItem('user');
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }
    
    return Promise.reject(error);
  }
);

export default api;
EOF

echo "✅ Creado: src/services/api.js"

# 4. Crear servicio de autenticación - src/services/authService.js
cat > src/services/authService.js << 'EOF'
import api from './api';

export const authService = {
  async login(username, password) {
    const response = await api.post('/auth/login/', { username, password });
    const { user, tokens } = response.data;
    
    localStorage.setItem('access_token', tokens.access);
    localStorage.setItem('refresh_token', tokens.refresh);
    localStorage.setItem('user', JSON.stringify(user));
    
    return { user, tokens };
  },

  async register(userData) {
    const response = await api.post('/auth/register/', userData);
    const { user, tokens } = response.data;
    
    localStorage.setItem('access_token', tokens.access);
    localStorage.setItem('refresh_token', tokens.refresh);
    localStorage.setItem('user', JSON.stringify(user));
    
    return { user, tokens };
  },

  logout() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('user');
  },

  async getProfile() {
    const response = await api.get('/auth/profile/');
    return response.data;
  },

  isAuthenticated() {
    return !!localStorage.getItem('access_token');
  },

  getCurrentUser() {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
  }
};
EOF

echo "✅ Creado: src/services/authService.js"

# 5. Crear store de Zustand - src/stores/authStore.js
cat > src/stores/authStore.js << 'EOF'
import { create } from 'zustand';
import { authService } from '../services/authService';

export const useAuthStore = create((set) => ({
  user: authService.getCurrentUser(),
  isAuthenticated: authService.isAuthenticated(),
  loading: false,
  error: null,

  login: async (username, password) => {
    set({ loading: true, error: null });
    try {
      const { user } = await authService.login(username, password);
      set({ user, isAuthenticated: true, loading: false });
    } catch (error) {
      set({ 
        error: error.response?.data?.detail || 'Error al iniciar sesión', 
        loading: false 
      });
      throw error;
    }
  },

  register: async (userData) => {
    set({ loading: true, error: null });
    try {
      const { user } = await authService.register(userData);
      set({ user, isAuthenticated: true, loading: false });
    } catch (error) {
      set({ 
        error: error.response?.data || 'Error al registrar usuario', 
        loading: false 
      });
      throw error;
    }
  },

  logout: () => {
    authService.logout();
    set({ user: null, isAuthenticated: false });
  },

  clearError: () => set({ error: null }),
}));
EOF

echo "✅ Creado: src/stores/authStore.js"

echo ""
echo "🎉 Estructura del frontend configurada!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Ejecutar el script para crear páginas (Login y Dashboard)"
echo "2. Configurar rutas en App.jsx"
echo "3. Iniciar servidor: npm run dev"