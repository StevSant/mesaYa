# =============================================================================
# MesaYA - Kafka Initializer Dockerfile
# =============================================================================
# Este Dockerfile crea una imagen para inicializar los topics de Kafka.
# Se ejecuta una sola vez después de que Kafka esté healthy.
#
# Build:
#   docker build -t mesaya-kafka-init ./infrastructure/kafka
#
# Nota: Kafka en sí usa la imagen oficial apache/kafka:3.9.0 directamente.
#       Este Dockerfile es solo para el inicializador de topics.
# =============================================================================

FROM apache/kafka:3.9.0

LABEL maintainer="MesaYA Team"
LABEL description="Kafka Topics Initializer for MesaYA Platform"
LABEL version="1.0.0"

# Copiar el script de creación de topics con permisos de ejecución
COPY --chmod=755 create-topics.sh /opt/kafka-init/create-topics.sh

# Variables de entorno por defecto
ENV KAFKA_BOOTSTRAP_SERVERS=kafka:9092

# Ejecutar el script de inicialización
ENTRYPOINT ["/bin/bash", "/opt/kafka-init/create-topics.sh"]
