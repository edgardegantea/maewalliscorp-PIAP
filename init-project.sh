#!/bin/bash

# Script de inicialización PIAP - Release 0 Sprint 0
# Directorio: /Users/edegantea/development/maewalliscorp/gestionproyectos/

echo "🚀 Iniciando setup de PIAP con MySQL..."

BASE_DIR="/Users/edegantea/development/maewalliscorp/gestionproyectos"
cd "$BASE_DIR"

# Crear estructura de directorios
echo "📁 Creando estructura de directorios..."
mkdir -p backend/piap_project
mkdir -p backend/apps/users
mkdir -p backend/apps/authentication
mkdir -p frontend/src/{components,pages,services,utils,stores,hooks}
mkdir -p frontend/public
mkdir -p .github/workflows
mkdir -p docs

# Inicializar Git
echo "📦 Inicializando repositorio Git..."
git init
git branch -M main

# Crear .gitignore
echo "📝 Creando .gitignore..."
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
*.egg-info/
dist/
build/

# Django
*.log
db.sqlite3
media/
staticfiles/

# Environment
.env
.env.local
.env.*.local

# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build
/frontend/dist/
/frontend/build/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
EOF

echo "✅ Estructura base creada"