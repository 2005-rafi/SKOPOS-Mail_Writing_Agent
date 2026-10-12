"""Provider usage and quota inspection endpoint."""

from fastapi import APIRouter, Depends, Request
from app.core.config import get_settings
from app.core.rate_limit import rate_limiter
from app.core.security import UserContext
from app.middleware.auth import get_current_user
from app.schemas.provider import (
    ProviderModelsRequest,
    ProviderModelsResponse,
    ProviderUsageRequest,
    ProviderUsageResponse,
)
from app.services.usage_service import UsageService

router = APIRouter(tags=["Provider"])


@router.post(
    "/provider/usage",
    response_model=ProviderUsageResponse,
    summary="Check Provider Usage and Quota",
)
async def get_provider_usage(
    request_data: ProviderUsageRequest,
    request: Request,
    user: UserContext = Depends(get_current_user),
) -> ProviderUsageResponse:
    """Returns provider-reported quota and usage metrics if supported."""
    settings = get_settings()

    client_ip = request.client.host if request.client else "127.0.0.1"
    rate_limit_key = f"{user.uid}:{client_ip}:usage"
    rate_limiter.check_and_record(
        key=rate_limit_key,
        limit=settings.RATE_LIMIT_USAGE_PER_MINUTE,
    )

    return await UsageService.get_usage(request=request_data, user=user)


@router.post(
    "/provider/models",
    response_model=ProviderModelsResponse,
    summary="Get Available Models for Provider (Dynamic via API Key)",
)
async def get_provider_models(
    request_data: ProviderModelsRequest,
    user: UserContext = Depends(get_current_user),
) -> ProviderModelsResponse:
    """Returns dynamically accessible models for the provider, queried live using apiKey if provided."""
    from app.core.constants import DEFAULT_MODELS
    from app.providers.registry import provider_registry
    from app.schemas.provider import ModelOption

    provider = provider_registry.get(request_data.provider)
    models_raw = await provider.list_models(api_key=request_data.apiKey)
    default_model = DEFAULT_MODELS.get(request_data.provider, models_raw[0]["id"] if models_raw else "")

    return ProviderModelsResponse(
        success=True,
        provider=request_data.provider,
        models=[ModelOption(**m) for m in models_raw],
        defaultModel=default_model,
        isLive=bool(request_data.apiKey and request_data.apiKey.strip()),
    )

