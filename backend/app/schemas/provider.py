"""Request and response models for provider usage and system configuration."""

from typing import Any
from pydantic import BaseModel, ConfigDict, Field
from app.core.constants import ProviderType


class ProviderUsageRequest(BaseModel):
    """Payload to query provider usage / quota."""

    model_config = ConfigDict(extra="ignore")

    provider: ProviderType
    apiKey: str = Field(..., min_length=1)


class ProviderUsageResponse(BaseModel):
    """Normalized response for provider usage information."""

    success: bool = True
    provider: ProviderType
    supported: bool
    reportedQuota: dict[str, Any] | None = None
    message: str


class ConfigResponse(BaseModel):
    """Public system configuration and capabilities."""

    success: bool = True
    appName: str
    version: str
    supportedProviders: list[str]
    supportedContentTypes: list[str]
    supportedTones: list[str]
    supportedLanguages: list[str]
    defaultMaxWords: int
    absoluteMaxWords: int
    modelsByProvider: dict[str, list[str]]


class ProviderModelsRequest(BaseModel):
    """Payload to dynamically retrieve available models for a provider, optionally via user's API key."""

    model_config = ConfigDict(extra="ignore")

    provider: ProviderType
    apiKey: str | None = Field(default=None, description="Optional user API key to query live permitted models")


class ModelOption(BaseModel):
    """Structured model identifier, presentation label, and free-tier qualification."""

    id: str
    label: str
    isFreeTierRecommended: bool = False


class ProviderModelsResponse(BaseModel):
    """Response containing dynamically available models for a provider."""

    success: bool = True
    provider: ProviderType
    models: list[ModelOption]
    defaultModel: str
    isLive: bool = False

