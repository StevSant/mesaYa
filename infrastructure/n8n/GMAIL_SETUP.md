# 📧 Configuración de Gmail OAuth en n8n

## ¿Por qué Gmail OAuth en lugar de SMTP/IMAP?

✅ **Más seguro:** OAuth2 es más seguro que contraseñas de aplicación
✅ **Más simple:** Una sola credential para enviar Y leer emails
✅ **Más confiable:** Menos problemas con límites de Gmail
✅ **Mejor integración:** Acceso a labels, threads, attachments

## 🚀 Configuración Paso a Paso

### 1. Crear Proyecto en Google Cloud

1. Ir a [Google Cloud Console](https://console.cloud.google.com/)
2. Crear nuevo proyecto → "MesaYA n8n"
3. Habilitar **Gmail API**:
   - API & Services → Library
   - Buscar "Gmail API" → Enable

### 2. Configurar Pantalla de Consentimiento OAuth

1. API & Services → OAuth consent screen
2. User Type: **External** → Create
3. Información de la aplicación:
   - App name: `MesaYA n8n`
   - User support email: `tu-email@gmail.com`
   - Developer contact: `tu-email@gmail.com`
4. Scopes → Add or Remove Scopes:
   - ✅ `https://www.googleapis.com/auth/gmail.send`
   - ✅ `https://www.googleapis.com/auth/gmail.readonly`
   - ✅ `https://www.googleapis.com/auth/gmail.modify`
5. Test users → Add Users → agregar tu email
6. Save and Continue

### 3. Crear Credenciales OAuth 2.0

1. API & Services → Credentials
2. Create Credentials → OAuth 2.0 Client ID
3. Application type: **Web application**
4. Name: `n8n MesaYA`
5. Authorized redirect URIs:

   ```
   http://localhost:5678/rest/oauth2-credential/callback
   ```

6. Create
7. **Copiar Client ID y Client Secret**

### 4. Configurar en n8n

1. Ir a <http://localhost:5678>
2. Login: `admin` / `mesaya_n8n_2024`
3. Settings → Credentials → Add Credential
4. Buscar "Gmail OAuth2"
5. Rellenar:
   - **Name:** `Gmail MesaYA`
   - **Client ID:** (del paso 3)
   - **Client Secret:** (del paso 3)
6. Click "Connect my account"
7. Seguir flujo de OAuth de Google
8. Dar permisos de Gmail
9. Save

### 5. Verificar Workflows

Los siguientes workflows ya están configurados para usar esta credential:

- ✅ **MesaYA - Payment Handler** → Envía emails de confirmación de pago
- ✅ **MesaYA - Reporte Diario de Reservaciones** → Envía reportes diarios
- ✅ **MesaYA - MCP Input Handler** → Lee emails y responde automáticamente

### 6. Activar Workflows

1. Ir a Workflows
2. Abrir cada workflow
3. Toggle "Active" → ON

## 🧪 Probar Envío de Email

1. Abrir workflow "MesaYA - Payment Handler"
2. Click en "Webhook" node → "Listen for test event"
3. Ejecutar:

```bash
curl -X POST http://localhost:5678/webhook/payment-webhook \
  -H "Content-Type: application/json" \
  -d '{
    "payment_id": "test_123",
    "status": "approved",
    "amount": 50,
    "currency": "USD",
    "metadata": {
      "reservation_id": "res_123",
      "service_type": "reservation",
      "customer_email": "tu-email@gmail.com",
      "customer_name": "Test User"
    }
  }'
```

1. Deberías recibir un email en `tu-email@gmail.com`

## 🔧 Troubleshooting

### Error: "Access blocked: This app's request is invalid"

**Solución:** Verifica que agregaste tu email en "Test users" en OAuth consent screen.

### Error: "redirect_uri_mismatch"

**Solución:** Verifica que la URI de redirección en Google Cloud coincida exactamente con:

```
http://localhost:5678/rest/oauth2-credential/callback
```

### Error: "insufficient_permissions"

**Solución:** Asegúrate de haber agregado los 3 scopes de Gmail en el paso 2.

### Emails no se envían

**Solución:**

1. Verifica que la credential "Gmail MesaYA" esté conectada (verde)
2. Abre Settings → Credentials → Gmail MesaYA → Test
3. Si falla, reconecta con "Connect my account"

## 📚 Documentación

- [Gmail API Scopes](https://developers.google.com/gmail/api/auth/scopes)
- [n8n Gmail Node](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.gmail/)
- [Google OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)

## 🎯 Límites de Gmail

- **Envío:** 500 emails/día (cuenta gratuita)
- **API Quota:** 1,000,000,000 quota units/día
- **Rate Limit:** 250 quota units/segundo/usuario

Para producción, considera usar Gmail Workspace (hasta 2,000 emails/día).
