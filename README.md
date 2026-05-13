# Plataforma Interna de Administración de Proyectos (PIAP)

## Descripción General
PIAP es una herramienta centralizada diseñada para administrar proyectos de desarrollo de software bajo un enfoque híbrido (PMBOK + Scrum). Permite a la dirección y a los equipos de proyecto gestionar portafolios, sprints, tareas, riesgos e incidencias desde un único lugar.

Este proyecto ha alcanzado su **MVP (Release 1)**, cumpliendo con las Fases 1 a 6 de su Documento Maestro.

## Arquitectura del Sistema
El proyecto sigue una arquitectura Cliente-Servidor de 3 capas:
1. **Frontend (Capa de Presentación):** SPA desarrollada en **React 19** con **Vite**. Utiliza Zustand para la gestión de estado y Recharts para el panel de métricas y gráficos Burndown.
2. **Backend (Capa de Negocio):** API RESTful desarrollada en **Python** con **Django 4.2** y **Django REST Framework (DRF)**. Implementa autenticación segura mediante JWT (JSON Web Tokens).
3. **Base de Datos (Capa de Datos):** Preparada para operar con **PostgreSQL** o **MySQL** (actualmente operando con la BD relacional configurada por Django).

## Modelo de Datos (Core)
El esquema principal de datos consta de las siguientes entidades:
- **User:** Usuarios del sistema con roles basados en RBAC.
- **Project:** Contiene los metadatos de la iniciativa, presupuestos y fechas.
- **ProjectMember:** Asignación de Usuarios a Proyectos con roles específicos (PM, Desarrollador, Tester, etc.).
- **Sprint:** Iteraciones de tiempo fijo asociadas a un Proyecto.
- **BacklogItem:** Historias de Usuario priorizadas.
- **Task:** Tareas técnicas que pertenecen a un Sprint o Backlog Item.
- **Risk:** Registro de riesgos (probabilidad e impacto).
- **Incident:** Problemas técnicos o funcionales reportados (severidad).
- **ProjectDocument:** Archivos adjuntos.

## API REST (Endpoints Principales)
La API base se encuentra en `/api/` y expone los siguientes módulos:
- **Auth:** `/api/auth/login/`, `/api/auth/refresh/`
- **Proyectos:** `/api/projects/projects/`
- **Backlog & Sprints:** `/api/projects/backlog/`, `/api/projects/sprints/`
- **Tareas (Kanban):** `/api/projects/tasks/`
- **Riesgos e Incidencias:** `/api/projects/risks/`, `/api/projects/incidents/`
- **Equipo:** `/api/projects/members/`

## Despliegue Local
1. **Backend:**
   ```bash
   cd backend
   source venv/bin/activate
   pip install -r requirements.txt
   python manage.py migrate
   python manage.py runserver
   ```
2. **Frontend:**
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

---
*Documento generado en la transición a la **Fase 7 (Operación y Mejora Continua)***.