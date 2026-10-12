"""Groq Cloud LLM provider implementation using async client."""

from typing import Any
import groq
from app.core.constants import DEFAULT_MODELS, ProviderType
from app.core.errors import (
    ProviderAuthException,
    ProviderRateLimitException,
    ProviderTimeoutException,
    ProviderUnavailableException,
)
from app.core.logging import logger
from app.providers.base import LLMProvider


class GroqProvider(LLMProvider):
    """Executes completions via the Groq Cloud API with resilient model fallback."""

    FALLBACK_CANDIDATES: tuple[str, ...] = (
        "llama-3.1-8b-instant",
        "llama3-70b-8192",
        "llama3-8b-8192",
        "mixtral-8x7b-32768",
    )

    @property
    def provider_type(self) -> ProviderType:
        return ProviderType.GROQ

    async def _execute_chat(
        self,
        client: groq.AsyncGroq,
        model_name: str,
        system_prompt: str,
        user_prompt: str,
        temperature: float,
    ) -> str:
        completion = await client.chat.completions.create(
            model=model_name,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=temperature,
            response_format={"type": "json_object"},
        )
        content = completion.choices[0].message.content
        if not content:
            raise ProviderUnavailableException("Groq returned an empty response.")
        return content

    async def generate(
        self,
        system_prompt: str,
        user_prompt: str,
        model: str,
        api_key: str,
        temperature: float = 0.7,
        timeout_seconds: int = 30,
    ) -> str:
        resolved_model = model or DEFAULT_MODELS[ProviderType.GROQ]

        try:
            client = groq.AsyncGroq(api_key=api_key, timeout=timeout_seconds)
            try:
                return await self._execute_chat(
                    client=client,
                    model_name=resolved_model,
                    system_prompt=system_prompt,
                    user_prompt=user_prompt,
                    temperature=temperature,
                )
            except groq.NotFoundError as exc:
                err_msg = str(exc).lower()
                logger.warning(
                    f"Groq model '{resolved_model}' not found or inaccessible for account: {exc}. "
                    "Attempting automatic fallback to verified alternate models..."
                )
                for fallback_model in self.FALLBACK_CANDIDATES:
                    if fallback_model == resolved_model:
                        continue
                    try:
                        logger.info(f"Retrying Groq completion with fallback model '{fallback_model}'...")
                        result = await self._execute_chat(
                            client=client,
                            model_name=fallback_model,
                            system_prompt=system_prompt,
                            user_prompt=user_prompt,
                            temperature=temperature,
                        )
                        logger.info(f"Successfully recovered using fallback Groq model '{fallback_model}'.")
                        return result
                    except (groq.NotFoundError, groq.BadRequestError) as fallback_exc:
                        logger.warning(f"Fallback model '{fallback_model}' failed: {fallback_exc}")
                        continue

                raise ProviderUnavailableException(
                    f"The requested Groq model '{resolved_model}' was not found or accessible with your API key. "
                    "Please select an available model such as 'llama-3.1-8b-instant' or 'mixtral-8x7b-32768' in Settings."
                ) from exc

        except groq.AuthenticationError as exc:
            logger.warning(f"Groq authentication rejected: {exc}")
            raise ProviderAuthException("The Groq API key was rejected as invalid.") from exc
        except groq.RateLimitError as exc:
            logger.warning(f"Groq rate limit encountered: {exc}")
            raise ProviderRateLimitException("Groq rate limit exceeded. Please wait shortly.") from exc
        except (groq.APITimeoutError, TimeoutError) as exc:
            logger.warning("Groq request timed out.")
            raise ProviderTimeoutException("Groq API request timed out.") from exc
        except (ProviderAuthException, ProviderRateLimitException, ProviderTimeoutException, ProviderUnavailableException):
            raise
        except Exception as exc:
            logger.error(f"Unexpected Groq execution error: {exc}")
            raise ProviderUnavailableException("An unexpected error occurred while communicating with Groq.") from exc

    async def get_usage(self, api_key: str) -> dict[str, Any] | None:
        """Groq does not expose a public real-time quota balance endpoint via personal user keys."""
        return None

    async def list_models(self, api_key: str | None = None) -> list[dict[str, Any]]:
        """Query Groq models API live if API key is provided, or return curated free-tier models."""
        free_tier_set = {
            "llama-3.1-8b-instant",
            "llama3-8b-8192",
            "mixtral-8x7b-32768",
            "gemma2-9b-it",
        }

        if api_key and api_key.strip():
            try:
                client = groq.AsyncGroq(api_key=api_key.strip(), timeout=10)
                models_page = await client.models.list()
                model_ids = [m.id for m in models_page.data]

                # Filter for text/chat completion models (exclude whisper audio, vision-only, guard)
                chat_models = [
                    mid for mid in model_ids
                    if not any(ex in mid.lower() for ex in ("whisper", "guard", "audio", "embed", "tts", "stt"))
                ]

                # Sort: put free-tier recommended 8B/instant models at the top
                def sort_key(m_id: str) -> tuple[int, str]:
                    is_free = 0 if (m_id in free_tier_set or "8b" in m_id.lower() or "instant" in m_id.lower()) else 1
                    return (is_free, m_id)

                chat_models.sort(key=sort_key)

                result: list[dict[str, Any]] = []
                for mid in chat_models:
                    is_rec = mid in free_tier_set or "8b" in mid.lower() or "instant" in mid.lower()
                    label = f"{mid} (Free Tier Recommended)" if is_rec else mid
                    result.append({
                        "id": mid,
                        "label": label,
                        "isFreeTierRecommended": is_rec,
                    })
                if result:
                    return result
            except Exception as exc:
                logger.warning(f"Failed to query live Groq models with user API key: {exc}")

        # Curated fallback list optimized for Free Tier accounts
        return [
            {
                "id": "llama-3.1-8b-instant",
                "label": "llama-3.1-8b-instant (Free Tier Recommended)",
                "isFreeTierRecommended": True,
            },
            {
                "id": "llama3-8b-8192",
                "label": "llama3-8b-8192 (Free Tier)",
                "isFreeTierRecommended": True,
            },
            {
                "id": "mixtral-8x7b-32768",
                "label": "mixtral-8x7b-32768 (Free Tier)",
                "isFreeTierRecommended": True,
            },
            {
                "id": "gemma2-9b-it",
                "label": "gemma2-9b-it (Google 9B Free Tier)",
                "isFreeTierRecommended": True,
            },
            {
                "id": "llama-3.3-70b-versatile",
                "label": "llama-3.3-70b-versatile (Tier 1 / Pro)",
                "isFreeTierRecommended": False,
            },
            {
                "id": "llama3-70b-8192",
                "label": "llama3-70b-8192 (Tier 1 / Pro)",
                "isFreeTierRecommended": False,
            },
        ]


