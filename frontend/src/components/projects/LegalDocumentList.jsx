import { useState } from 'react';
import { projectsAPI } from '../../services/projectsAPI';

export default function LegalDocumentList({ projectId }) {
  const [isGenerating, setIsGenerating] = useState(false);

  const handleGenerate = async (type, label) => {
    try {
      setIsGenerating(true);
      const response = await projectsAPI.generateLegalDocument(projectId, type);
      
      // Crear URL para el Blob (PDF)
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `${label}_${projectId}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();
    } catch (error) {
      console.error('Error al generar el documento legal:', error);
      alert('Hubo un error al generar el documento. Por favor, intenta de nuevo.');
    } finally {
      setIsGenerating(false);
    }
  };

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 mt-6 max-w-6xl mx-auto transition-all">
      <div className="mb-8 border-b border-gray-200 pb-4">
        <h3 className="text-2xl font-bold text-gray-800 mb-2">Documentación Legal (Autogenerada)</h3>
        <p className="text-gray-500">Genera y descarga en formato PDF los documentos legales del proyecto con la información actual.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        
        <div className="bg-gray-50 rounded-xl p-6 border border-gray-200 flex flex-col h-full transition-all hover:shadow-md hover:border-blue-200">
          <div className="text-4xl mb-4 text-center">📝</div>
          <h5 className="text-xl font-bold text-gray-800 text-center mb-3">Contrato de Inicio</h5>
          <p className="text-gray-600 text-sm text-center flex-grow">Documento formal que autoriza el inicio del proyecto, incluyendo objetivos, alcance y presupuesto inicial.</p>
          <button 
            className="w-full mt-6 px-4 py-2.5 rounded-lg font-medium text-white bg-blue-600 hover:bg-blue-700 transition-colors shadow-sm flex justify-center items-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed" 
            onClick={() => handleGenerate('inicio', 'Contrato_Inicio')}
            disabled={isGenerating}
          >
            {isGenerating ? (
              <><div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div> Generando...</>
            ) : (
              <><span>📄</span> Generar PDF</>
            )}
          </button>
        </div>

        <div className="bg-gray-50 rounded-xl p-6 border border-gray-200 flex flex-col h-full transition-all hover:shadow-md hover:border-blue-200">
          <div className="text-4xl mb-4 text-center">🔄</div>
          <h5 className="text-xl font-bold text-gray-800 text-center mb-3">Documento de Modificación</h5>
          <p className="text-gray-600 text-sm text-center flex-grow">Plantilla para solicitar o formalizar cambios en el alcance, cronograma o presupuesto del proyecto.</p>
          <button 
            className="w-full mt-6 px-4 py-2.5 rounded-lg font-medium text-white bg-blue-600 hover:bg-blue-700 transition-colors shadow-sm flex justify-center items-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed" 
            onClick={() => handleGenerate('modificacion', 'Documento_Modificacion')}
            disabled={isGenerating}
          >
            {isGenerating ? (
              <><div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div> Generando...</>
            ) : (
              <><span>📄</span> Generar PDF</>
            )}
          </button>
        </div>

        <div className="bg-gray-50 rounded-xl p-6 border border-gray-200 flex flex-col h-full transition-all hover:shadow-md hover:border-blue-200">
          <div className="text-4xl mb-4 text-center">📖</div>
          <h5 className="text-xl font-bold text-gray-800 text-center mb-3">Bitácora del Proyecto</h5>
          <p className="text-gray-600 text-sm text-center flex-grow">Registro oficial de eventos, cambios y decisiones importantes ocurridas a lo largo del proyecto.</p>
          <button 
            className="w-full mt-6 px-4 py-2.5 rounded-lg font-medium text-white bg-blue-600 hover:bg-blue-700 transition-colors shadow-sm flex justify-center items-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed" 
            onClick={() => handleGenerate('bitacora', 'Bitacora_Proyecto')}
            disabled={isGenerating}
          >
            {isGenerating ? (
              <><div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div> Generando...</>
            ) : (
              <><span>📄</span> Generar PDF</>
            )}
          </button>
        </div>

      </div>
    </div>
  );
}
