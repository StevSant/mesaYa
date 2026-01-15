#!/bin/bash
# =============================================================================
# MesaYA - n8n Entrypoint Script
# =============================================================================
# Este script se ejecuta al iniciar el contenedor de n8n.
# Importa workflows predefinidos y luego inicia n8n.
# =============================================================================

set -e

echo "=============================================="
echo "  MesaYA - Iniciando n8n"
echo "=============================================="
echo ""

# Directorio de workflows predefinidos
WORKFLOWS_DIR="/home/node/.n8n/workflows"
IMPORT_DIR="/home/node/workflows"

# Función para importar workflows
import_workflows() {
    if [ -d "$IMPORT_DIR" ] && [ "$(ls -A $IMPORT_DIR 2>/dev/null)" ]; then
        echo "📂 Importando workflows desde $IMPORT_DIR..."
        echo ""

        for workflow_file in "$IMPORT_DIR"/*.json; do
            if [ -f "$workflow_file" ]; then
                filename=$(basename "$workflow_file")
                echo "  → Importando: $filename"

                # Importar el workflow usando la CLI de n8n
                n8n import:workflow --input="$workflow_file" 2>/dev/null || {
                    echo "    ⚠️  Advertencia: No se pudo importar $filename"
                }
            fi
        done

        echo ""
        echo "✅ Importación de workflows completada"
    else
        echo "ℹ️  No hay workflows para importar en $IMPORT_DIR"
    fi
}

# Esperar a que la base de datos esté lista
echo "⏳ Esperando inicialización de base de datos..."
sleep 5

# Importar workflows (en segundo plano para no bloquear el inicio)
(
    sleep 30  # Esperar a que n8n esté completamente iniciado
    import_workflows
) &

echo ""
echo "🚀 Iniciando n8n..."
echo "   URL: http://localhost:${N8N_PORT:-5678}"
echo "   Usuario: ${N8N_BASIC_AUTH_USER:-admin}"
echo ""
echo "=============================================="

# Iniciar n8n
exec n8n start
