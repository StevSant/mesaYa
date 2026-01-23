"""Configuration for Partner Demo service."""

from dataclasses import dataclass, field
from datetime import datetime


@dataclass
class PartnerConfig:
    """Partner configuration and state."""

    # Service config
    name: str = "MesaYA Partner Demo"
    host: str = "0.0.0.0"
    port: int = 8088
    webhook_path: str = "/api/webhook"

    # MesaYA connection
    mesa_ya_res_url: str = "http://localhost:3000"
    mesa_ya_payment_url: str = "http://localhost:8000"

    # Partner registration state
    partner_id: str | None = None
    partner_secret: str | None = None
    registered_at: datetime | None = None
    is_registered: bool = False

    # Subscribed events
    subscribed_events: list[str] = field(
        default_factory=lambda: [
            "payment.created",
            "payment.succeeded",
            "payment.failed",
            "payment.refunded",
        ]
    )

    @property
    def webhook_url(self) -> str:
        """Get the full webhook URL for this partner."""
        return f"http://localhost:{self.port}{self.webhook_path}"


# Global config instance
config = PartnerConfig()
