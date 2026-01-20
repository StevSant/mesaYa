# ⚙️ MesaYA - n8n Automation Platform

Plataforma de automatización para el sistema MesaYA usando n8n.

## 📋 Descripción

Este módulo contiene la infraestructura y workflows de n8n para automatizar:

- **Notificaciones por email**: Confirmaciones de reservas, recordatorios
- **Procesamiento de eventos Kafka**: Consumo y reacción a eventos del sistema
- **Reportes automatizados**: Generación de informes diarios/semanales
- **Integraciones externas**: Conexión con servicios de terceros (email, SMS, etc.)

## 🏗️ Estructura

```
infrastructure/n8n/
├── docker-compose.yml       # Configuración de Docker
├── Dockerfile              # Imagen personalizada de n8n
├── entrypoint.sh           # Script de inicialización
└── workflows/              # Workflows de n8n
    ├── README.md           # Documentación de workflows
    ├── reservation-notification.json
    ├── kafka-reservation-consumer.json
    ├── reservation-reminder-24h.json
    └── daily-report.json
```

## 🚀 Instalación y Ejecución

### Prerrequisitos

- Docker y Docker Compose
- Kafka (debe estar corriendo)
- Servicio de email configurado (Gmail, SendGrid, etc.)

### Variables de Entorno

Crear un archivo `.env` en `infrastructure/n8n/`:

```env
# n8n Configuration
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=tu_password_seguro

# Database (opcional - usa SQLite por defecto)
N8N_DATABASE_TYPE=sqlite
N8N_DATABASE_SQLITE_DATABASE=/home/node/.n8n/database.sqlite

# Timezone
GENERIC_TIMEZONE=America/Guayaquil

# Kafka
KAFKA_BROKERS=kafka:9092

# Email Service (configurar según proveedor)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=tu-email@gmail.com
EMAIL_PASSWORD=tu-password-de-aplicacion
```

### Ejecutar

```bash
# Desde la raíz del proyecto
docker compose up -d n8n

# O desde infrastructure/n8n
cd infrastructure/n8n
docker compose up -d
```

### Acceder a la interfaz

Una vez iniciado, accede a:

```
http://localhost:5678
```

Credenciales por defecto (según tu .env):

- Usuario: `admin`
- Contraseña: La que configuraste en `N8N_BASIC_AUTH_PASSWORD`

## 📋 Workflows Disponibles

### 1. Notificación de Nueva Reservación

**Archivo:** `reservation-notification.json`

Envía email de confirmación cuando se crea una reserva.

**Trigger:** Webhook o evento de Kafka
**Acciones:**

- Recibe datos de la reserva
- Obtiene información del restaurante
- Envía email de confirmación al cliente

### 2. Consumidor de Eventos Kafka

**Archivo:** `kafka-reservation-consumer.json`

Consume eventos del topic de Kafka de reservaciones.

**Trigger:** Polling de Kafka
**Eventos:**

- `reservation.created` - Nueva reserva
- `reservation.status_changed` - Cambio de estado
- `reservation.cancelled` - Cancelación

### 3. Recordatorio 24h Antes

**Archivo:** `reservation-reminder-24h.json`

Envía recordatorio a clientes 24 horas antes de su reserva.

**Trigger:** Cron (cada hora)
**Acciones:**

- Busca reservas para las próximas 24h
- Filtra las que aún no tienen recordatorio enviado
- Envía email de recordatorio

### 4. Reporte Diario

**Archivo:** `daily-report.json`

Genera reporte diario de actividad para restaurantes.

**Trigger:** Cron (diario a las 8:00 AM)
**Acciones:**

- Recopila estadísticas del día anterior
- Genera resumen de reservas
- Envía reporte por email al dueño del restaurante

## 📥 Importar Workflows

1. Acceder a la interfaz de n8n (`http://localhost:5678`)
2. Ir a **Workflows** → **Import from File**
3. Seleccionar el archivo JSON del workflow
4. Configurar credenciales necesarias (email, Kafka, etc.)
5. Activar el workflow

## ⚙️ Configuración de Credenciales

### Email (SMTP)

1. En n8n, ir a **Credentials** → **Add Credential**
2. Seleccionar **SMTP**
3. Configurar:
   - Host: `smtp.gmail.com`
   - Port: `587`
   - User: Tu email
   - Password: Contraseña de aplicación

### Kafka

Para conectar con Kafka, usar el nodo **Kafka Trigger** con:

- Brokers: `kafka:9092` (dentro de Docker) o `localhost:9092` (local)
- Topics: `mesa-ya.reservations.events`, etc.
- Group ID: `n8n-consumer-group`

## 🔧 Personalización

### Crear un Nuevo Workflow

1. En n8n, click en **Add Workflow**
2. Agregar nodos:
   - **Trigger**: Webhook, Cron, Kafka, etc.
   - **Logic**: IF, Switch, Set, etc.
   - **Actions**: HTTP Request, Email, Database, etc.
3. Conectar los nodos
4. Probar el workflow
5. Exportar como JSON y guardar en `workflows/`

### Variables de Entorno en Workflows

Usar `{{ $env.VARIABLE_NAME }}` para acceder a variables de entorno.

Ejemplo:

```
{{ $env.EMAIL_USER }}
{{ $env.KAFKA_BROKERS }}
```

## 🧪 Testing

### Probar un Workflow

1. Abrir el workflow en n8n
2. Click en **Execute Workflow** o **Listen for Test Event**
3. Enviar datos de prueba
4. Verificar resultados en cada nodo

### Logs

Ver logs del contenedor:

```bash
docker compose logs -f n8n
```

## 🛠️ Tecnologías

- **n8n** - Plataforma de automatización workflow
- **Docker** - Contenedorización
- **Kafka** - Mensajería de eventos
- **SQLite/PostgreSQL** - Base de datos de workflows

## 📊 Mejores Prácticas

- **Nombrar workflows claramente**: Usar nombres descriptivos
- **Documentar nodos**: Agregar notas en nodos complejos
- **Manejar errores**: Configurar flujos de error
- **Versionar workflows**: Exportar y guardar en Git
- **Usar credenciales**: No hardcodear passwords

## 🔍 Monitoreo

- **Executions**: Ver historial de ejecuciones en n8n
- **Logs**: Revisar logs del contenedor Docker
- **Errores**: n8n muestra errores en la interfaz

## 📚 Más Información

- [Documentación oficial de n8n](https://docs.n8n.io/)
- [Documentación de workflows](./workflows/README.md)
- [Documentación principal del proyecto](../../docs/)

## 📄 Licencia

Este proyecto es parte de MesaYA y está desarrollado por estudiantes de ULEAM.
