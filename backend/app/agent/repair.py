"""Repair engine executing a single-pass repair for defective outputs."""

from app.agent.prompt_builder import PromptBuilder
from app.core.errors import LLMRepairException
from app.core.logging import logger
from app.providers.base import LLMProvider
from app.schemas.common import OutputContent, SettingsModel
from app.utils.text import (
    deduplicate_email_components,
    extract_json_block,
    sanitize_text,
)


class RepairEngine:
    """Executes single-shot repair on outputs failing validation."""

    @classmethod
    async def repair(
        cls,
        provider: LLMProvider,
        raw_output_dict: dict | None,
        issues: list[str],
        settings: SettingsModel,
        api_key: str,
        model: str,
        temperature: float = 0.5,
    ) -> OutputContent:
        """Attempt exactly ONE repair pass.

        Raises LLMRepairException if repair parsing fails.
        """
        logger.info(f"Initiating single-pass repair for {len(issues)} issues.")
        system_prompt, repair_prompt = PromptBuilder.build_repair_prompts(
            raw_draft=raw_output_dict,
            issues=issues,
            settings=settings,
        )

        try:
            raw_repaired = await provider.generate(
                system_prompt=system_prompt,
                user_prompt=repair_prompt,
                model=model,
                api_key=api_key,
                temperature=temperature,
            )
            repaired_dict = extract_json_block(raw_repaired)
            if not repaired_dict:
                raise LLMRepairException(
                    "Repair attempt failed: Provider did not return valid JSON.",
                    details={"rawResponse": raw_repaired[:300]},
                )

            raw_subj = sanitize_text(repaired_dict.get("subject")) if repaired_dict.get("subject") else None
            raw_sal = sanitize_text(repaired_dict.get("salutation")) if repaired_dict.get("salutation") else None
            raw_body = sanitize_text(repaired_dict.get("body", ""))
            raw_clos = sanitize_text(repaired_dict.get("closing")) if repaired_dict.get("closing") else None

            final_sal, final_body, final_clos = deduplicate_email_components(raw_sal, raw_body, raw_clos)

            return OutputContent(
                subject=raw_subj,
                salutation=final_sal,
                body=final_body,
                closing=final_clos,
            )
        except LLMRepairException:
            raise
        except Exception as exc:
            logger.error(f"Error executing repair attempt: {exc}")
            raise LLMRepairException(f"Repair attempt failed: {exc}") from exc
