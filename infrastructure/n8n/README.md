# ⚙️ MesaYA - n8n Event Bus

**Principio fundamental:** "Todo evento externo pasa por n8n"

## 🚀 Quick Start

1. **Configurar variables:** `cp .env.example .env` → Edita `.env` con tus valores
2. **Iniciar n8n:** `docker compose up -d`
3. **Importar workflows:** `.\import-workflows-docker.ps1`
4. **Configurar Gmail OAuth:** Sigue [GMAIL_SETUP.md](GMAIL_SETUP.md) para configurar Gmail
5. **Acceder:** <http://localhost:5678> (admin / mesaya_n8n_2024)
6. **Activar** workflows (toggle ON en cada uno)

## ✅ Workflows Obligatorios

1. **Payment Handler** - `/payment-webhook` - Pagos → Servicio → WebSocket → Email → Partner
2. **Partner Handler** - `/partner-webhook` - Eventos externos con HMAC
3. **MCP Input Handler** - Telegram/Email → AI → Respuesta
4. **Scheduled Tasks** - Cron diario (reportes, limpieza)

## 🔧 Configuración

### 1. Obtener Token de Servicio (API Key)

Los workflows necesitan un token JWT de **larga duración (365 días)** para acceder a endpoints protegidos del backend:

```bash
# Paso 1: Login como admin (obtener token temporal)
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@mesaya.com", "password": "Admin123!@#"}'

# Copiar el access_token de la respuesta

# Paso 2: Generar service token de larga duración
curl -X POST http://localhost:3000/api/v1/auth/service-token \
  -H "Authorization: Bearer <TOKEN_ADMIN_DEL_PASO_1>"

# Copiar el access_token de esta respuesta (durará 365 días)
```

### 2. Configurar Token en n8n

**Opción A: En el archivo .env**

```bash
# Editar infrastructure/n8n/.env
MESAYA_API_TOKEN=<TOKEN_DEL_PASO_2>
```

**Opción B: En la UI de n8n**

1. Ir a <http://localhost:5678>
2. Login: admin / mesaya_n8n_2024
3. Settings → Variables
4. Editar `MESAYA_API_TOKEN` y pegar el token
5. Save

### 3. Variables de Entorno (.env)

Las variables están en `.env` y son leídas automáticamente por Docker:

- **URLs de servicios:** `MESAYA_API_URL`, `MESAYA_WS_URL`, `MESAYA_CHATBOT_URL`, etc.
- **Webhooks externos:** `PARTNER_WEBHOOK_URL`, `PARTNER_WEBHOOK_SECRET`
- **Autenticación:** `MESAYA_API_TOKEN` (token de larga duración del paso 2)

### 4. Credenciales (Settings → Credentials en UI)

n8n requiere configurar estas credenciales en la interfaz web:

- **Gmail OAuth2:** Autenticación de Google para enviar/leer emails (reemplaza SMTP/IMAP)
  1. Settings → Credentials → Add Credential → Gmail OAuth2
  2. Name: "Gmail MesaYA"
  3. Seguir flujo de OAuth de Google
  4. Dar permisos de lectura/escritura de Gmail

- **Telegram Bot:** Token de @BotFather (para recibir/enviar mensajes)
  1. Settings → Credentials → Add Credential → Telegram API
  2. Pegar token del bot de Telegram

## 🧪 Testing

```bash
curl -X POST http://localhost:5678/webhook/payment-webhook \
  -H "Content-Type: application/json" \
  -d '{"payment_id":"pay_123","status":"approved","amount":50,"currency":"USD","metadata":{"reservation_id":"res_123","service_type":"reservation","customer_email":"test@example.com","customer_name":"Test"}}'
```

Ver [workflows/README.md](workflows/README.md) para más detalles.
