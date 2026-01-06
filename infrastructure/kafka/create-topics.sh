#!/bin/bash
# =============================================================================
# MesaYA - Script de inicialización de topics de Kafka
# =============================================================================
# DISEÑO: Un topic por dominio/agregado (Event-Driven Architecture)
# El tipo de evento se especifica en el payload con `event_type`
#
# Payload esperado:
# {
#   "event_type": "created" | "updated" | "deleted" | "status_changed" | ...,
#   "entity_id": "uuid",
#   "timestamp": "ISO 8601",
#   "data": { ... },
#   "metadata": { "user_id": "...", "correlation_id": "..." }
# }
# =============================================================================

set -euo pipefail

BOOTSTRAP_SERVER="${KAFKA_BOOTSTRAP_SERVERS:-kafka:9092}"

echo "=============================================="
echo "  MesaYA - Inicializando Topics de Kafka"
echo "=============================================="
echo "Bootstrap Server: ${BOOTSTRAP_SERVER}"
echo ""
echo "Diseño: Un topic por dominio (event_type en payload)"
echo ""

# Lista de topics - UN TOPIC POR ENTIDAD/DOMINIO
# El event_type (created, updated, deleted, status_changed, etc.) va en el payload
TOPICS=(
  "mesa-ya.restaurants.events"      # Eventos de restaurantes
  "mesa-ya.sections.events"         # Eventos de secciones (áreas del restaurante)
  "mesa-ya.tables.events"           # Eventos de mesas (CRUD, no efímeros)
  "mesa-ya.objects.events"          # Eventos de objetos (mobiliario/decoración)
  "mesa-ya.section-objects.events"  # Eventos de relación section-object
  "mesa-ya.menus.events"            # Eventos de menús (incluye dishes como sub-entidad)
  "mesa-ya.reviews.events"          # Eventos de reseñas
  "mesa-ya.images.events"           # Eventos de imágenes
  "mesa-ya.reservations.events"     # Eventos de reservaciones
  "mesa-ya.payments.events"         # Eventos de pagos
  "mesa-ya.subscriptions.events"    # Eventos de suscripciones (incluye planes)
  "mesa-ya.auth.events"             # Eventos de autenticación/autorización
  "mesa-ya.owner-upgrade.events"    # Eventos de solicitudes de upgrade a owner
)

# Topics de Auth MS para comunicación request/reply (Gateway <-> Auth MS)
AUTH_TOPICS=(
  "auth.sign-up"
  "auth.sign-up.reply"
  "auth.login"
  "auth.login.reply"
  "auth.refresh-token"
  "auth.refresh-token.reply"
  "auth.logout"
  "auth.logout.reply"
  "auth.find-user-by-id"
  "auth.find-user-by-id.reply"
  "auth.find-user-by-email"
  "auth.find-user-by-email.reply"
)

echo "Creando ${#TOPICS[@]} topics de eventos..."
echo ""

for topic in "${TOPICS[@]}"; do
  echo "  → Creando topic: ${topic}"
  /opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --create \
    --if-not-exists \
    --topic "${topic}" \
    --partitions 3 \
    --replication-factor 1
done

echo ""
echo "Creando ${#AUTH_TOPICS[@]} topics de Auth MS (request/reply)..."
echo ""

for topic in "${AUTH_TOPICS[@]}"; do
  echo "  → Creando topic: ${topic}"
  /opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --create \
    --if-not-exists \
    --topic "${topic}" \
    --partitions 1 \
    --replication-factor 1
done

echo ""
echo "=============================================="
echo "  ✓ Todos los topics han sido creados"
echo "=============================================="
echo ""
echo "Topics de eventos disponibles:"
for topic in "${TOPICS[@]}"; do
  echo "  - ${topic}"
done
echo ""
echo "Topics de Auth MS (request/reply):"
for topic in "${AUTH_TOPICS[@]}"; do
  echo "  - ${topic}"
done
echo ""
echo "NOTA: Los eventos efímeros (selecting/released de mesas)"
echo "      se manejan directamente por WebSocket, no por Kafka."
echo "=============================================="
