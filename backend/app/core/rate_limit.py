"""In-memory sliding window rate limiter.

Tracks request counts per window per identifier (IP + Firebase UID) without external dependencies.
"""

import time
from collections import defaultdict
from threading import Lock
from typing import Final
from app.core.errors import RateLimitExceededException


class SlidingWindowRateLimiter:
    """Sliding-window in-memory rate limiter with thread-safe timestamp tracking."""

    def __init__(self, window_seconds: int = 60) -> None:
        self.window_seconds: Final[int] = window_seconds
        self._history: dict[str, list[float]] = defaultdict(list)
        self._lock: Lock = Lock()

    def check_and_record(self, key: str, limit: int) -> None:
        """Check if request is within limits and record the attempt.

        Raises RateLimitExceededException if limit is exceeded.
        """
        now = time.monotonic()
        cutoff = now - self.window_seconds

        with self._lock:
            timestamps = self._history[key]
            # Prune timestamps older than window
            valid_timestamps = [t for t in timestamps if t > cutoff]

            if len(valid_timestamps) >= limit:
                # Still record or raise
                self._history[key] = valid_timestamps
                raise RateLimitExceededException(
                    f"Rate limit exceeded ({limit} req/{self.window_seconds}s). Please wait before trying again."
                )

            valid_timestamps.append(now)
            self._history[key] = valid_timestamps

    def clear(self) -> None:
        """Clear all rate limit state (primarily for test isolation)."""
        with self._lock:
            self._history.clear()


# Global in-memory rate limiter singleton
rate_limiter = SlidingWindowRateLimiter(window_seconds=60)
