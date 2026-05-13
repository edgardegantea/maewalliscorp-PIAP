#!/bin/bash
cd /Users/edegantea/development/maewalliscorp/gestionproyectos/frontend

echo "⚡ Configurando Frontend React + Vite..."

# Crear proyecto Vite
npm create vite@latest . -- --template react

# Instalar dependencias base
npm install

# Instalar dependencias adicionales
npm install axios react-router-dom @tanstack/react-query zustand react-hook-form

# Crear archivo .env
cat > .env << 'EOF'
VITE_API_URL=http://localhost:8000/api
VITE_APP_NAME=PIAP
EOF

echo "✅ Frontend React+Vite configurado"