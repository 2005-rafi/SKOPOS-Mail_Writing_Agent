"""Agent Orchestrator controlling the full generation, validation, and repair lifecycle."""

from typing import Tuple
from app.agent.repair import RepairEngine
from app.agent.validator import Validator
from app.core.errors import LLMGenerationException, LLMRepairException
from app.core.logging import logger
from app.providers.base import LLMProvider
from app.schemas.common import OutputContent, SettingsModel, ValidationSummary
from app.utils.text import (
    deduplicate_email_components,
    extract_json_block,
    sanitize_text,
)


class AgentOrchestrator:
    """Coordinates Prompt -> LLM Generation -> Validation -> Repair (Max 1) -> Output."""

    @classmethod
    async def run_pipeline(
        cls,
        provider: LLMProvider,
        system_prompt: str,
        user_prompt: str,
        settings: SettingsModel,
        api_key: str,
        model: str,
        temperature: float = 0.7,
    ) -> Tuple[OutputContent, ValidationSummary]:
        """Execute the end-to-end generation and validation pipeline."""
        logger.info(f"Executing pipeline with provider '{provider.provider_type.value}' model '{model}'")

        # 1. Primary LLM Generation
        raw_text = await provider.generate(
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            model=model,
            api_key=api_key,
            temperature=temperature,
        )

        parsed_dict = extract_json_block(raw_text)
        if not parsed_dict:
            logger.warning("LLM output did not contain parseable JSON dictionary.")
            # Trigger repair immediately for non-JSON response
            parsed_output = None
        else:
            raw_subj = sanitize_text(parsed_dict.get("subject")) if parsed_dict.get("subject") else None
            raw_sal = sanitize_text(parsed_dict.get("salutation")) if parsed_dict.get("salutation") else None
            raw_body = sanitize_text(parsed_dict.get("body", ""))
            raw_clos = sanitize_text(parsed_dict.get("closing")) if parsed_dict.get("closing") else None

            final_sal, final_body, final_clos = deduplicate_email_components(raw_sal, raw_body, raw_clos)

            parsed_output = OutputContent(
                subject=raw_subj,
                salutation=final_sal,
                body=final_body,
                closing=final_clos,
            )

        # 2. Validation
        is_valid, issues = Validator.validate(parsed_output, settings)

        # If valid, return immediately
        if is_valid and parsed_output:
            return parsed_output, ValidationSummary(passed=True, repaired=False, issues=[])

        logger.info(f"Initial validation failed ({len(issues)} issues). Triggering single-pass repair...")

        # 3. Single Repair Attempt
        try:
            repaired_output = await RepairEngine.repair(
                provider=provider,
                raw_output_dict=parsed_dict,
                issues=issues,
                settings=settings,
                api_key=api_key,
                model=model,
                temperature=max(0.2, temperature - 0.2),  # Slightly lower temperature for deterministic repair
            )

            # 4. Re-validate repaired output
            repaired_valid, post_repair_issues = Validator.validate(repaired_output, settings)
            if not repaired_valid:
                logger.warning(f"Repair attempt concluded with remaining issues: {post_repair_issues}")
                # We return the repaired output with warning summary rather than crashing, unless body is empty
                if not repaired_output.body:
                    raise LLMRepairException("Repair failed to generate communication body.")

            return repaired_output, ValidationSummary(
                passed=repaired_valid,
                repaired=True,
                issues=post_repair_issues if not repaired_valid else issues,
            )

        except LLMRepairException:
            # If initial output had at least some body, fallback to it rather than crashing
            if parsed_output and parsed_output.body:
                logger.warning("Repair failed; returning initial output with validation flags.")
                return parsed_output, ValidationSummary(passed=False, repaired=True, issues=issues)
            raise LLMGenerationException("Failed to generate and repair communication output.")
