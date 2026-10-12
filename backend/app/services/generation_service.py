"""Service handling email and letter generation requests."""

from datetime import datetime, timezone
import uuid
from app.agent.orchestrator import AgentOrchestrator
from app.agent.prompt_builder import PromptBuilder
from app.core.constants import DEFAULT_MODELS
from app.core.security import UserContext
from app.providers.registry import provider_registry
from app.schemas.generation import GenerateRequest, GenerateResponse
from app.utils.text import count_words


class GenerationService:
    """Orchestrates generation requests from incoming payloads to response envelopes."""

    @classmethod
    async def generate(
        cls,
        request: GenerateRequest,
        user: UserContext,
    ) -> GenerateResponse:
        provider = provider_registry.get(request.provider)
        model = request.model or DEFAULT_MODELS[request.provider]

        system_prompt, user_prompt = PromptBuilder.build_generate_prompts(
            scenario=request.scenario,
            settings=request.settings,
        )

        output, validation = await AgentOrchestrator.run_pipeline(
            provider=provider,
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            settings=request.settings,
            api_key=request.apiKey,
            model=model,
            temperature=request.settings.temperature,
        )

        word_count = count_words(output.body)
        run_id = f"gen_{uuid.uuid4().hex[:12]}"
        now_iso = datetime.now(timezone.utc).isoformat()

        return GenerateResponse(
            success=True,
            id=run_id,
            type=request.contentType,
            output=output,
            settings=request.settings,
            provider=request.provider,
            model=model,
            wordCount=word_count,
            validation=validation,
            createdAt=now_iso,
        )
