"""HTTP client for MesaYA services."""

import json
from datetime import datetime
from typing import Any
from uuid import uuid4

import httpx

from mesaya_partner_demo.config import config
from mesaya_partner_demo.models import SentEvent, event_store
from mesaya_partner_demo.webhook_service import WebhookService


class MesaYAClient:
    """Client for interacting with MesaYA services."""

    def __init__(self):
        self.timeout = 10.0

    async def register_as_partner(
        self,
        mesa_ya_url: str | None = None,
        events: list[str] | None = None,
    ) -> dict[str, Any]:
        """
        Register this service as a B2B partner in MesaYA.

        Args:
            mesa_ya_url: URL of mesaYA_Res service
            events: List of events to subscribe to

        Returns:
            Registration result with partner ID and secret
        """
        base_url = mesa_ya_url or config.mesa_ya_res_url
        url = f"{base_url}/api/v1/partners/register"

        registration_data = {
            "name": f"partner-demo-{uuid4().hex[:8]}",
            "webhookUrl": config.webhook_url,
            "events": events or config.subscribed_events,
            "description": "Demo B2B Partner for webhook interoperability testing",
            "contactEmail": "demo@partner.local",
        }

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(url, json=registration_data)

                if response.status_code == 201:
                    data = response.json()
                    # Update config with registration info
                    config.partner_id = data.get("id")
                    config.partner_secret = data.get("secret")
                    config.is_registered = True
                    config.registered_at = datetime.utcnow()
                    config.mesa_ya_res_url = base_url

                    return {
                        "success": True,
                        "partner_id": config.partner_id,
                        "secret": config.partner_secret,
                        "message": "Successfully registered as partner",
                        "subscribed_events": data.get("subscribedEvents", []),
                    }
                elif response.status_code == 409:
                    return {
                        "success": False,
                        "error": "Partner with similar name already exists",
                        "status_code": 409,
                    }
                else:
                    return {
                        "success": False,
                        "error": response.text,
                        "status_code": response.status_code,
                    }

        except httpx.TimeoutException:
            return {"success": False, "error": "Connection timeout"}
        except httpx.RequestError as e:
            return {"success": False, "error": f"Connection error: {e}"}

    async def send_webhook_to_mesaya(
        self,
        event_type: str,
        data: dict[str, Any],
        target_url: str | None = None,
    ) -> SentEvent:
        """
        Send a webhook event to MesaYA.

        This demonstrates the bidirectional communication capability.

        Args:
            event_type: Type of event to send
            data: Event payload data
            target_url: Target webhook URL (defaults to mesaYA_Res webhook endpoint)

        Returns:
            SentEvent record
        """
        # Build URL with partner ID if registered
        partner_id = config.partner_id or "unregistered"
        url = (
            target_url
            or f"{config.mesa_ya_res_url}/api/v1/webhooks/partner/{partner_id}"
        )
        event_id = str(uuid4())
        timestamp = datetime.utcnow()
        timestamp_iso = timestamp.isoformat() + "Z"

        # Build payload (format expected by mesaYA_Res)
        payload = {
            "event": event_type,
            "timestamp": timestamp_iso,
            "data": data,
        }

        payload_json = json.dumps(payload)

        # Generate HMAC signature if we have a secret
        # Format: signature = HMAC-SHA256(secret, timestamp + "." + body)
        signature = None
        if config.partner_secret:
            import hmac
            import hashlib

            signature_data = f"{timestamp_iso}.{payload_json}"
            signature = hmac.new(
                config.partner_secret.encode(),
                signature_data.encode(),
                hashlib.sha256,
            ).hexdigest()

        headers = {
            "Content-Type": "application/json",
            "X-Webhook-Timestamp": timestamp_iso,
        }
        if signature:
            headers["X-Webhook-Signature"] = signature

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(
                    url,
                    content=payload_json,
                    headers=headers,
                )

                success = response.status_code < 300
                sent_event = SentEvent(
                    id=event_id,
                    event_type=event_type,
                    timestamp=timestamp,
                    payload=payload,
                    target_url=url,
                    success=success,
                    response_code=response.status_code,
                    error_message=None if success else response.text[:200],
                )

        except httpx.TimeoutException:
            sent_event = SentEvent(
                id=event_id,
                event_type=event_type,
                timestamp=timestamp,
                payload=payload,
                target_url=url,
                success=False,
                response_code=None,
                error_message="Connection timeout",
            )
        except httpx.RequestError as e:
            sent_event = SentEvent(
                id=event_id,
                event_type=event_type,
                timestamp=timestamp,
                payload=payload,
                target_url=url,
                success=False,
                response_code=None,
                error_message=f"Connection error: {e}",
            )

        # Store the sent event
        event_store.add_sent(sent_event)

        return sent_event

    async def check_mesaya_health(self) -> dict[str, Any]:
        """Check if MesaYA services are reachable."""
        results = {}

        # Check mesaYA_Res
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                response = await client.get(f"{config.mesa_ya_res_url}/health")
                results["mesaYA_Res"] = {
                    "status": "online" if response.status_code == 200 else "error",
                    "url": config.mesa_ya_res_url,
                }
        except Exception:
            results["mesaYA_Res"] = {"status": "offline", "url": config.mesa_ya_res_url}

        # Check mesaYA_payment_ms
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                response = await client.get(f"{config.mesa_ya_payment_url}/health")
                results["mesaYA_payment"] = {
                    "status": "online" if response.status_code == 200 else "error",
                    "url": config.mesa_ya_payment_url,
                }
        except Exception:
            results["mesaYA_payment"] = {
                "status": "offline",
                "url": config.mesa_ya_payment_url,
            }

        return results


# Singleton instance
mesa_ya_client = MesaYAClient()
