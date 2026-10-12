"""Mock LLM Provider for deterministic automated testing and offline verification."""

import json
from typing import Any
from app.core.constants import ProviderType
from app.providers.base import LLMProvider


class MockLLMProvider(LLMProvider):
    """Deterministic mock provider that simulates generation, validation failures, and repairs."""

    def __init__(self) -> None:
        self.call_count: int = 0
        self.should_simulate_repair: bool = False
        self.should_fail: bool = False
        self.failure_message: str = "Simulated mock provider failure"

    @property
    def provider_type(self) -> ProviderType:
        return ProviderType.MOCK

    async def generate(
        self,
        system_prompt: str,
        user_prompt: str,
        model: str,
        api_key: str,
        temperature: float = 0.7,
        timeout_seconds: int = 30,
    ) -> str:
        self.call_count += 1

        if self.should_fail:
            from app.core.errors import ProviderUnavailableException
            raise ProviderUnavailableException(self.failure_message)

        # If simulating repair loop: first call produces invalid output (e.g. missing body or closing),
        # second call (which has 'REPAIR REQUEST' in user_prompt) produces valid output
        if self.should_simulate_repair and "REPAIR REQUEST" not in user_prompt:
            return json.dumps({
                "subject": "Delayed Order Notification",
                "salutation": "Dear Supplier,",
                "body": "",  # Empty body intentionally triggers validation failure
                "closing": "Regards,",
            })

        # Standard deterministic response
        return json.dumps({
            "subject": "Urgent Follow-Up Regarding Delayed Supply Delivery",
            "salutation": "Dear Supplier,",
            "body": "I am writing to formally address the outstanding delivery of raw materials ordered one month ago. Despite repeated assurances, the shipment has not arrived. Please provide an immediate status update and expedite the dispatch of these materials by the end of this week.",
            "closing": "Sincerely,\nOperations Team",
        })

    async def get_usage(self, api_key: str) -> dict[str, Any] | None:
        return {
            "tier": "mock_unlimited",
            "mockCallsExecuted": self.call_count,
            "quotaRemaining": "unlimited",
        }

    async def list_models(self, api_key: str | None = None) -> list[dict[str, Any]]:
        return [
            {
                "id": "mock-model-v1",
                "label": "mock-model-v1 (Offline Deterministic)",
                "isFreeTierRecommended": True,
            }
        ]
