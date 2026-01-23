"""MesaYA Partner Demo - B2B Webhook Interoperability Demo."""

from mesaya_partner_demo.app import app


def main():
    """Run the partner demo service."""
    import uvicorn

    uvicorn.run(
        "mesaya_partner_demo.app:app",
        host="0.0.0.0",
        port=8088,
        reload=True,
    )


__all__ = ["app", "main"]
