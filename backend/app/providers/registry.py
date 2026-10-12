"""Provider Registry for managing and resolving LLM providers dynamically."""

from typing import Dict
from app.core.constants import ProviderType
from app.core.errors import ProviderNotSupportedException
from app.providers.base import LLMProvider
from app.providers.gemini import GeminiProvider
from app.providers.groq import GroqProvider
from app.providers.mock import MockLLMProvider


class ProviderRegistry:
    """Registry maintaining active LLMProvider instances."""

    def __init__(self) -> None:
        self._providers: Dict[ProviderType, LLMProvider] = {}
        # Register default implementations
        self.register(GroqProvider())
        self.register(GeminiProvider())
        self.register(MockLLMProvider())

    def register(self, provider: LLMProvider) -> None:
        """Register or override a provider implementation."""
        self._providers[provider.provider_type] = provider

    def get(self, provider_type: ProviderType | str) -> LLMProvider:
        """Retrieve provider instance or raise ProviderNotSupportedException."""
        try:
            ptype = ProviderType(provider_type)
        except ValueError:
            raise ProviderNotSupportedException(str(provider_type))

        provider = self._providers.get(ptype)
        if not provider:
            raise ProviderNotSupportedException(ptype.value)
        return provider


# Global default provider registry singleton
provider_registry = ProviderRegistry()
