"""Request and response models for generation endpoint."""

from pydantic import BaseModel, ConfigDict, Field
from app.core.constants import (
    ContentType,
    MAX_SCENARIO_LENGTH,
    ProviderType,
)
from app.schemas.common import OutputContent, SettingsModel, ValidationSummary


class GenerateRequest(BaseModel):
    """Payload to generate an email or letter from a scenario."""

    model_config = ConfigDict(extra="ignore")

    scenario: str = Field(
        ...,
        min_length=5,
        max_length=MAX_SCENARIO_LENGTH,
        description="The event, situation, or message intent to generate communication for",
    )
    contentType: ContentType = Field(default=ContentType.EMAIL, description="Output communication type")
    settings: SettingsModel = Field(default_factory=SettingsModel, description="Writing preferences")
    provider: ProviderType = Field(default=ProviderType.GROQ, description="AI provider to execute with")
    model: str | None = Field(default=None, description="Specific model ID override")
    apiKey: str = Field(..., min_length=1, description="Client-provided provider API key")


class GenerateResponse(BaseModel):
    """Successful generation response envelope."""

    success: bool = True
    id: str = Field(..., description="Unique generation run ID")
    type: ContentType
    output: OutputContent
    settings: SettingsModel
    provider: ProviderType
    model: str
    wordCount: int
    validation: ValidationSummary
    createdAt: str
