# API Gateway Infra (Nginx)

Infraestructura de API Gateway usando Nginx como reverse proxy para exponer una API pública por HTTPS/TLS, ocultar servicios internos y enrutar:

- `/auth/*` -> Auth Service
- `/dicom/*` -> Medical Imaging Service

## Características

- HTTPS/TLS con rutas de certificados configurables por variables de entorno.
- Redirección automática HTTP -> HTTPS.
- CORS configurable.
- CORS con validación de origen exacto contra `CORS_ALLOW_ORIGIN`.
- Validación JWT en gateway mediante `auth_request` hacia endpoint interno del Auth Service.
- Logs de acceso y error en Nginx.
- Seguridad básica (`server_tokens off`, headers de seguridad, límite de body).
- Servicios internos no expuestos públicamente (solo `expose` en red interna de Docker).

## Estructura

```text
.
├── Dockerfile
├── docker-compose.yml
├── .env.example
└── nginx
    ├── entrypoint.sh
    └── nginx.conf.template
```

## Variables de entorno

Copiar el ejemplo y ajustar valores reales:

```bash
cp .env.example .env
```

Variables relevantes:

- `TLS_CERT_PATH`, `TLS_KEY_PATH`: rutas dentro del contenedor.
- `TLS_CERT_HOST_PATH`, `TLS_KEY_HOST_PATH`: rutas del host montadas en `docker-compose`.
- `AUTH_SERVICE_HOST`, `AUTH_SERVICE_PORT`, `AUTH_VALIDATE_PATH`.
- `MEDICAL_IMAGING_SERVICE_HOST`, `MEDICAL_IMAGING_SERVICE_PORT`.
- `CORS_ALLOW_ORIGIN`, `CORS_ALLOW_CREDENTIALS`.

## Flujo de requests

1. **Frontend** llama únicamente al dominio público del gateway (`https://api.example.com`).
2. Si la ruta es **`/auth/*`**, el gateway reenvía al **Auth Service**.
3. Si la ruta es **`/dicom/*`**, el gateway exige JWT y ejecuta validación interna (`auth_request`) contra el **Auth Service**.
4. Si JWT es válido, el gateway reenvía al **Medical Imaging Service**.
5. El frontend nunca accede directamente a servicios internos.

## Ejecución

```bash
docker compose --env-file .env up -d --build
```

## Notas de producción

- Reemplazar imágenes de ejemplo (`AUTH_SERVICE_IMAGE`, `MEDICAL_IMAGING_SERVICE_IMAGE`) por imágenes reales.
- Usar certificados válidos de CA pública (o ACM/Let's Encrypt según entorno).
- Asegurar permisos restrictivos para la clave privada TLS en host (`chmod 600` para `TLS_KEY_HOST_PATH`).
- Mantener `.env` fuera de control de versiones y sin secretos en texto plano del repositorio.
