# ⚙️ MesaYA - n8n Event Bus

**Principio fundamental:** "Todo evento externo pasa por n8n"

## 🚀 Quick Start

1. **Iniciar n8n:** `docker compose up -d`
2. **Importar workflows:** `.\import-workflows-docker.ps1`
3. **Acceder:** <http://localhost:5678> (admin / mesaya_n8n_2024)
4. **Activar** cada workflow en la UI

## ✅ Workflows Obligatorios

1. **Payment Handler** - `/payment-webhook` - Pagos → Servicio → WebSocket → Email → Partner
2. **Partner Handler** - `/partner-webhook` - Eventos externos con HMAC
3. **MCP Input Handler** - Telegram/Email → AI → Respuesta
4. **Scheduled Tasks** - Cron diario (reportes, limpieza)

## 🔧 Credenciales (Settings → Credentials)

- **SMTP:** smtp.gmail.com:587
- **Telegram Bot:** Token de @BotFather
- **Email IMAP:** imap.gmail.com:993

## 🧪 Testing

```bash
curl -X POST http://localhost:5678/webhook/payment-webhook \
  -H "Content-Type: application/json" \
  -d '{"payment_id":"pay_123","status":"approved","amount":50,"currency":"USD","metadata":{"reservation_id":"res_123","service_type":"reservation","customer_email":"test@example.com","customer_name":"Test"}}'
```

Ver [workflows/README.md](workflows/README.md) para más detalles.
