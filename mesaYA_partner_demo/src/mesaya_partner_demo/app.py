"""FastAPI Application for Partner Demo service."""

from pathlib import Path
from typing import Any

from fastapi import FastAPI, Request, Header
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel

from mesaya_partner_demo.config import config
from mesaya_partner_demo.models import event_store
from mesaya_partner_demo.mesa_ya_client import mesa_ya_client
from mesaya_partner_demo.webhook_service import webhook_service

# Templates directory
TEMPLATES_DIR = Path(__file__).parent / "templates"
templates = Jinja2Templates(directory=str(TEMPLATES_DIR))

# Create FastAPI app
app = FastAPI(
    title="MesaYA Partner Demo",
    description="Demo B2B Partner for webhook interoperability with MesaYA",
    version="1.0.0",
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================================
# Request/Response Models
# ============================================================================


class RegisterRequest(BaseModel):
    """Request to register as a partner."""

    mesa_ya_url: str = "http://localhost:3000"
    events: list[str] = ["payment.created", "payment.succeeded", "payment.failed"]


class SendEventRequest(BaseModel):
    """Request to send an event to MesaYA."""

    event_type: str
    data: dict[str, Any]
    target_url: str | None = None


# ============================================================================
# Web UI Endpoints
# ============================================================================


@app.get("/", response_class=HTMLResponse)
async def dashboard(request: Request) -> HTMLResponse:
    """Render the main dashboard."""
    return templates.TemplateResponse(
        "dashboard.html",
        {
            "request": request,
            "partner_registered": config.is_registered,
            "partner_id": config.partner_id or "",
            "registered_at": (
                config.registered_at.strftime("%Y-%m-%d %H:%M")
                if config.registered_at
                else ""
            ),
            "stats": event_store.get_stats(),
            "received_events": event_store.get_all_received(),
            "sent_events": event_store.get_all_sent(),
        },
    )


# ============================================================================
# API Endpoints
# ============================================================================


@app.get("/health")
async def health_check() -> dict[str, Any]:
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": "mesaya-partner-demo",
        "registered": config.is_registered,
        "partner_id": config.partner_id,
    }


@app.post("/api/webhook")
async def receive_webhook(
    request: Request,
    x_webhook_signature: str | None = Header(None, alias="X-Webhook-Signature"),
    x_partner_id: str | None = Header(None, alias="X-Partner-Id"),
) -> dict[str, Any]:
    """
    Receive webhooks from MesaYA.

    This endpoint receives payment events and other notifications.
    Verifies HMAC-SHA256 signature if partner is registered.
    """
    # Get raw body for signature verification
    body = await request.body()
    payload = await request.json()

    print(f"📥 Webhook received: {payload.get('event', 'unknown')}")
    print(f"   Signature: {x_webhook_signature}")
    print(f"   Partner ID: {x_partner_id}")

    # Process the webhook
    event = webhook_service.process_webhook(
        payload=payload,
        signature_header=x_webhook_signature,
        partner_id=x_partner_id,
    )

    return {
        "received": True,
        "event_id": event.id,
        "event_type": event.event_type,
        "status": event.status.value,
        "message": f"Webhook {event.event_type} processed successfully",
    }


@app.get("/api/events")
async def get_events() -> dict[str, Any]:
    """Get all received and sent events."""
    return {
        "received": event_store.get_all_received(),
        "sent": event_store.get_all_sent(),
        "stats": event_store.get_stats(),
    }


@app.post("/api/register")
async def register_as_partner(request: RegisterRequest) -> dict[str, Any]:
    """Register this service as a B2B partner in MesaYA."""
    result = await mesa_ya_client.register_as_partner(
        mesa_ya_url=request.mesa_ya_url,
        events=request.events,
    )
    return result


@app.post("/api/send-event")
async def send_event(request: SendEventRequest) -> dict[str, Any]:
    """Send a webhook event to MesaYA (bidirectional communication)."""
    event = await mesa_ya_client.send_webhook_to_mesaya(
        event_type=request.event_type,
        data=request.data,
        target_url=request.target_url,
    )
    return event.to_dict()


@app.get("/api/health-check")
async def check_mesaya_health() -> dict[str, Any]:
    """Check health of MesaYA services."""
    return await mesa_ya_client.check_mesaya_health()


@app.get("/api/status")
async def get_partner_status() -> dict[str, Any]:
    """Get current partner registration status."""
    return {
        "registered": config.is_registered,
        "partner_id": config.partner_id,
        "secret_set": config.partner_secret is not None,
        "registered_at": (
            config.registered_at.isoformat() if config.registered_at else None
        ),
        "mesa_ya_url": config.mesa_ya_res_url,
        "webhook_url": config.webhook_url,
        "subscribed_events": config.subscribed_events,
    }


@app.delete("/api/events")
async def clear_events() -> dict[str, str]:
    """Clear all stored events."""
    event_store.clear()
    return {"message": "All events cleared"}


# ============================================================================
# Startup/Shutdown Events
# ============================================================================


@app.on_event("startup")
async def startup_event() -> None:
    """Application startup."""
    print("🤝 MesaYA Partner Demo starting...")
    print(f"📡 Webhook endpoint: {config.webhook_url}")
    print(f"🌐 Dashboard: http://localhost:{config.port}")


@app.on_event("shutdown")
async def shutdown_event() -> None:
    """Application shutdown."""
    print("👋 MesaYA Partner Demo shutting down...")
