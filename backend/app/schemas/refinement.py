"""Request and response models for refinement endpoint."""

from pydantic import BaseModel, ConfigDict, Field
from app.core.constants import (
    ContentType,
    MAX_REFINEMENT_LENGTH,
    ProviderType,
)
from app.schemas.common import OutputContent, SettingsModel, ValidationSummary


class RefineRequest(BaseModel):
    """Payload to refine previously generated communication."""

    model_config = ConfigDict(extra="ignore")

    previousOutput: OutputContent = Field(..., description="The output previously generated")
    instruction: str = Field(
        ...,
        min_length=2,
        max_length=MAX_REFINEMENT_LENGTH,
        description="Conversational modification request (e.g., 'Make it firmer', 'Shorten paragraph 2')",
    )
    contentType: ContentType = Field(default=ContentType.EMAIL, description="Target document type")
    settings: SettingsModel = Field(default_factory=SettingsModel, description="Writing preferences")
    provider: ProviderType = Field(default=ProviderType.GROQ, description="AI provider")
    model: str | None = Field(default=None, description="Specific model ID override")
    apiKey: str = Field(..., min_length=1, description="Client-provided provider API key")


class RefineResponse(BaseModel):
    """Successful refinement response envelope."""

    success: bool = True
    id: str
    output: OutputContent
    settings: SettingsModel
    provider: ProviderType
    model: str
    wordCount: int
    validation: ValidationSummary
    createdAt: str
