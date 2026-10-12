"""Public system configuration and capabilities endpoint."""

from fastapi import APIRouter
from app.core.config import get_settings
from app.core.constants import (
    ABSOLUTE_MAX_WORDS,
    AVAILABLE_MODELS,
    ContentType,
    DEFAULT_MAX_WORDS,
    ProviderType,
    SUPPORTED_LANGUAGES,
    ToneType,
)
from app.schemas.provider import ConfigResponse

router = APIRouter(tags=["Configuration"])


@router.get("/config", response_model=ConfigResponse, summary="Public Capabilities Configuration")
async def get_public_config() -> ConfigResponse:
    """Returns supported providers, models, content types, and limits."""
    settings = get_settings()
    return ConfigResponse(
        success=True,
        appName=settings.APP_NAME,
        version=settings.API_VERSION,
        supportedProviders=[p.value for p in ProviderType],
        supportedContentTypes=[c.value for c in ContentType],
        supportedTones=[t.value for t in ToneType],
        supportedLanguages=SUPPORTED_LANGUAGES,
        defaultMaxWords=DEFAULT_MAX_WORDS,
        absoluteMaxWords=ABSOLUTE_MAX_WORDS,
        modelsByProvider={p.value: models for p, models in AVAILABLE_MODELS.items()},
    )
