"""SKOPOS FastAPI Application Entrypoint.

Controlled AI Writing Engine with Agentic Validation and Repair.
"""

from contextlib import asynccontextmanager
from typing import AsyncGenerator
from fastapi import FastAPI, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import RedirectResponse
from app.api.v1.router import api_v1_router
from app.core.config import get_settings
from app.core.constants import API_PREFIX
from app.core.logging import logger
from app.middleware.error_handler import register_error_handlers
from app.middleware.request_id import RequestIdMiddleware


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """Lifespan context manager for startup and shutdown logging."""
    settings = get_settings()
    logger.info(f"Starting {settings.APP_NAME} Backend ({settings.ENVIRONMENT})")
    yield
    logger.info(f"Stopping {settings.APP_NAME} Backend")


def create_app() -> FastAPI:
    """Create and configure the FastAPI application instance."""
    settings = get_settings()

    app = FastAPI(
        title=settings.APP_NAME,
        description="Controlled AI Writing Engine with Agentic Validation and Repair.",
        version="1.0.0",
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
        lifespan=lifespan,
    )

    # 1. Attach Request ID Middleware
    app.add_middleware(RequestIdMiddleware)

    # 2. Attach CORS Middleware
    origins = settings.CORS_ORIGINS
    if "*" in origins:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=False,
            allow_methods=["*"],
            allow_headers=["*"],
            expose_headers=["X-Request-ID"],
        )
    else:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=origins,
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
            expose_headers=["X-Request-ID"],
        )

    # 3. Attach GZip Compression Middleware (reduces payload size for mobile clients)
    app.add_middleware(GZipMiddleware, minimum_size=500)

    # 4. Register Standardized Error Handlers
    register_error_handlers(app)

    # 5. Attach API v1 Router
    app.include_router(api_v1_router, prefix=API_PREFIX)

    @app.api_route("/health", methods=["GET", "HEAD"], include_in_schema=False)
    async def root_health_probe(response: Response) -> dict[str, str | bool]:
        """Root health probe for platform orchestrators (Render, Kubernetes, Docker)."""
        response.headers["Cache-Control"] = "public, max-age=60, stale-while-revalidate=30"
        response.headers["X-Server-Status"] = "active"
        return {
            "success": True,
            "status": "healthy",
            "service": settings.APP_NAME,
            "version": settings.API_VERSION,
            "environment": settings.ENVIRONMENT,
        }

    @app.get("/", include_in_schema=False)
    async def root_redirect() -> RedirectResponse:
        """Redirect root requests to interactive API documentation."""
        return RedirectResponse(url="/docs")

    return app



app = create_app()

if __name__ == "__main__":
    import uvicorn
    settings = get_settings()
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.ENVIRONMENT == "development",
    )
