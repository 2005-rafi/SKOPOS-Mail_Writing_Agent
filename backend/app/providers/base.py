"""Abstract Base Class for LLM Providers.

All providers must implement this interface. Business logic must never directly couple to provider SDKs.
"""

from abc import ABC, abstractmethod
from typing import Any
from app.core.constants import ProviderType


class LLMProvider(ABC):
    """Abstract interface defining required LLM capabilities."""

    @property
    @abstractmethod
    def provider_type(self) -> ProviderType:
        """Return the ProviderType enum identifier."""
        pass

    @abstractmethod
    async def generate(
        self,
        system_prompt: str,
        user_prompt: str,
        model: str,
        api_key: str,
        temperature: float = 0.7,
        timeout_seconds: int = 30,
    ) -> str:
        """Execute text generation and return raw text/JSON from model.

        Must raise normalized domain exceptions (ProviderAuthException, ProviderTimeoutException, etc.)
        and never leak raw SDK exceptions.
        """
        pass

    @abstractmethod
    async def get_usage(self, api_key: str) -> dict[str, Any] | None:
        """Fetch provider-reported usage or quota metrics if supported.

        Returns None if the provider does not expose a reliable usage endpoint.
        """
        pass

    @abstractmethod
    async def list_models(self, api_key: str | None = None) -> list[dict[str, Any]]:
        """Fetch available models for this provider, optionally queried live from the provider API using api_key."""
        pass
