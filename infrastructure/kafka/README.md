# MesaYA - Kafka Infrastructure

Esta carpeta contiene la configuración de Apache Kafka para la plataforma MesaYA.

## 📁 Estructura

```
kafka/
├── Dockerfile           # Imagen para inicializador de topics
├── docker-compose.yml   # Configuración standalone de Kafka
├── create-topics.sh     # Script de creación de topics
└── README.md           # Esta documentación
```

## 🚀 Uso

### Desde el proyecto principal

```bash
# Desde la raíz del proyecto
docker compose up -d kafka kafka-init
```

### Standalone (solo Kafka)

```bash
cd infrastructure/kafka
docker compose up -d
```

### Con Kafka UI

```bash
docker compose --profile ui up -d
# Acceder a http://localhost:8090
```

## 📋 Topics

### Topics de Eventos (Event-Driven)

Cada topic representa un dominio/agregado. El tipo de evento (`created`, `updated`, `deleted`, etc.) se especifica en el payload.

| Topic | Descripción |
|-------|-------------|
| `mesa-ya.restaurants.events` | Eventos de restaurantes |
| `mesa-ya.sections.events` | Eventos de secciones |
| `mesa-ya.tables.events` | Eventos de mesas |
| `mesa-ya.objects.events` | Eventos de objetos |
| `mesa-ya.section-objects.events` | Relación section-object |
| `mesa-ya.menus.events` | Eventos de menús |
| `mesa-ya.reviews.events` | Eventos de reseñas |
| `mesa-ya.images.events` | Eventos de imágenes |
| `mesa-ya.reservations.events` | Eventos de reservaciones |
| `mesa-ya.payments.events` | Eventos de pagos |
| `mesa-ya.subscriptions.events` | Eventos de suscripciones |
| `mesa-ya.auth.events` | Eventos de autenticación |
| `mesa-ya.owner-upgrade.events` | Solicitudes de upgrade |

### Topics de Auth MS (Request/Reply)

Para comunicación síncrona con el microservicio de autenticación.

| Topic | Descripción |
|-------|-------------|
| `auth.sign-up` / `auth.sign-up.reply` | Registro |
| `auth.login` / `auth.login.reply` | Login |
| `auth.refresh-token` / `auth.refresh-token.reply` | Refresh token |
| `auth.logout` / `auth.logout.reply` | Logout |
| `auth.find-user-by-id` / `auth.find-user-by-id.reply` | Buscar usuario por ID |
| `auth.find-user-by-email` / `auth.find-user-by-email.reply` | Buscar usuario por email |

## 📨 Formato de Mensajes

```json
{
  "event_type": "created | updated | deleted | status_changed",
  "entity_id": "uuid",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "data": {
    // Datos del evento
  },
  "metadata": {
    "user_id": "uuid",
    "correlation_id": "uuid"
  }
}
```

## 🔧 Configuración

### Puertos

| Puerto | Uso |
|--------|-----|
| 9092 | Comunicación interna (contenedores) |
| 29092 | Comunicación desde host (localhost) |
| 8090 | Kafka UI (solo con profile `ui`) |

### Variables de Entorno

| Variable | Valor Default | Descripción |
|----------|---------------|-------------|
| `KAFKA_BOOTSTRAP_SERVERS` | kafka:9092 | Servidor de Kafka |
| `CLUSTER_ID` | MkU3OEVBNTcwNTJENDM2Qk | ID del cluster KRaft |

## 🐛 Troubleshooting

### Ver estado de Kafka

```bash
docker compose ps
docker compose logs -f kafka
```

### Listar topics

```bash
docker exec mesaya-kafka /opt/kafka/bin/kafka-topics.sh \
  --list \
  --bootstrap-server localhost:9092
```

### Consumir mensajes de un topic

```bash
docker exec mesaya-kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic mesa-ya.reservations.events \
  --from-beginning
```

### Producir mensaje de prueba

```bash
docker exec -it mesaya-kafka /opt/kafka/bin/kafka-console-producer.sh \
  --bootstrap-server localhost:9092 \
  --topic mesa-ya.reservations.events
```

### Recrear topics

```bash
docker compose down
docker volume rm mesaya-kafka-data
docker compose up -d
```
