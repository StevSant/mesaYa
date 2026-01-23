"""Data models for Partner Demo service."""

from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import Any


class EventStatus(str, Enum):
    """Status of a received webhook event."""

    RECEIVED = "received"
    VERIFIED = "verified"
    INVALID_SIGNATURE = "invalid_signature"
    PROCESSED = "processed"
    ERROR = "error"


@dataclass
class WebhookEvent:
    """Represents a received webhook event."""

    id: str
    event_type: str
    timestamp: datetime
    payload: dict[str, Any]
    status: EventStatus
    signature: str | None = None
    partner_id: str | None = None
    error_message: str | None = None

    def to_dict(self) -> dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return {
            "id": self.id,
            "event_type": self.event_type,
            "timestamp": self.timestamp.isoformat(),
            "payload": self.payload,
            "status": self.status.value,
            "signature": self.signature,
            "partner_id": self.partner_id,
            "error_message": self.error_message,
        }


@dataclass
class SentEvent:
    """Represents an event sent to MesaYA."""

    id: str
    event_type: str
    timestamp: datetime
    payload: dict[str, Any]
    target_url: str
    success: bool
    response_code: int | None = None
    error_message: str | None = None

    def to_dict(self) -> dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return {
            "id": self.id,
            "event_type": self.event_type,
            "timestamp": self.timestamp.isoformat(),
            "payload": self.payload,
            "target_url": self.target_url,
            "success": self.success,
            "response_code": self.response_code,
            "error_message": self.error_message,
        }


@dataclass
class EventStore:
    """In-memory store for events (no database)."""

    received_events: list[WebhookEvent] = field(default_factory=list)
    sent_events: list[SentEvent] = field(default_factory=list)
    max_events: int = 100  # Keep last 100 events

    def add_received(self, event: WebhookEvent) -> None:
        """Add a received event to the store."""
        self.received_events.insert(0, event)
        # Trim to max
        if len(self.received_events) > self.max_events:
            self.received_events = self.received_events[: self.max_events]

    def add_sent(self, event: SentEvent) -> None:
        """Add a sent event to the store."""
        self.sent_events.insert(0, event)
        # Trim to max
        if len(self.sent_events) > self.max_events:
            self.sent_events = self.sent_events[: self.max_events]

    def get_all_received(self) -> list[dict[str, Any]]:
        """Get all received events as dictionaries."""
        return [e.to_dict() for e in self.received_events]

    def get_all_sent(self) -> list[dict[str, Any]]:
        """Get all sent events as dictionaries."""
        return [e.to_dict() for e in self.sent_events]

    def clear(self) -> None:
        """Clear all events."""
        self.received_events.clear()
        self.sent_events.clear()

    def get_stats(self) -> dict[str, Any]:
        """Get event statistics."""
        received_by_type: dict[str, int] = {}
        for event in self.received_events:
            received_by_type[event.event_type] = (
                received_by_type.get(event.event_type, 0) + 1
            )

        verified = sum(
            1 for e in self.received_events if e.status == EventStatus.VERIFIED
        )
        invalid = sum(
            1 for e in self.received_events if e.status == EventStatus.INVALID_SIGNATURE
        )

        return {
            "total_received": len(self.received_events),
            "total_sent": len(self.sent_events),
            "received_verified": verified,
            "received_invalid": invalid,
            "sent_success": sum(1 for e in self.sent_events if e.success),
            "sent_failed": sum(1 for e in self.sent_events if not e.success),
            "events_by_type": received_by_type,
        }


# Global event store
event_store = EventStore()
