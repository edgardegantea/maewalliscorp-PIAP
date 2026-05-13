import api from './api';

export const projectsAPI = {
  // Proyectos
  getProjects: (params) => api.get('/projects/projects/', { params }),
  getProject: (id) => api.get(`/projects/projects/${id}/`),
  createProject: (data) => api.post('/projects/projects/', data),
  updateProject: (id, data) => api.patch(`/projects/projects/${id}/`, data),
  deleteProject: (id) => api.delete(`/projects/projects/${id}/`),
  
  // Acciones especiales
  getMyProjects: () => api.get('/projects/projects/my_projects/'),
  getStatistics: () => api.get('/projects/projects/statistics/'),
  updateProgress: (id, percentage) => api.post(`/projects/projects/${id}/update_progress/`, {
    completion_percentage: percentage
  }),
  getTimeline: (id) => api.get(`/projects/projects/${id}/timeline/`),
  generateLegalDocument: (projectId, type) => api.get(`/projects/projects/${projectId}/generate_legal_document/`, {
    params: { type },
    responseType: 'blob'
  }),
  
  // Categorías
  getCategories: () => api.get('/projects/categories/'),
  getCategory: (id) => api.get(`/projects/categories/${id}/`),
  createCategory: (data) => api.post('/projects/categories/', data),
  updateCategory: (id, data) => api.patch(`/projects/categories/${id}/`, data),
  deleteCategory: (id) => api.delete(`/projects/categories/${id}/`),
  
  // Configuración de la Empresa
  getCompanySettings: () => api.get('/projects/company-settings/'),
  updateCompanySettings: (data) => api.patch('/projects/company-settings/update_settings/', data),
  
  // Hitos
  getMilestones: (projectId) => api.get('/projects/milestones/', { params: { project: projectId } }),
  createMilestone: (data) => api.post('/projects/milestones/', data),
  updateMilestone: (id, data) => api.patch(`/projects/milestones/${id}/`, data),
  deleteMilestone: (id) => api.delete(`/projects/milestones/${id}/`),
  markMilestoneCompleted: (id) => api.post(`/projects/milestones/${id}/mark_completed/`),
  
  // Comentarios
  getComments: (projectId) => api.get('/projects/comments/', { params: { project: projectId } }),
  createComment: (data) => api.post('/projects/comments/', data),
  updateComment: (id, data) => api.patch(`/projects/comments/${id}/`, data),
  deleteComment: (id) => api.delete(`/projects/comments/${id}/`),
  
  // Documentos
  getDocuments: (projectId) => api.get('/projects/documents/', { params: { project: projectId } }),
  uploadDocument: (data) => {
    const formData = new FormData();
    Object.keys(data).forEach(key => formData.append(key, data[key]));
    return api.post('/projects/documents/', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
  },
  deleteDocument: (id) => api.delete(`/projects/documents/${id}/`),

  // Sprints
  getSprints: (projectId) => api.get('/projects/sprints/', { params: { project: projectId } }),
  getSprint: (id) => api.get(`/projects/sprints/${id}/`),
  createSprint: (data) => api.post('/projects/sprints/', data),
  updateSprint: (id, data) => api.patch(`/projects/sprints/${id}/`, data),
  deleteSprint: (id) => api.delete(`/projects/sprints/${id}/`),
  getSprintBacklogItems: (id) => api.get(`/projects/sprints/${id}/backlog_items/`),

  // Backlog Items
  getBacklogItems: (projectId) => api.get('/projects/backlog/', { params: { project: projectId } }),
  getBacklogItem: (id) => api.get(`/projects/backlog/${id}/`),
  createBacklogItem: (data) => api.post('/projects/backlog/', data),
  updateBacklogItem: (id, data) => api.patch(`/projects/backlog/${id}/`, data),
  deleteBacklogItem: (id) => api.delete(`/projects/backlog/${id}/`),

  // Tasks
  getTasks: (params) => api.get('/projects/tasks/', { params }),
  getTask: (id) => api.get(`/projects/tasks/${id}/`),
  createTask: (data) => api.post('/projects/tasks/', data),
  updateTask: (id, data) => api.patch(`/projects/tasks/${id}/`, data),
  deleteTask: (id) => api.delete(`/projects/tasks/${id}/`),

  // Risks
  getRisks: (projectId) => api.get('/projects/risks/', { params: { project: projectId } }),
  getRisk: (id) => api.get(`/projects/risks/${id}/`),
  createRisk: (data) => api.post('/projects/risks/', data),
  updateRisk: (id, data) => api.patch(`/projects/risks/${id}/`, data),
  deleteRisk: (id) => api.delete(`/projects/risks/${id}/`),

  // Incidents
  getIncidents: (projectId) => api.get('/projects/incidents/', { params: { project: projectId } }),
  getIncident: (id) => api.get(`/projects/incidents/${id}/`),
  createIncident: (data) => api.post('/projects/incidents/', data),
  updateIncident: (id, data) => api.patch(`/projects/incidents/${id}/`, data),
  deleteIncident: (id) => api.delete(`/projects/incidents/${id}/`),

  // Members
  getMembers: (projectId) => api.get('/projects/members/', { params: { project: projectId } }),
  getMember: (id) => api.get(`/projects/members/${id}/`),
  createMember: (data) => api.post('/projects/members/', data),
  updateMember: (id, data) => api.patch(`/projects/members/${id}/`, data),
  deleteMember: (id) => api.delete(`/projects/members/${id}/`),

  // Users
  getUsers: () => api.get('/projects/users/'),
};
