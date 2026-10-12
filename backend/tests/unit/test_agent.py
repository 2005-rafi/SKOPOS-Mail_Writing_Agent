"""Unit tests for agent prompt builder, validator, repair engine, and orchestrator."""

import pytest
from app.agent.orchestrator import AgentOrchestrator
from app.agent.prompt_builder import PromptBuilder
from app.agent.validator import Validator
from app.core.constants import ContentType, ToneType
from app.providers.mock import MockLLMProvider
from app.schemas.common import OutputContent, SettingsModel


def test_prompt_builder_generate():
    settings = SettingsModel(
        tone=ToneType.DIRECT,
        contentType=ContentType.EMAIL,
        subjectEnabled=True,
        salutationEnabled=True,
        closingEnabled=True,
        maxWords=80,
    )
    system_prompt, user_prompt = PromptBuilder.build_generate_prompts(
        scenario="Raw materials delayed for one month.",
        settings=settings,
    )

    assert "SKOPOS" in system_prompt
    assert "Raw materials delayed for one month." in user_prompt
    assert "<user_input>" in user_prompt
    assert "</user_input>" in user_prompt
    assert "80 words" in user_prompt


def test_validator_success():
    settings = SettingsModel(
        subjectEnabled=True,
        salutationEnabled=True,
        closingEnabled=True,
        maxWords=100,
    )
    valid_output = OutputContent(
        subject="Status Update Required",
        salutation="Dear John,",
        body="We are awaiting the scheduled shipment. Please deliver by Friday.",
        closing="Best regards,\nSarah",
    )
    is_valid, issues = Validator.validate(valid_output, settings)
    assert is_valid is True
    assert len(issues) == 0


def test_validator_missing_required_fields():
    settings = SettingsModel(
        subjectEnabled=True,
        salutationEnabled=True,
        closingEnabled=True,
        maxWords=100,
    )
    # Missing subject and closing
    output = OutputContent(
        subject=None,
        salutation="Dear Team,",
        body="Please find the attached invoice.",
        closing=None,
    )
    is_valid, issues = Validator.validate(output, settings)
    assert is_valid is False
    assert any("Subject line is enabled" in i for i in issues)
    assert any("Closing sign-off is enabled" in i for i in issues)


def test_validator_empty_body():
    settings = SettingsModel()
    output = OutputContent(
        subject="Invoice",
        salutation="Hi,",
        body="   ",
        closing="Thanks,",
    )
    is_valid, issues = Validator.validate(output, settings)
    assert is_valid is False
    assert any("body is empty" in i for i in issues)


def test_validator_ai_leakage():
    settings = SettingsModel()
    output = OutputContent(
        subject="Notice",
        salutation="Dear Sir,",
        body="As an AI language model, I recommend you contact the customer service directly.",
        closing="Regards,",
    )
    is_valid, issues = Validator.validate(output, settings)
    assert is_valid is False
    assert any("unintended conversational AI marker" in i for i in issues)


@pytest.mark.asyncio
async def test_agent_orchestrator_success():
    provider = MockLLMProvider()
    settings = SettingsModel()
    system_prompt, user_prompt = PromptBuilder.build_generate_prompts("Order status", settings)

    output, summary = await AgentOrchestrator.run_pipeline(
        provider=provider,
        system_prompt=system_prompt,
        user_prompt=user_prompt,
        settings=settings,
        api_key="mock_key",
        model="mock-model",
    )

    assert output.body != ""
    assert summary.passed is True
    assert summary.repaired is False


@pytest.mark.asyncio
async def test_agent_orchestrator_repair_flow():
    provider = MockLLMProvider()
    provider.should_simulate_repair = True  # Triggers 1st call invalid body, 2nd call valid
    settings = SettingsModel()
    system_prompt, user_prompt = PromptBuilder.build_generate_prompts("Delayed materials", settings)

    output, summary = await AgentOrchestrator.run_pipeline(
        provider=provider,
        system_prompt=system_prompt,
        user_prompt=user_prompt,
        settings=settings,
        api_key="mock_key",
        model="mock-model",
    )

    assert output.body != ""
    assert summary.repaired is True
    assert summary.passed is True
    assert provider.call_count == 2
