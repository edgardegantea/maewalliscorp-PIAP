import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import { useProjectsStore } from '../stores/projectsStore';
import { PieChart, Pie, Cell, Tooltip as RechartsTooltip, Legend, ResponsiveContainer } from 'recharts';
import CompanySettingsModal from '../components/projects/CompanySettingsModal';

const COLORS = ['#28a745', '#ffc107', '#dc3545', '#17a2b8', '#6c757d', '#fd7e14'];

export default function DashboardPage() {
  const navigate = useNavigate();
  const { user, logout } = useAuthStore();
  const { statistics, fetchStatistics } = useProjectsStore();
  const [loading, setLoading] = useState(true);
  const [showSettingsModal, setShowSettingsModal] = useState(false);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    setLoading(true);
    try {
      await fetchStatistics();
    } catch (e) {
      console.error(e);
    }
    setLoading(false);
  };

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  // Preparar datos para gráficos
  const getStatusData = () => {
    if (!statistics?.by_status) return [];
    return Object.keys(statistics.by_status).map(key => ({
      name: key,
      value: statistics.by_status[key]
    })).filter(item => item.value > 0);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-gradient-to-br from-slate-800 to-slate-900 text-white py-5 shadow-md">
        <div className="w-full mx-auto px-10 flex justify-between items-center">
          <h1 className="text-2xl font-bold m-0">PIAP - Dashboard Ejecutivo</h1>
          <div className="flex items-center gap-4">
            <button 
              onClick={() => setShowSettingsModal(true)} 
              className="bg-white/20 text-white border border-white px-4 py-2 rounded-md cursor-pointer transition-colors hover:bg-white/30 text-sm font-medium"
            >
              ⚙️ Configuración
            </button>
            <button 
              onClick={() => navigate('/profile')} 
              className="bg-white/20 text-white border border-white px-4 py-2 rounded-md cursor-pointer transition-colors hover:bg-white/30 text-sm font-medium"
            >
              👤 {user?.username || 'Usuario'}
            </button>
            <button 
              onClick={handleLogout} 
              className="bg-white/20 text-white border border-white px-4 py-2 rounded-md cursor-pointer transition-colors hover:bg-white/30 text-sm font-medium"
            >
              Cerrar Sesión
            </button>
          </div>
        </div>
      </header>

      <main className="w-full mx-auto px-10 py-10">
        <div className="bg-gradient-to-br from-slate-800 to-slate-900 text-white p-8 rounded-xl mb-8 shadow-lg shadow-blue-700/30">
          <h2 className="text-3xl font-bold mb-2 m-0">Bienvenido, {user?.first_name || user?.username}! 👋</h2>
          <p className="m-0 text-white/90">Visión global del portafolio de proyectos</p>
        </div>

        {loading ? (
          <div className="w-16 h-16 border-4 border-gray-100 border-t-indigo-500 rounded-full animate-spin mx-auto my-10"></div>
        ) : (
          <>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
              <div 
                className="bg-white rounded-xl p-8 shadow-sm transition-all duration-300 hover:-translate-y-1 hover:shadow-md cursor-pointer border-2 border-transparent hover:border-blue-700" 
                onClick={() => navigate('/projects')}
              >
                <div className="text-5xl mb-4">📊</div>
                <h2 className="text-xl font-bold mb-3 text-gray-800">Proyectos Activos</h2>
                <p className="text-5xl font-bold text-blue-700 my-3">{statistics?.total_projects || 0}</p>
                <p className="text-gray-500 text-sm m-0">Total en el portafolio</p>
              </div>

              <div className="bg-white rounded-xl p-8 shadow-sm transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
                <div className="text-5xl mb-4">⚠️</div>
                <h2 className="text-xl font-bold mb-3 text-gray-800">Retrasados</h2>
                <p className="text-5xl font-bold text-red-500 my-3">{statistics?.overdue_projects || 0}</p>
                <p className="text-gray-500 text-sm m-0">Proyectos con fecha vencida</p>
              </div>

              <div className="bg-white rounded-xl p-8 shadow-sm transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
                <div className="text-5xl mb-4">📈</div>
                <h2 className="text-xl font-bold mb-3 text-gray-800">Progreso Promedio</h2>
                <p className="text-5xl font-bold text-blue-700 my-3">{(statistics?.avg_completion || 0).toFixed(1)}%</p>
                <p className="text-gray-500 text-sm m-0">Global del portafolio</p>
              </div>

              <div className="bg-white rounded-xl p-8 shadow-sm transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
                <div className="text-5xl mb-4">💰</div>
                <h2 className="text-xl font-bold mb-3 text-gray-800">Presupuesto Ejecutado</h2>
                <p className="text-xl font-bold text-blue-700 my-3 mt-4">
                  ${(statistics?.total_budget_actual || 0).toLocaleString()} / ${(statistics?.total_budget_planned || 0).toLocaleString()}
                </p>
                <p className="text-gray-500 text-sm m-0">Gasto actual vs planificado</p>
              </div>
            </div>

            <div className="mt-8 bg-white p-8 rounded-xl shadow-sm">
              <h3 className="text-xl font-bold text-blue-700 mb-6">Distribución por Estado</h3>
              <div className="w-full h-72">
                {getStatusData().length > 0 ? (
                  <ResponsiveContainer>
                    <PieChart>
                      <Pie
                        data={getStatusData()}
                        cx="50%"
                        cy="50%"
                        outerRadius={100}
                        fill="#8884d8"
                        dataKey="value"
                        label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                      >
                        {getStatusData().map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                        ))}
                      </Pie>
                      <RechartsTooltip />
                      <Legend />
                    </PieChart>
                  </ResponsiveContainer>
                ) : (
                  <p className="text-center mt-12 text-gray-500">No hay suficientes datos para mostrar la gráfica.</p>
                )}
              </div>
            </div>
          </>
        )}

        <div className="bg-white p-8 rounded-xl shadow-sm mt-8">
          <h3 className="text-xl font-bold text-gray-800 mb-6 m-0">Acciones Rápidas</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <button 
              className="flex items-center gap-3 p-4 bg-gray-50 border-2 border-gray-200 rounded-lg font-semibold text-base transition-all duration-300 hover:bg-blue-700 hover:text-white hover:border-blue-700 hover:-translate-y-0.5 hover:shadow-lg shadow-blue-700/30" 
              onClick={() => navigate('/projects/new')}
            >
              <span className="text-2xl">➕</span>
              <span>Nuevo Proyecto</span>
            </button>
            <button 
              className="flex items-center gap-3 p-4 bg-gray-50 border-2 border-gray-200 rounded-lg font-semibold text-base transition-all duration-300 hover:bg-blue-700 hover:text-white hover:border-blue-700 hover:-translate-y-0.5 hover:shadow-lg shadow-blue-700/30" 
              onClick={() => navigate('/projects')}
            >
              <span className="text-2xl">📋</span>
              <span>Ver Proyectos</span>
            </button>
            <button 
              className="flex items-center gap-3 p-4 bg-gray-50 border-2 border-gray-200 rounded-lg font-semibold text-base transition-all duration-300 hover:bg-blue-700 hover:text-white hover:border-blue-700 hover:-translate-y-0.5 hover:shadow-lg shadow-blue-700/30" 
              onClick={() => navigate('/categories')}
            >
              <span className="text-2xl">🏷️</span>
              <span>Administrar Categorías</span>
            </button>
          </div>
        </div>
      </main>

      {showSettingsModal && (
        <CompanySettingsModal onClose={() => setShowSettingsModal(false)} />
      )}
    </div>
  );
}