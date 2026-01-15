# MesaYA - n8n Workflows

Esta carpeta contiene los workflows de automatización de n8n para la plataforma MesaYA.

## 📁 Estructura

```
workflows/
├── reservation-notification.json    # Notificación al crear reservación
├── kafka-reservation-consumer.json  # Consumidor de eventos Kafka
├── reservation-reminder-24h.json    # Recordatorio 24h antes
└── daily-report.json               # Reporte diario para restaurantes
```

## 🚀 Workflows Disponibles

### 1. Notificación de Nueva Reservación

**Archivo:** `reservation-notification.json`

- **Trigger:** Webhook POST `/reservation-webhook`
- **Función:** Envía email de confirmación al cliente cuando se crea una reservación
- **Flujo:**
  1. Recibe evento de reservación creada
  2. Obtiene información del restaurante
  3. Obtiene información de la mesa
  4. Envía email de confirmación

### 2. Consumidor de Kafka (Reservaciones)

**Archivo:** `kafka-reservation-consumer.json`

- **Trigger:** Polling cada 30 segundos
- **Función:** Consume eventos del topic `mesa-ya.reservations.events`
- **Eventos manejados:**
  - `created` - Nueva reservación
  - `status_changed` - Cambio de estado
  - `cancelled` - Cancelación

### 3. Recordatorio 24h Antes

**Archivo:** `reservation-reminder-24h.json`

- **Trigger:** Cada hora
- **Función:** Envía recordatorio a clientes 24h antes de su reservación
- **Flujo:**
  1. Busca reservaciones confirmadas para las próximas 24h
  2. Filtra las que están en el rango de 23-25h
  3. Envía email de recordatorio

### 4. Reporte Diario

**Archivo:** `daily-report.json`

- **Trigger:** Diariamente a las 8:00 AM
- **Función:** Envía reporte diario a dueños de restaurantes
- **Incluye:**
  - Total de reservaciones del día
  - Total de comensales esperados
  - Hora pico
  - Detalle de cada reservación

## 📥 Importar Workflows

### Opción 1: Importación Automática

Los workflows se importan automáticamente al iniciar n8n si están en esta carpeta.

### Opción 2: Importación Manual

1. Acceder a n8n: <http://localhost:5678>
2. Ir a **Settings** → **Import**
3. Seleccionar el archivo JSON del workflow
4. Activar el workflow

### Opción 3: CLI de n8n

```bash
docker exec -it mesaya-n8n n8n import:workflow --input=/home/node/workflows/reservation-notification.json
```

## ⚙️ Configuración Requerida

### Variables de Entorno

Los workflows usan las siguientes variables de entorno (configurar en docker-compose):

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `MESAYA_API_URL` | URL del backend NestJS | <http://host.docker.internal:3000> |
| `MESAYA_GRAPHQL_URL` | URL del servidor GraphQL | <http://host.docker.internal:8000/graphql> |
| `MESAYA_WS_URL` | URL del WebSocket | ws://host.docker.internal:8080 |
| `MESAYA_CHATBOT_URL` | URL del chatbot | <http://host.docker.internal:8001> |

### Credenciales SMTP

Para enviar emails, configurar credenciales SMTP en n8n:

1. Ir a **Credentials** → **New**
2. Seleccionar **SMTP**
3. Configurar servidor, puerto, usuario y contraseña

## 🔧 Desarrollo de Nuevos Workflows

### Convenciones

- Nombres descriptivos en español
- Tags para categorización: `reservations`, `notifications`, `kafka`, `scheduled`, `reports`
- Usar variables de entorno para URLs de servicios
- Incluir manejo de errores

### Template Básico

```json
{
  "name": "MesaYA - [Nombre del Workflow]",
  "nodes": [...],
  "connections": {...},
  "settings": {
    "executionOrder": "v1"
  },
  "tags": [...],
  "active": false
}
```

## 📊 Monitoreo

### Ver Ejecuciones

1. Acceder a n8n: <http://localhost:5678>
2. Ir a **Executions**
3. Filtrar por workflow o estado

### Logs

```bash
docker compose logs -f n8n
```

## 🐛 Troubleshooting

### Workflow no se ejecuta

1. Verificar que el workflow esté activado (toggle verde)
2. Revisar logs de n8n
3. Verificar conectividad con servicios externos

### Error de conexión a servicios

1. Verificar que los microservicios estén corriendo
2. Comprobar las URLs en variables de entorno
3. Desde dentro del contenedor n8n, `host.docker.internal` apunta al host

### Kafka no recibe mensajes

1. Verificar que Kafka esté healthy: `docker compose ps`
2. Revisar topics: `docker exec mesaya-kafka /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092`
