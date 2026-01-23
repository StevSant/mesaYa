"""Webhook service for HMAC verification and processing."""

import hashlib
import hmac
import time
from datetime import datetime
from typing import Any
from uuid import uuid4

from mesaya_partner_demo.config import config
from mesaya_partner_demo.models import EventStatus, WebhookEvent, event_store


class WebhookService:
    """Service for handling webhook verification and processing."""

    # Signature validity window in seconds (5 minutes)
    SIGNATURE_VALIDITY_SECONDS = 5 * 60

    @staticmethod
    def generate_signature(payload: str, secret: str) -> tuple[str, int]:
        """
        Generate HMAC-SHA256 signature for a payload.

        Returns:
            Tuple of (signature_header, timestamp)
        """
        timestamp = int(time.time())
        signed_payload = f"{timestamp}.{payload}"

        signature = hmac.new(
            secret.encode(),
            signed_payload.encode(),
            hashlib.sha256,
        ).hexdigest()

        return f"t={timestamp},v1={signature}", timestamp

    @staticmethod
    def verify_signature(
        signature_header: str | None,
        payload: str,
        secret: str,
    ) -> tuple[bool, str | None]:
        """
        Verify HMAC-SHA256 signature from webhook.

        Args:
            signature_header: The X-Webhook-Signature header value
            payload: The raw request body
            secret: The partner's webhook secret

        Returns:
            Tuple of (is_valid, error_message)
        """
        if not signature_header:
            return False, "Missing signature header"

        if not secret:
            # If we don't have a secret yet, we can't verify
            return True, None  # Accept but note it's unverified

        try:
            # Parse signature header: "t=timestamp,v1=signature"
            parts = signature_header.split(",")
            timestamp_part = next((p for p in parts if p.startswith("t=")), None)
            signature_part = next((p for p in parts if p.startswith("v1=")), None)

            if not timestamp_part or not signature_part:
                return False, "Invalid signature format"

            timestamp = int(timestamp_part[2:])
            received_signature = signature_part[3:]

            # Check timestamp is within validity window
            now = int(time.time())
            if abs(now - timestamp) > WebhookService.SIGNATURE_VALIDITY_SECONDS:
                return False, f"Signature expired (age: {abs(now - timestamp)}s)"

            # Compute expected signature
            signed_payload = f"{timestamp}.{payload}"
            expected_signature = hmac.new(
                secret.encode(),
                signed_payload.encode(),
                hashlib.sha256,
            ).hexdigest()

            # Constant-time comparison
            if hmac.compare_digest(expected_signature, received_signature):
                return True, None
            else:
                return False, "Signature mismatch"

        except (ValueError, IndexError) as e:
            return False, f"Error parsing signature: {e}"

    @staticmethod
    def process_webhook(
        payload: dict[str, Any],
        signature_header: str | None,
        partner_id: str | None = None,
    ) -> WebhookEvent:
        """
        Process an incoming webhook event.

        Args:
            payload: The parsed JSON payload
            signature_header: The X-Webhook-Signature header
            partner_id: The X-Partner-Id header

        Returns:
            The created WebhookEvent
        """
        event_id = str(uuid4())
        event_type = payload.get("event", "unknown")
        timestamp = datetime.utcnow()

        # Try to parse timestamp from payload
        if "timestamp" in payload:
            try:
                timestamp = datetime.fromisoformat(
                    payload["timestamp"].replace("Z", "+00:00")
                )
            except (ValueError, AttributeError):
                pass

        # Verify signature
        payload_str = str(payload)  # For verification purposes
        is_valid, error_msg = WebhookService.verify_signature(
            signature_header,
            payload_str,
            config.partner_secret or "",
        )

        status = EventStatus.VERIFIED if is_valid else EventStatus.INVALID_SIGNATURE
        if not config.partner_secret:
            # If not registered yet, just mark as received
            status = EventStatus.RECEIVED

        event = WebhookEvent(
            id=event_id,
            event_type=event_type,
            timestamp=timestamp,
            payload=payload,
            status=status,
            signature=signature_header,
            partner_id=partner_id,
            error_message=error_msg if not is_valid else None,
        )

        # Store the event
        event_store.add_received(event)

        return event


# Singleton instance
webhook_service = WebhookService()
