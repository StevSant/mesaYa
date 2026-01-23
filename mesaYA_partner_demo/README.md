# MesaYA Partner Demo 🤝

Proyecto de demostración de interoperabilidad B2B mediante webhooks con el sistema MesaYA.

## 🎯 Objetivo

Este miniproyecto demuestra el **Pilar 2: Webhooks e Interoperabilidad B2B** implementando:

1. **Recepción de Webhooks**: Endpoint que recibe eventos de pago de MesaYA
2. **Verificación HMAC-SHA256**: Autenticación segura de webhooks entrantes
3. **Registro de Partner**: Auto-registro en el sistema MesaYA como partner B2B
4. **Envío de Webhooks**: Comunicación bidireccional enviando eventos de vuelta
5. **Dashboard de Eventos**: UI para visualizar la interoperabilidad en tiempo real

## 📋 Arquitectura

```
┌─────────────────────┐                    ┌─────────────────────┐
│    MesaYA           │    Webhook         │  Partner Demo       │
│  (mesaYA_Res +      │ ─────────────────► │  (Este proyecto)    │
│   mesaYA_payment)   │                    │                     │
│                     │ ◄───────────────── │  - Recibe eventos   │
│  - Gestión pagos    │   Webhook B2B      │  - Muestra en UI    │
│  - Partners API     │                    │  - Envía eventos    │
└─────────────────────┘                    └─────────────────────┘
```

## 🚀 Inicio Rápido

```bash
# Instalar dependencias
uv sync

# Ejecutar el servicio
uv run mesaya-partner

# O directamente con uvicorn
uv run uvicorn mesaya_partner_demo.app:app --reload --port 8088
```

El servicio estará disponible en: **<http://localhost:8088>**

## 🔗 Endpoints

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/` | GET | Dashboard principal con UI |
| `/api/webhook` | POST | Recibe webhooks de MesaYA |
| `/api/events` | GET | Lista eventos recibidos (JSON) |
| `/api/register` | POST | Registrarse como partner en MesaYA |
| `/api/send-event` | POST | Enviar evento a MesaYA |
| `/api/status` | GET | Estado del partner |
| `/health` | GET | Health check |

## 📡 Flujo de Interoperabilidad

### 1. Registro como Partner

```bash
POST /api/register
{
  "mesa_ya_url": "http://localhost:3000",  # URL de mesaYA_Res
  "events": ["payment.created", "payment.succeeded", "payment.failed"]
}
```

### 2. Recepción de Webhooks (automático)

Cuando se crea un pago en MesaYA, este partner recibe:

```json
{
  "event": "payment.created",
  "timestamp": "2026-01-22T15:30:00Z",
  "payment_id": "abc-123",
  "amount": "25.00",
  "status": "pending"
}
```

### 3. Envío de Webhook B2B (manual desde UI)

```bash
POST /api/send-event
{
  "event_type": "partner.order.ready",
  "data": { "order_id": "123", "message": "Pedido listo" }
}
```

## 🔐 Seguridad - HMAC-SHA256

Todos los webhooks incluyen verificación HMAC:

```
Header: X-Webhook-Signature: t=timestamp,v1=signature
```

La firma se genera como:

```python
signature = HMAC-SHA256(secret, f"{timestamp}.{payload}")
```

## 🎨 UI de Demostración

El dashboard en `/` muestra:

- ✅ Estado de conexión con MesaYA
- 📋 Lista de eventos recibidos en tiempo real
- 🔘 Botones para enviar eventos de prueba
- 📊 Información del partner registrado

## 📁 Estructura del Proyecto

```
mesaYA_partner_demo/
├── pyproject.toml
├── README.md
└── src/
    └── mesaya_partner_demo/
        ├── __init__.py
        ├── __main__.py
        ├── app.py              # Aplicación FastAPI
        ├── config.py           # Configuración
        ├── models.py           # Modelos de datos
        ├── webhook_service.py  # Lógica de webhooks
        ├── mesa_ya_client.py   # Cliente HTTP para MesaYA
        └── templates/
            └── dashboard.html  # UI del dashboard
```

## 🧪 Testing de Interoperabilidad

1. **Iniciar MesaYA** (mesaYA_Res en puerto 3000)
2. **Iniciar este servicio** (puerto 8088)
3. **Registrar el partner** desde el dashboard
4. **Crear un pago** en MesaYA
5. **Verificar** que el evento aparece en el dashboard del partner
6. **Enviar evento** desde el partner y verificar recepción en MesaYA

## 📝 Notas

- Este proyecto usa **datos en memoria** (sin base de datos)
- Ideal para **demostraciones** y **pruebas de integración**
- Implementa el patrón de **comunicación bidireccional B2B**
