"""Google Gemini LLM provider implementation using asynchronous REST client."""

from typing import Any
import httpx
from app.core.constants import DEFAULT_MODELS, ProviderType
from app.core.errors import (
    ProviderAuthException,
    ProviderRateLimitException,
    ProviderTimeoutException,
    ProviderUnavailableException,
)
from app.core.logging import logger
from app.providers.base import LLMProvider


class GeminiProvider(LLMProvider):
    """Executes completions via the Google Gemini API."""

    BASE_URL = "https://generativelanguage.googleapis.com/v1beta"

    @property
    def provider_type(self) -> ProviderType:
        return ProviderType.GEMINI

    async def generate(
        self,
        system_prompt: str,
        user_prompt: str,
        model: str,
        api_key: str,
        temperature: float = 0.7,
        timeout_seconds: int = 30,
    ) -> str:
        resolved_model = model or DEFAULT_MODELS[ProviderType.GEMINI]
        endpoint = f"{self.BASE_URL}/models/{resolved_model}:generateContent"

        payload = {
            "system_instruction": {
                "parts": [{"text": system_prompt}]
            },
            "contents": [
                {
                    "role": "user",
                    "parts": [{"text": user_prompt}]
                }
            ],
            "generationConfig": {
                "temperature": temperature,
                "response_mime_type": "application/json",
            },
        }

        try:
            async with httpx.AsyncClient(timeout=timeout_seconds) as client:
                response = await client.post(
                    endpoint,
                    params={"key": api_key},
                    json=payload,
                    headers={"Content-Type": "application/json"},
                )

                if response.status_code == 200:
                    data = response.json()
                    candidates = data.get("candidates", [])
                    if not candidates:
                        raise ProviderUnavailableException("Gemini returned no candidates.")
                    parts = candidates[0].get("content", {}).get("parts", [])
                    if not parts or "text" not in parts[0]:
                        raise ProviderUnavailableException("Gemini returned empty content.")
                    return parts[0]["text"]

                if response.status_code in (400, 401, 403):
                    error_data = response.json().get("error", {})
                    msg = error_data.get("message", "API key rejected by Google Gemini.")
                    logger.warning(f"Gemini authentication rejected (status {response.status_code}): {msg}")
                    raise ProviderAuthException(f"Gemini API key rejected: {msg}")

                if response.status_code == 429:
                    logger.warning("Gemini quota/rate limit exceeded.")
                    raise ProviderRateLimitException("Google Gemini quota or rate limit exceeded.")

                if response.status_code >= 500:
                    logger.warning(f"Gemini server error (status {response.status_code}): {response.text}")
                    raise ProviderUnavailableException("Google Gemini service is temporarily unavailable.")

                if response.status_code == 404:
                    error_data = response.json().get("error", {})
                    msg = error_data.get("message", f"Model '{resolved_model}' not found on Google Gemini.")
                    logger.warning(f"Gemini model not found (status 404): {msg}")
                    if resolved_model != "gemini-1.5-flash":
                        logger.info("Attempting fallback to 'gemini-1.5-flash'...")
                        fallback_endpoint = f"{self.BASE_URL}/models/gemini-1.5-flash:generateContent"
                        fb_res = await client.post(
                            fallback_endpoint,
                            params={"key": api_key},
                            json=payload,
                            headers={"Content-Type": "application/json"},
                        )
                        if fb_res.status_code == 200:
                            fb_data = fb_res.json()
                            candidates = fb_data.get("candidates", [])
                            if candidates and candidates[0].get("content", {}).get("parts"):
                                return candidates[0]["content"]["parts"][0].get("text", "")
                    raise ProviderUnavailableException(
                        f"Google Gemini model '{resolved_model}' was not found. Please select 'gemini-1.5-flash' or another supported model."
                    )

                raise ProviderUnavailableException(f"Gemini returned unexpected status {response.status_code}.")

        except httpx.TimeoutException as exc:
            logger.warning("Gemini request timed out.")
            raise ProviderTimeoutException("Google Gemini API request timed out.") from exc
        except (ProviderAuthException, ProviderRateLimitException, ProviderUnavailableException):
            raise
        except Exception as exc:
            logger.error(f"Unexpected Gemini execution error: {exc}")
            raise ProviderUnavailableException("An error occurred while connecting to Google Gemini.") from exc

    async def get_usage(self, api_key: str) -> dict[str, Any] | None:
        """Query Gemini models endpoint to verify API key validity."""
        endpoint = f"{self.BASE_URL}/models"
        try:
            async with httpx.AsyncClient(timeout=10) as client:
                res = await client.get(endpoint, params={"key": api_key})
                if res.status_code == 200:
                    models = [m.get("name") for m in res.json().get("models", [])]
                    return {
                        "status": "active",
                        "accessibleModelsCount": len(models),
                        "quotaDetails": "Available via Google Cloud Console",
                    }
                return None
        except Exception:
            return None

    async def list_models(self, api_key: str | None = None) -> list[dict[str, Any]]:
        """Query Google Gemini models API live if API key is provided, or return curated free-tier models."""
        free_tier_set = {
            "gemini-1.5-flash",
            "gemini-2.0-flash",
            "gemini-1.5-flash-8b",
        }

        if api_key and api_key.strip():
            try:
                endpoint = f"{self.BASE_URL}/models"
                async with httpx.AsyncClient(timeout=10) as client:
                    res = await client.get(endpoint, params={"key": api_key.strip()})
                    if res.status_code == 200:
                        raw_models = res.json().get("models", [])
                        content_models: list[str] = []
                        for m in raw_models:
                            methods = m.get("supportedGenerationMethods", [])
                            if "generateContent" in methods:
                                name = m.get("name", "").replace("models/", "")
                                if name and not any(ex in name.lower() for ex in ("embedding", "aqa", "imagen", "vision", "bison", "chat")):
                                    content_models.append(name)

                        # Sort: free-tier Flash models first
                        def sort_key(m_id: str) -> tuple[int, str]:
                            is_free = 0 if any(ft in m_id.lower() for ft in ("1.5-flash", "2.0-flash", "flash")) else 1
                            return (is_free, m_id)

                        content_models.sort(key=sort_key)

                        result: list[dict[str, Any]] = []
                        for mid in content_models:
                            is_rec = any(ft in mid.lower() for ft in ("1.5-flash", "2.0-flash", "flash"))
                            label = f"{mid} (Free Tier Recommended)" if is_rec else mid
                            result.append({
                                "id": mid,
                                "label": label,
                                "isFreeTierRecommended": is_rec,
                            })
                        if result:
                            return result
            except Exception as exc:
                logger.warning(f"Failed to query live Gemini models with user API key: {exc}")

        # Curated fallback list optimized for Free Tier accounts
        return [
            {
                "id": "gemini-1.5-flash",
                "label": "gemini-1.5-flash (Free Tier Recommended)",
                "isFreeTierRecommended": True,
            },
            {
                "id": "gemini-2.0-flash",
                "label": "gemini-2.0-flash (Fast Free Tier)",
                "isFreeTierRecommended": True,
            },
            {
                "id": "gemini-1.5-pro",
                "label": "gemini-1.5-pro (Standard)",
                "isFreeTierRecommended": False,
            },
        ]

