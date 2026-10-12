"""Shared schemas for output structures, writing settings, and standardized error envelopes."""

from typing import Any
from pydantic import BaseModel, ConfigDict, Field
from app.core.constants import (
    ContentType,
    DEFAULT_MAX_WORDS,
    DEFAULT_TEMPERATURE,
    StyleType,
    ToneType,
)


class OutputContent(BaseModel):
    """Structured generated communication content."""

    model_config = ConfigDict(extra="ignore")

    subject: str | None = Field(default=None, description="Email subject line or letter title")
    salutation: str | None = Field(default=None, description="Opening greeting")
    body: str = Field(..., description="Main communication body")
    closing: str | None = Field(default=None, description="Formal closing sign-off")


class SettingsModel(BaseModel):
    """User-controlled generation preferences."""

    model_config = ConfigDict(extra="ignore")

    tone: ToneType = Field(default=ToneType.PROFESSIONAL, description="Desired communication tone")
    customTone: str | None = Field(default=None, max_length=200, description="Custom tone instructions when tone is custom")
    language: str = Field(default="English", description="Target output language")
    contentType: ContentType = Field(default=ContentType.EMAIL, description="Document type")
    style: StyleType = Field(default=StyleType.CONCISE, description="Stylistic approach")
    customStyle: str | None = Field(default=None, max_length=200, description="Custom stylistic instructions when style is custom")
    subjectEnabled: bool = Field(default=True, description="Whether subject line is required")
    salutationEnabled: bool = Field(default=True, description="Whether salutation is required")
    closingEnabled: bool = Field(default=True, description="Whether closing sign-off is required")
    maxWords: int = Field(default=DEFAULT_MAX_WORDS, ge=20, le=500, description="Maximum word limit")
    temperature: float = Field(default=DEFAULT_TEMPERATURE, ge=0.0, le=1.0, description="Model temperature")



class ValidationSummary(BaseModel):
    """Summary of deterministic and semantic validation."""

    passed: bool = Field(..., description="Whether content passed all validation criteria")
    repaired: bool = Field(default=False, description="Whether repair was performed")
    issues: list[str] = Field(default_factory=list, description="Validation issues identified")


class ErrorDetail(BaseModel):
    """Standardized error object."""

    code: str
    message: str
    requestId: str
    details: dict[str, Any] | None = None


class ErrorEnvelope(BaseModel):
    """Standardized top-level error response."""

    success: bool = False
    error: ErrorDetail
