"""Unit tests for resilient LLM provider implementations (Groq & Gemini)."""

from unittest.mock import AsyncMock, MagicMock, patch
import groq
import httpx
import pytest
from app.core.constants import ProviderType
from app.core.errors import (
    ProviderAuthException,
    ProviderUnavailableException,
)
from app.providers.gemini import GeminiProvider
from app.providers.groq import GroqProvider


@pytest.mark.asyncio
async def test_groq_provider_model_not_found_fallback_success():
    """Verify that if Groq returns 404 model_not_found on the requested model,

    it automatically falls back to an alternative model and succeeds.
    """
    provider = GroqProvider()

    # Create mock client
    mock_client = AsyncMock()

    # First call with requested model fails with 404 model_not_found
    err_404 = groq.NotFoundError(
        message="The model `llama-3.3-70b-versatile` does not exist or you do not have access to it.",
        response=MagicMock(status_code=404),
        body={"error": {"code": "model_not_found"}},
    )

    # Second call with fallback model succeeds
    success_completion = MagicMock()
    success_completion.choices = [
        MagicMock(message=MagicMock(content='{"subject": "Notice", "body": "Materials ready."}'))
    ]

    mock_client.chat.completions.create = AsyncMock(
        side_effect=[err_404, success_completion]
    )

    with patch("groq.AsyncGroq", return_value=mock_client):
        result = await provider.generate(
            system_prompt="system",
            user_prompt="user",
            model="llama-3.3-70b-versatile",
            api_key="gsk_test123",
        )

    assert result == '{"subject": "Notice", "body": "Materials ready."}'
    # Verify create was called twice (initial + fallback)
    assert mock_client.chat.completions.create.call_count == 2
    # Verify first call used requested model, second call used fallback model
    first_call_model = mock_client.chat.completions.create.call_args_list[0].kwargs["model"]
    second_call_model = mock_client.chat.completions.create.call_args_list[1].kwargs["model"]
    assert first_call_model == "llama-3.3-70b-versatile"
    assert second_call_model == "llama-3.1-8b-instant"


@pytest.mark.asyncio
async def test_groq_provider_all_models_unavailable_raises_clear_error():
    """Verify that if all models fail with model_not_found, a helpful message is returned."""
    provider = GroqProvider()
    mock_client = AsyncMock()

    err_404 = groq.NotFoundError(
        message="Model not found",
        response=MagicMock(status_code=404),
        body={"error": {"code": "model_not_found"}},
    )
    mock_client.chat.completions.create = AsyncMock(side_effect=err_404)

    with patch("groq.AsyncGroq", return_value=mock_client):
        with pytest.raises(ProviderUnavailableException) as exc_info:
            await provider.generate(
                system_prompt="system",
                user_prompt="user",
                model="invalid-model-name",
                api_key="gsk_test123",
            )

    assert "was not found or accessible" in str(exc_info.value.message)


@pytest.mark.asyncio
async def test_groq_provider_auth_error_mapping():
    """Verify that 401 AuthenticationError is mapped to ProviderAuthException."""
    provider = GroqProvider()
    mock_client = AsyncMock()

    err_auth = groq.AuthenticationError(
        message="Invalid API Key",
        response=MagicMock(status_code=401),
        body={},
    )
    mock_client.chat.completions.create = AsyncMock(side_effect=err_auth)

    with patch("groq.AsyncGroq", return_value=mock_client):
        with pytest.raises(ProviderAuthException):
            await provider.generate(
                system_prompt="system",
                user_prompt="user",
                model="llama-3.1-8b-instant",
                api_key="gsk_invalid",
            )


@pytest.mark.asyncio
async def test_gemini_provider_model_not_found_fallback():
    """Verify Gemini fallback on 404 response."""
    provider = GeminiProvider()

    resp_404 = MagicMock()
    resp_404.status_code = 404
    resp_404.json.return_value = {"error": {"message": "Model not found"}}

    resp_200 = MagicMock()
    resp_200.status_code = 200
    resp_200.json.return_value = {
        "candidates": [{"content": {"parts": [{"text": '{"body": "Gemini fallback success"}'}]}}]
    }

    mock_http_client = AsyncMock()
    mock_http_client.post = AsyncMock(side_effect=[resp_404, resp_200])
    mock_http_client.__aenter__ = AsyncMock(return_value=mock_http_client)
    mock_http_client.__aexit__ = AsyncMock(return_value=None)

    with patch("httpx.AsyncClient", return_value=mock_http_client):
        result = await provider.generate(
            system_prompt="system",
            user_prompt="user",
            model="gemini-2.5-flash",
            api_key="AIza_test",
        )

    assert "Gemini fallback success" in result
