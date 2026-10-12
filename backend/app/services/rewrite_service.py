"""Service handling draft rewriting requests."""

from datetime import datetime, timezone
import uuid
from app.agent.orchestrator import AgentOrchestrator
from app.agent.prompt_builder import PromptBuilder
from app.core.constants import DEFAULT_MODELS
from app.core.security import UserContext
from app.providers.registry import provider_registry
from app.schemas.rewrite import RewriteRequest, RewriteResponse
from app.utils.text import count_words


class RewriteService:
    """Orchestrates content rewriting according to user preferences."""

    @classmethod
    async def rewrite(
        cls,
        request: RewriteRequest,
        user: UserContext,
    ) -> RewriteResponse:
        provider = provider_registry.get(request.provider)
        model = request.model or DEFAULT_MODELS[request.provider]

        system_prompt, user_prompt = PromptBuilder.build_rewrite_prompts(
            existing_content=request.existingContent,
            instruction=request.instruction,
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
        run_id = f"rew_{uuid.uuid4().hex[:12]}"
        now_iso = datetime.now(timezone.utc).isoformat()

        return RewriteResponse(
            success=True,
            id=run_id,
            output=output,
            settings=request.settings,
            provider=request.provider,
            model=model,
            wordCount=word_count,
            validation=validation,
            createdAt=now_iso,
        )
