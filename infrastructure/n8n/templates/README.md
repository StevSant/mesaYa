# Plantillas de Email para n8n - MesaYA

Este directorio contiene las plantillas HTML para los correos electrónicos enviados por los workflows de n8n.

## 📧 Plantillas Disponibles

### `daily-report-email.html`

Plantilla para el reporte diario de reservaciones.

**Características:**

- ✨ Diseño responsivo (mobile-first)
- 🎨 Usa los colores oficiales de MesaYA (`#f4511f` - primary)
- 📊 Grid de estadísticas con 4 métricas clave
- 📋 Tabla detallada de reservaciones
- 🔔 Mensaje diferente para días sin reservaciones
- 💡 Tips y recomendaciones
- 🎯 Compatible con clientes de email (Gmail, Outlook, etc.)

**Variables disponibles:**

```javascript
$json.restaurantName      // Nombre del restaurante
$json.date               // Fecha del reporte
$json.ownerEmail         // Email del propietario
$json.summary.totalReservations  // Total de reservaciones
$json.summary.totalGuests        // Total de comensales
$json.summary.peakHour          // Hora pico
$json.summary.byStatus          // Reservaciones por estado
$json.reservations[]            // Array con detalles de reservaciones
```

## 🎨 Paleta de Colores MesaYA

La plantilla usa los siguientes colores del frontend:

```css
--color-primary: #f4511f      /* Naranja principal */
--color-background: #f8fafc   /* Fondo claro (slate-50) */
--color-surface: #ffffff      /* Superficie blanca */
--color-title: #0f172a        /* Títulos (slate-900) */
--color-paragraph: #334155    /* Texto (slate-700) */
--color-text-muted: #64748b   /* Texto secundario (slate-500) */
--color-border: #e2e8f0       /* Bordes (slate-200) */
```

### Estados de Reservación

```css
.status-confirmed  → Verde (#dcfce7 bg, #166534 text)
.status-pending    → Amarillo (#fef3c7 bg, #92400e text)
.status-cancelled  → Rojo (#fee2e2 bg, #991b1b text)
.status-completed  → Azul (#dbeafe bg, #1e40af text)
```

## 📱 Responsividad

La plantilla se adapta automáticamente a dispositivos móviles:

- **Desktop**: Grid de 4 columnas para estadísticas
- **Mobile**: Grid de 2x2 para estadísticas
- Tabla responsive con texto más pequeño
- Padding reducido en pantallas pequeñas

## 🔧 Uso en n8n

### Inline (Actual)

La plantilla está minificada e incrustada directamente en el workflow JSON para facilitar la portabilidad.

### Cómo actualizar la plantilla

1. **Edita** el archivo `daily-report-email.html` con tu editor favorito
2. **Minifica** el HTML (opcional, pero recomendado para performance):
   - Online: <https://www.minifier.org/>
   - CLI: `npm install -g html-minifier` → `html-minifier daily-report-email.html`
3. **Reemplaza** el contenido en el workflow JSON:
   - Abre `../workflows/daily-report.json`
   - Busca el campo `"html"` en el nodo "Enviar Reporte"
   - Reemplaza con la versión minificada
4. **Importa** el workflow actualizado en n8n

### Testing Local

Para probar la plantilla localmente:

```bash
# Abre el archivo HTML directamente en el navegador
open daily-report-email.html

# O usa un servidor local
npx http-server . -p 8080
# Visita http://localhost:8080/daily-report-email.html
```

## 📝 Ejemplos de Uso

### Con Reservaciones

Muestra:

- Grid de 4 estadísticas (reservaciones, comensales, hora pico, confirmadas)
- Mensaje de resumen personalizado
- Tabla completa con todas las reservaciones del día
- Tip del día

### Sin Reservaciones

Muestra:

- Mensaje amigable indicando que no hay reservaciones
- Call-to-action para promocionar el negocio
- Tip del día

## 🚀 Futuras Plantillas

Otras plantillas que se pueden crear:

- `payment-confirmation-email.html` - Confirmación de pagos
- `reservation-reminder-email.html` - Recordatorio de reservación
- `weekly-summary-email.html` - Resumen semanal
- `cancellation-notice-email.html` - Aviso de cancelación

## 📚 Referencias

- [Tailwind CSS](https://tailwindcss.com) - Sistema de diseño usado en mesaYA
- [n8n Email Node](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.emailsend/) - Documentación
- [Email HTML Best Practices](https://www.campaignmonitor.com/css/) - Compatibilidad con clientes

---

**Nota:** Estas plantillas están diseñadas para funcionar en la mayoría de clientes de email (Gmail, Outlook, Apple Mail, etc.) usando técnicas de HTML/CSS inline y estilos seguros.
