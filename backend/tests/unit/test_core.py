"""Unit tests for core utilities, rate limiter, and redacting logger."""

import pytest
from app.core.errors import RateLimitExceededException
from app.core.logging import redact_sensitive_data
from app.core.rate_limit import SlidingWindowRateLimiter
from app.utils.text import count_words, extract_json_block, sanitize_text, validate_utf8


def test_count_words():
    assert count_words("") == 0
    assert count_words("   ") == 0
    assert count_words("Hello world") == 2
    assert count_words("This is a multi-line\ncommunication test string.") == 7


def test_validate_utf8():
    assert validate_utf8("Valid UTF-8 string with symbols: € $ ©") is True
    assert validate_utf8("") is True


def test_sanitize_text():
    assert sanitize_text("  hello \r\n world   ") == "hello \n world"
    assert sanitize_text("") == ""
    # Test HTML break normalization
    assert sanitize_text("Line 1<br>Line 2<br/>Line 3<BR />Line 4") == "Line 1\nLine 2\nLine 3\nLine 4"
    assert sanitize_text("Hello<p>World</p>") == "Hello\n\nWorld"
    assert sanitize_text("Para 1<br><br>Para 2") == "Para 1\n\nPara 2"


def test_deduplicate_email_components():
    from app.utils.text import deduplicate_email_components

    # Test stripping duplicate salutation from body
    sal, body, clos = deduplicate_email_components(
        salutation="Dear Customer,",
        body="Dear Customer,\nWe regret to inform you that your shipment is delayed.\nSincerely,\nTeam",
        closing="Sincerely,\nTeam",
    )
    assert sal == "Dear Customer,"
    assert body == "We regret to inform you that your shipment is delayed."
    assert clos == "Sincerely,\nTeam"


def test_extract_json_block():
    # Direct JSON
    raw = '{"subject": "Test", "body": "Content"}'
    assert extract_json_block(raw) == {"subject": "Test", "body": "Content"}

    # Markdown fenced JSON
    markdown_wrapped = '```json\n{"subject": "Hello", "body": "World"}\n```'
    assert extract_json_block(markdown_wrapped) == {"subject": "Hello", "body": "World"}

    # Extra commentary outside JSON
    with_commentary = 'Here is your JSON:\n{"subject": "A", "body": "B"}\nHope this helps!'
    assert extract_json_block(with_commentary) == {"subject": "A", "body": "B"}

    # Invalid JSON
    assert extract_json_block("No JSON here") is None


def test_redact_sensitive_data():
    sample_groq = "Request failed with key: gsk_abcdef12345678901234567890"
    redacted = redact_sensitive_data(sample_groq)
    assert "gsk_" not in redacted
    assert "[REDACTED_CREDENTIAL]" in redacted

    sample_gemini = "Using Gemini key AIzaSyD1234567890abcdef1234567890"
    redacted_gemini = redact_sensitive_data(sample_gemini)
    assert "AIzaSy" not in redacted_gemini

    sample_bearer = "Authorization: Bearer ya29.a0AfH6SMB_some_token"
    redacted_bearer = redact_sensitive_data(sample_bearer)
    assert "ya29" not in redacted_bearer


def test_sliding_window_rate_limiter():
    limiter = SlidingWindowRateLimiter(window_seconds=2)
    key = "user_123:test"

    # Limit of 3 requests
    limiter.check_and_record(key, limit=3)
    limiter.check_and_record(key, limit=3)
    limiter.check_and_record(key, limit=3)

    # 4th request must raise
    with pytest.raises(RateLimitExceededException):
        limiter.check_and_record(key, limit=3)
