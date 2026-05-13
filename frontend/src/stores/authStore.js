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
