"""Deterministic and semantic validation engine.

Performs deterministic rule checks first before evaluating semantic qualities.
"""

from app.schemas.common import OutputContent, SettingsModel
from app.utils.text import count_words, validate_utf8


class Validator:
    """Validates generated communications against structural and content rules."""

    # Model refusal or conversational leakage markers
    LEAKAGE_MARKERS = [
        "as an ai",
        "i am an ai",
        "here is your email",
        "here is the letter",
        "sure, here is",
        "i cannot fulfill",
        "as a large language model",
    ]

    @classmethod
    def validate(
        cls,
        output: OutputContent | None,
        settings: SettingsModel,
    ) -> tuple[bool, list[str]]:
        """Run deterministic and semantic validation checks.

        Returns (is_valid, list_of_issues).
        """
        issues: list[str] = []

        if not output:
            return False, ["Output is null or malformed JSON."]

        # 1. Deterministic Validation: Body presence
        if not output.body or not output.body.strip():
            issues.append("The communication body is empty.")
            return False, issues

        # 2. Deterministic Validation: UTF-8 encoding
        if not validate_utf8(output.body):
            issues.append("Output body contains invalid UTF-8 characters.")

        # 3. Deterministic Validation: Required structural fields
        if settings.subjectEnabled:
            if not output.subject or not output.subject.strip():
                issues.append("Subject line is enabled in configuration but was missing in output.")

        if settings.salutationEnabled:
            if not output.salutation or not output.salutation.strip():
                issues.append("Salutation is enabled in configuration but was missing in output.")

        if settings.closingEnabled:
            if not output.closing or not output.closing.strip():
                issues.append("Closing sign-off is enabled in configuration but was missing in output.")

        # 4. Deterministic Validation: Word count compliance
        # Allow a slight 10% tolerance over user-specified max words to account for token boundaries
        word_count = count_words(output.body)
        max_allowed = int(settings.maxWords * 1.15)
        if word_count > max_allowed:
            issues.append(
                f"Body length ({word_count} words) exceeds configured maximum limit ({settings.maxWords} words)."
            )

        # 5. Semantic Validation: Conversational leakage / AI boilerplate check
        lower_body = output.body.lower()
        for marker in cls.LEAKAGE_MARKERS:
            if marker in lower_body:
                issues.append(f"Output contains unintended conversational AI marker: '{marker}'.")
                break

        is_valid = len(issues) == 0
        return is_valid, issues
