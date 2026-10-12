"""Service health and deployment verification endpoint optimized for Render.com."""

from fastapi import APIRouter, Response
from app.core.config import get_settings

router = APIRouter(tags=["System"])


@router.api_route("/health", methods=["GET", "HEAD"], summary="Service Health Check")
async def health_check(response: Response) -> dict[str, str | bool]:
    """Returns application health and environment details for uptime probes.
    
    Includes Cache-Control headers so edge proxies and mobile clients
    can absorb repeated polling without waking or bloating the server.
    """
    response.headers["Cache-Control"] = "public, max-age=60, stale-while-revalidate=30"
    response.headers["X-Server-Status"] = "active"
    
    settings = get_settings()
    return {
        "success": True,
        "status": "healthy",
        "service": settings.APP_NAME,
        "version": settings.API_VERSION,
        "environment": settings.ENVIRONMENT,
    }

