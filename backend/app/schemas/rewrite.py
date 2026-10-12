"""Request and response models for rewrite endpoint."""

from pydantic import BaseModel, ConfigDict, Field
from app.core.constants import (
    ContentType,
    MAX_PREVIOUS_OUTPUT_LENGTH,
    MAX_REFINEMENT_LENGTH,
    ProviderType,
)
from app.schemas.common import OutputContent, SettingsModel, ValidationSummary


class RewriteRequest(BaseModel):
    """Payload to rewrite existing written content."""

    model_config = ConfigDict(extra="ignore")

    existingContent: str = Field(
        ...,
        min_length=5,
        max_length=MAX_PREVIOUS_OUTPUT_LENGTH,
        description="The rough draft or text to be rewritten",
    )
    instruction: str | None = Field(
        default=None,
        max_length=MAX_REFINEMENT_LENGTH,
        description="Specific emphasis or instructions for rewriting",
    )
    contentType: ContentType = Field(default=ContentType.EMAIL, description="Target document type")
    settings: SettingsModel = Field(default_factory=SettingsModel, description="Writing preferences")
    provider: ProviderType = Field(default=ProviderType.GROQ, description="AI provider")
    model: str | None = Field(default=None, description="Specific model ID override")
    apiKey: str = Field(..., min_length=1, description="Client-provided provider API key")


class RewriteResponse(BaseModel):
    """Successful rewrite response envelope."""

    success: bool = True
    id: str
    output: OutputContent
    settings: SettingsModel
    provider: ProviderType
    model: str
    wordCount: int
    validation: ValidationSummary
    createdAt: str
