# Payment System Refactoring - Complete

## Summary

The payment system has been refactored to:

1. **Persist payments in PostgreSQL** instead of in-memory dictionaries
2. **Trigger webhooks** to registered partners when payments succeed
3. **Use mesaYA_Res as API Gateway** with Payment MS handling all payment logic
4. **Remove legacy controllers** from mesaYA_Res

## Architecture Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│   Frontend      │────▶│  mesaYA_Res     │────▶│  Payment MS     │
│   (Angular)     │     │  (NestJS)       │     │  (FastAPI)      │
│                 │     │  API Gateway    │     │                 │
└─────────────────┘     └────────┬────────┘     └────────┬────────┘
                                 │                       │
                                 │                       │
                                 ▼                       ▼
                        ┌─────────────────┐     ┌─────────────────┐
                        │                 │     │                 │
                        │  PostgreSQL     │◀────│  Partners       │
                        │  (Shared DB)    │     │  (Webhooks)     │
                        │                 │     │                 │
                        └─────────────────┘     └─────────────────┘
```

## Changes Made

### Payment Microservice (mesaYA_payment_ms)

#### New Files Created

1. **`shared/infrastructure/database/connection.py`**
   - Async SQLAlchemy connection management
   - `init_db()`, `close_db()`, `get_db_session()` functions
   - Connection pooling with pre-ping

2. **`shared/infrastructure/database/models.py`**
   - `PaymentModel` ORM class
   - Maps to existing `payments` table
   - `to_domain()` and `from_domain()` conversion methods

3. **`features/payments/infrastructure/repository.py`**
   - `PaymentRepository` class
   - Full CRUD: `create()`, `get_by_id()`, `update_status()`, `get_by_reservation_id()`
   - Async database operations

4. **`shared/infrastructure/http_clients/mesa_ya_res_client.py`**
   - `MesaYaResClient` class
   - Fetches partners from mesaYA_Res API
   - `get_partners_for_event()`, `get_all_active_partners()`

#### Modified Files

1. **`features/payments/presentation/router.py`**
   - Replaced `_payments_store` dict with `PaymentRepository`
   - All endpoints now use database persistence
   - Added dependency injection for repository

2. **`features/webhooks/presentation/router.py`**
   - Added `/api/webhooks/notify` endpoint (called by gateway)
   - `send_partner_webhooks()` fetches partners from mesaYA_Res
   - HMAC signature generation for webhook security

3. **`features/partners/presentation/router.py`**
   - Now read-only (fetches from mesaYA_Res API)
   - Removed local `_partners_store` dict
   - All write operations removed

4. **`app.py`**
   - Added `await init_db()` on startup
   - Added `await close_db()` on shutdown

### mesaYA_Res (NestJS API Gateway)

#### Modified Files

1. **`payment-ms.types.ts`**
   - Added `NotifyWebhookMsRequest` interface
   - Added `NotifyWebhookMsResponse` interface
   - Extended `VerifyPaymentMsResponse` with sync fields

2. **`payment-ms-client.service.ts`**
   - Added `notifyWebhook()` method
   - Calls Payment MS `/api/webhooks/notify`
   - Non-blocking (doesn't throw on errors)

3. **`payment-gateway.controller.ts`**
   - `verifyPayment()` now triggers webhooks on success
   - Fire-and-forget pattern for webhook notification
   - Logs webhook results

4. **`payment.module.ts`**
   - Removed legacy controllers:
     - `PaymentsController`
     - `PaymentsAdminController`
     - `PaymentsUserController`
     - `PaymentsRestaurantController`
   - Kept: `PaymentGatewayController`, `PaymentWebhookController`
   - Removed unused use-case providers

5. **`presentation/index.ts`**
   - Updated exports to only include active controllers

6. **`application/use-cases/index.ts`**
   - Added deprecation comments for legacy use cases

## Flow Diagram

### Payment Creation Flow

```
1. User clicks "Pay" → Frontend
2. Frontend → POST /payment-gateway/reservations/checkout
3. PaymentGatewayController validates user owns reservation
4. PaymentGatewayController → PaymentMsClient.createPayment()
5. PaymentMsClient → POST http://payment-ms:8003/api/payments
6. Payment MS creates payment in PostgreSQL
7. Payment MS returns checkout_url
8. User redirected to checkout page
```

### Payment Verification Flow

```
1. User returns from checkout → Frontend
2. Frontend → POST /payment-gateway/:paymentId/verify
3. PaymentGatewayController → PaymentMsClient.verifyPayment()
4. PaymentMsClient → POST http://payment-ms:8003/api/payments/:id/verify
5. Payment MS verifies with provider (Stripe/Mock)
6. Payment MS updates status in PostgreSQL
7. PaymentGatewayController triggers webhooks (fire & forget)
8. PaymentMsClient → POST http://payment-ms:8003/api/webhooks/notify
9. Payment MS fetches partners from mesaYA_Res
10. Payment MS sends webhooks to all active partners
```

## Configuration Required

### Payment MS (.env)

```env
# Database (same as mesaYA_Res)
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/mesaya_db

# Internal services
MESA_YA_RES_URL=http://localhost:3000
N8N_WEBHOOK_URL=http://localhost:5678/webhook

# Payment provider
PAYMENT_PROVIDER=mock  # or "stripe"
```

### mesaYA_Res (.env)

```env
# Payment MS
PAYMENT_MS_URL=http://localhost:8003
PAYMENT_MS_TIMEOUT=30000
```

## Database Schema

The Payment MS uses the existing `payments` table created by TypeORM:

```sql
-- Core columns (existing)
payment_id      UUID PRIMARY KEY
reservation_id  UUID REFERENCES reservations(id)
subscription_id UUID REFERENCES subscriptions(id)
amount          DECIMAL(10,2)
payment_status  payment_status_enum  -- 'pending', 'succeeded', 'failed', etc.
created_at      TIMESTAMP
updated_at      TIMESTAMP

-- Extended columns (may need migration)
user_id           UUID
currency          VARCHAR(3)
payment_type      VARCHAR(20)
provider          VARCHAR(50)
provider_payment_id VARCHAR(255)
checkout_url      TEXT
payer_email       VARCHAR(255)
payer_name        VARCHAR(255)
description       TEXT
metadata          JSONB
idempotency_key   VARCHAR(255) UNIQUE
failure_reason    TEXT
```

## Migration Required

To add the extended columns, run this SQL migration:

```sql
-- Add new columns for Payment MS
ALTER TABLE payments
ADD COLUMN IF NOT EXISTS user_id UUID,
ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'usd',
ADD COLUMN IF NOT EXISTS payment_type VARCHAR(20) DEFAULT 'reservation',
ADD COLUMN IF NOT EXISTS provider VARCHAR(50) DEFAULT 'mock',
ADD COLUMN IF NOT EXISTS provider_payment_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS checkout_url TEXT,
ADD COLUMN IF NOT EXISTS payer_email VARCHAR(255),
ADD COLUMN IF NOT EXISTS payer_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS idempotency_key VARCHAR(255) UNIQUE,
ADD COLUMN IF NOT EXISTS failure_reason TEXT;
```

## API Endpoints

### mesaYA_Res Gateway Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/payment-gateway/reservations/checkout` | Create payment checkout |
| GET | `/payment-gateway/:paymentId` | Get payment details |
| POST | `/payment-gateway/:paymentId/verify` | Verify payment status |
| POST | `/payment-gateway/:paymentId/cancel` | Cancel pending payment |
| GET | `/payment-gateway/health/check` | Health check |

### Payment MS Internal Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/payments` | Create payment |
| GET | `/api/payments/:id` | Get payment |
| POST | `/api/payments/:id/verify` | Verify payment |
| POST | `/api/payments/:id/cancel` | Cancel payment |
| POST | `/api/webhooks/notify` | Trigger partner webhooks |
| GET | `/api/partners` | List partners (from mesaYA_Res) |

## Testing

### Manual Testing Steps

1. Start services:

   ```bash
   # Start PostgreSQL
   docker-compose up -d postgres

   # Start mesaYA_Res
   cd mesaYA_Res && npm run start:dev

   # Start Payment MS
   cd mesaYA_payment_ms && python -m uvicorn mesaYA_payment_ms.app:create_app --factory --reload
   ```

2. Create a payment:

   ```bash
   curl -X POST http://localhost:3000/payment-gateway/reservations/checkout \
     -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     -d '{"reservationId": "<uuid>", "amount": 50.00}'
   ```

3. Verify payment:

   ```bash
   curl -X POST http://localhost:3000/payment-gateway/<payment_id>/verify
   ```

4. Check database:

   ```sql
   SELECT * FROM payments WHERE payment_id = '<payment_id>';
   ```

## Next Steps

1. [ ] Run database migration to add extended columns
2. [ ] Test end-to-end payment flow
3. [ ] Register partners in mesaYA_Res for webhook testing
4. [ ] Configure n8n webhook URL
5. [ ] Add unit tests for new repository and client classes
6. [ ] Consider deleting legacy controller files (currently kept for reference)
