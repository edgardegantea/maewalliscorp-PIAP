# Guía de Despliegue en Plesk (Monorepo)

Este repositorio contiene tanto el **Frontend** (React/Vite) como el **Backend** (Django) y está diseñado para ser desplegado en dos subdominios diferentes desde Plesk utilizando Git.

* Backend: `piap-backend.maewalliscorp.org`
* Frontend: `piap.maewalliscorp.org`

## 1. Configuración del Backend (Django)

1. En Plesk, ve a **Sitios web y dominios** y crea o selecciona el subdominio `piap-backend.maewalliscorp.org`.
2. Configura la **Raíz del documento (Document Root)** para que apunte a la carpeta del backend dentro del repositorio: `/httpdocs/backend` (o la ruta donde Plesk clone tu Git + `/backend`).
3. Ve a la opción **Git** en Plesk para este subdominio:
   * Conecta tu repositorio.
   * En **Acciones de implementación adicionales** (Additional deployment actions), agrega el siguiente script:
     ```bash
     cd backend
     pip install -r requirements.txt
     python manage.py migrate
     python manage.py collectstatic --noinput
     # Toca el archivo wsgi para reiniciar Passenger
     touch passenger_wsgi.py
     ```
4. Ve a la configuración de **Python** (o "Aplicación Python") en Plesk para este subdominio:
   * Activa la aplicación Python.
   * Verifica que la versión de Python sea 3.9 o superior.
   * El archivo de inicio debe ser `passenger_wsgi.py` (el cual ya está creado en la carpeta `backend/`).
   * Aplicación/Módulo: `application`
5. Crea un archivo `.env` en la carpeta `backend/` de tu servidor con las credenciales de producción de tu base de datos MySQL (Plesk permite manejar variables de entorno desde la interfaz o puedes crearlo manualmente por FTP/SSH).


## 2. Configuración del Frontend (React/Vite)

1. En Plesk, ve a **Sitios web y dominios** y selecciona el subdominio principal `piap.maewalliscorp.org`.
2. Configura la **Raíz del documento (Document Root)** para que apunte a la carpeta `dist` del frontend: `/httpdocs/frontend/dist` (o la ruta donde Plesk clone tu Git + `/frontend/dist`).
3. Asegúrate de tener la extensión de **Node.js** instalada en tu Plesk.
4. Ve a la opción **Git** en Plesk para este subdominio:
   * Conecta el mismo repositorio.
   * En **Acciones de implementación adicionales** (Additional deployment actions), agrega el siguiente script:
     ```bash
     cd frontend
     # Instala las dependencias y compila el proyecto de React
     npm install
     npm run build
     ```
5. **Enrutamiento (React Router):** Para que las rutas de React funcionen correctamente y no den error 404 al recargar, necesitas configurar Apache/Nginx. En Plesk, ve a **Configuración de Apache y nginx** para el subdominio del frontend y añade lo siguiente en las *Directivas adicionales de nginx*:

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

6. **Variable de entorno del API:** Antes de que Plesk compile (`npm run build`), asegúrate de que el frontend apunte al backend correcto.
   * Modifica el archivo `frontend/src/services/api.js` o usa variables de entorno en Plesk (por ejemplo, creando un archivo `.env.production` en la carpeta `frontend` que contenga: `VITE_API_URL=https://piap-backend.maewalliscorp.org/api`)

## Resumen

Como tienes un "Monorepo" (Frontend y Backend juntos), Plesk clonará todo el repositorio en ambos subdominios. El truco está en:
1. Apuntar el Document Root de cada subdominio a la carpeta correcta (`/backend` y `/frontend/dist`).
2. Utilizar los "scripts de implementación de Git" en Plesk para compilar React en un lado, y para instalar dependencias/migrar en el otro.
