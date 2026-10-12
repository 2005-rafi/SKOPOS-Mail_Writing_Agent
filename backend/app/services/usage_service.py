"""Service handling provider quota and usage queries."""

from app.core.constants import ProviderType
from app.core.security import UserContext
from app.providers.registry import provider_registry
from app.schemas.provider import ProviderUsageRequest, ProviderUsageResponse


class UsageService:
    """Queries provider-reported usage or quota metrics."""

    @classmethod
    async def get_usage(
        cls,
        request: ProviderUsageRequest,
        user: UserContext,
    ) -> ProviderUsageResponse:
        provider = provider_registry.get(request.provider)
        quota_data = await provider.get_usage(request.apiKey)

        if quota_data is not None:
            return ProviderUsageResponse(
                success=True,
                provider=request.provider,
                supported=True,
                reportedQuota=quota_data,
                message=f"Usage information reported by {request.provider.value}.",
            )

        # Provider does not expose real-time balance queries via API keys
        return ProviderUsageResponse(
            success=True,
            provider=request.provider,
            supported=False,
            reportedQuota=None,
            message=f"Provider '{request.provider.value}' does not expose real-time quota endpoints for personal API keys.",
        )
