# =============================================================================
# MesaYA - n8n Workflow Automation Dockerfile
# =============================================================================
# n8n es una herramienta de automatización de flujos de trabajo con interfaz
# visual. Esta configuración incluye:
#   - Persistencia de datos y workflows
#   - Integración con Kafka para eventos
#   - Webhooks para triggers externos
#   - Credenciales encriptadas
#
# Build:
#   docker build -t mesaya-n8n ./infrastructure/n8n
#
# Variables de entorno requeridas:
#   - N8N_ENCRYPTION_KEY: Clave para encriptar credenciales (generar con openssl)
#   - N8N_BASIC_AUTH_PASSWORD: Contraseña de acceso a n8n
# =============================================================================

FROM n8nio/n8n:latest

LABEL maintainer="MesaYA Team"
LABEL description="n8n Workflow Automation for MesaYA Platform"
LABEL version="1.0.0"

# =============================================================================
# Variables de entorno - Configuración base
# =============================================================================

# Configuración general de n8n
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV GENERIC_TIMEZONE=America/Guayaquil
ENV TZ=America/Guayaquil

# Rutas de datos
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV N8N_TEMPLATES_ENABLED=true
ENV N8N_PERSONALIZATION_ENABLED=false

# Configuración de ejecución de workflows
ENV EXECUTIONS_MODE=regular
ENV EXECUTIONS_TIMEOUT=300
ENV EXECUTIONS_TIMEOUT_MAX=600
ENV EXECUTIONS_DATA_SAVE_ON_ERROR=all
ENV EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
ENV EXECUTIONS_DATA_SAVE_ON_PROGRESS=true
ENV EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true
ENV EXECUTIONS_DATA_PRUNE=true
ENV EXECUTIONS_DATA_MAX_AGE=336

# Configuración de logs
ENV N8N_LOG_LEVEL=info
ENV N8N_LOG_OUTPUT=console

# Webhooks
ENV WEBHOOK_URL=http://localhost:5678/
ENV N8N_PAYLOAD_SIZE_MAX=16

# Autenticación básica (se sobrescribe con variables de entorno en compose)
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin

# Métricas (Prometheus)
ENV N8N_METRICS=true
ENV N8N_METRICS_PREFIX=n8n_

# Configuración de base de datos SQLite (default)
ENV DB_TYPE=sqlite
ENV DB_SQLITE_VACUUM_ON_STARTUP=true

# Deshabilitar telemetría
ENV N8N_DIAGNOSTICS_ENABLED=false
ENV N8N_VERSION_NOTIFICATIONS_ENABLED=false

# =============================================================================
# Configuración de nodos comunitarios
# =============================================================================
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true
ENV NODE_FUNCTION_ALLOW_BUILTIN=*
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*

# =============================================================================
# Puertos expuestos
# =============================================================================
EXPOSE 5678

# =============================================================================
# Healthcheck
# =============================================================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1

# =============================================================================
# Nota: n8n start se ejecuta automáticamente por la imagen base
# Los workflows se pueden importar manualmente o montar como volumen
# =============================================================================
