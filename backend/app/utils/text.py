"""Text processing, sanitization, and structured content extraction utilities."""

import json
import re
from typing import Any


def count_words(text: str) -> int:
    """Calculate word count for a given text string."""
    if not text or not text.strip():
        return 0
    return len(text.strip().split())


def validate_utf8(text: str) -> bool:
    """Verify that a string is valid UTF-8 encodable and decodable."""
    try:
        text.encode("utf-8").decode("utf-8")
        return True
    except (UnicodeEncodeError, UnicodeDecodeError):
        return False


def sanitize_text(text: str) -> str:
    """Clean HTML breaks, extra trailing whitespaces, and normalize line endings."""
    if not text:
        return ""
    # Convert <br>, <br/>, <br />, <p>, </p> to newlines
    normalized = re.sub(r"(?i)<br\s*/?>", "\n", text)
    normalized = re.sub(r"(?i)</?p\s*>", "\n\n", normalized)
    # Normalize Windows CRLF and CR to LF
    normalized = normalized.replace("\r\n", "\n").replace("\r", "\n")
    # Collapse 3+ newlines to max 2 newlines
    normalized = re.sub(r"\n{3,}", "\n\n", normalized)
    return normalized.strip()


def deduplicate_email_components(
    salutation: str | None,
    body: str,
    closing: str | None,
) -> tuple[str | None, str, str | None]:
    """Strip redundant salutation or closing from body if already provided as dedicated fields."""
    cleaned_body = body.strip()

    if salutation and salutation.strip():
        sal_clean = salutation.strip()
        if cleaned_body.lower().startswith(sal_clean.lower()):
            cleaned_body = cleaned_body[len(sal_clean) :].strip()
            cleaned_body = re.sub(r"^[\s,]+", "", cleaned_body).strip()
        else:
            body_lines = cleaned_body.split("\n")
            first_line = body_lines[0].strip().rstrip(",;:- ")
            sal_line = sal_clean.rstrip(",;:- ")
            if first_line.lower() == sal_line.lower():
                cleaned_body = "\n".join(body_lines[1:]).strip()

    if closing and closing.strip():
        clos_clean = closing.strip()
        if cleaned_body.lower().endswith(clos_clean.lower()):
            cleaned_body = cleaned_body[: -len(clos_clean)].strip()
            cleaned_body = re.sub(r"[\s,]+$", "", cleaned_body).strip()
        else:
            body_lines = cleaned_body.split("\n")
            clos_lines = [l.strip().rstrip(",;:- ").lower() for l in clos_clean.split("\n") if l.strip()]
            if body_lines:
                last_line = body_lines[-1].strip().rstrip(",;:- ").lower()
                if last_line in clos_lines or (clos_lines and last_line == clos_lines[-1]):
                    num_to_strip = 1
                    if len(clos_lines) > 1 and len(body_lines) >= len(clos_lines):
                        candidate_block = "\n".join(body_lines[-len(clos_lines) :]).strip().lower()
                        if clos_clean.lower() in candidate_block:
                            num_to_strip = len(clos_lines)
                    cleaned_body = "\n".join(body_lines[:-num_to_strip]).strip()

    return salutation, cleaned_body, closing


def extract_json_block(raw_text: str) -> dict[str, Any] | None:
    """Extract and parse a JSON dictionary from raw LLM output.

    Handles outputs enclosed in ```json ... ``` blocks or raw JSON strings.
    """
    if not raw_text:
        return None

    cleaned = raw_text.strip()

    # Case 1: Try parsing directly
    try:
        data = json.loads(cleaned)
        if isinstance(data, dict):
            return data
    except Exception:
        pass

    # Case 2: Extract from markdown code fence ```json ... ``` or ``` ... ```
    fence_match = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", cleaned, re.DOTALL)
    if fence_match:
        try:
            data = json.loads(fence_match.group(1))
            if isinstance(data, dict):
                return data
        except Exception:
            pass

    # Case 3: Find outermost balanced { ... }
    first_brace = cleaned.find("{")
    last_brace = cleaned.rfind("}")
    if first_brace != -1 and last_brace != -1 and last_brace > first_brace:
        json_candidate = cleaned[first_brace : last_brace + 1]
        try:
            data = json.loads(json_candidate)
            if isinstance(data, dict):
                return data
        except Exception:
            pass

    return None
