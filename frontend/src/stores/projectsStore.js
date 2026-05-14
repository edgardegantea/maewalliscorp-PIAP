import { create } from 'zustand';
import { projectsAPI } from '../services/projectsAPI';

export const useProjectsStore = create((set, get) => ({
  projects: [],
  currentProject: null,
  categories: [],
  statistics: null,
  loading: false,
  error: null,

  // Obtener proyectos
  fetchProjects: async (filters = {}) => {
    set({ loading: true, error: null });
    try {
      const response = await projectsAPI.getProjects(filters);
      set({ projects: response.data, loading: false });
      return response.data;
    } catch (error) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  // Obtener proyecto por ID
  fetchProject: async (id) => {
    set({ loading: true, error: null });
    try {
      const response = await projectsAPI.getProject(id);
      set({ currentProject: response.data, loading: false });
      return response.data;
    } catch (error) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  // Crear proyecto
  createProject: async (projectData) => {
    set({ loading: true, error: null });
    try {
      const response = await projectsAPI.createProject(projectData);
      set(state => ({
        projects: [response.data, ...state.projects],
        loading: false
      }));
      return response.data;
    } catch (error) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  // Actualizar proyecto
  updateProject: async (id, projectData) => {
    set({ loading: true, error: null });
    try {
      const response = await projectsAPI.updateProject(id, projectData);
      set(state => ({
        projects: state.projects.map(p => p.id === id ? response.data : p),
        currentProject: state.currentProject?.id === id ? response.data : state.currentProject,
        loading: false
      }));
      return response.data;
    } catch (error) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  // Eliminar proyecto
  deleteProject: async (id) => {
    set({ loading: true, error: null });
    try {
      await projectsAPI.deleteProject(id);
      set(state => ({
        projects: state.projects.filter(p => p.id !== id),
        loading: false
      }));
    } catch (error) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  // Obtener mis proyectos
  fetchMyProjects: async () => {
    set({ loading: true, error: null });
    try {
      const response = await projectsAPI.getMyProjects();
      set({ projects: response.data, loading: false });
      return response.data;
    } catch (error) {
      set({ error: error.message, loading: false });
      throw error;
    }
  },

  // Obtener estadísticas
  fetchStatistics: async () => {
    try {
      const response = await projectsAPI.getStatistics();
      set({ statistics: response.data });
      return response.data;
    } catch (error) {
      console.error('Error fetching statistics:', error);
      throw error;
    }
  },

  // Actualizar progreso
  updateProgress: async (id, percentage) => {
    try {
      const response = await projectsAPI.updateProgress(id, percentage);
      set(state => ({
        projects: state.projects.map(p => p.id === id ? response.data : p),
        currentProject: state.currentProject?.id === id ? response.data : state.currentProject
      }));
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // Obtener categorías
  fetchCategories: async () => {
    try {
      const response = await projectsAPI.getCategories();
      set({ categories: response.data });
      return response.data;
    } catch (error) {
      console.error('Error fetching categories:', error);
      throw error;
    }
  },

  createCategory: async (data) => {
    try {
      const response = await projectsAPI.createCategory(data);
      set(state => ({ categories: [...state.categories, response.data] }));
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  updateCategory: async (id, data) => {
    try {
      const response = await projectsAPI.updateCategory(id, data);
      set(state => ({
        categories: state.categories.map(c => c.id === id ? response.data : c)
      }));
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  deleteCategory: async (id) => {
    try {
      await projectsAPI.deleteCategory(id);
      set(state => ({
        categories: state.categories.filter(c => c.id !== id)
      }));
    } catch (error) {
      throw error;
    }
  },

  // Limpiar estado
  clearCurrentProject: () => set({ currentProject: null }),
  clearError: () => set({ error: null }),
}));
