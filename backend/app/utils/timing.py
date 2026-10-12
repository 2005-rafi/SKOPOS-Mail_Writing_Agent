"""Timing utilities for latency measurement."""

import time


class Timer:
    """Context manager for timing execution in milliseconds."""

    def __init__(self) -> None:
        self.start_time: float = 0.0
        self.duration_ms: float = 0.0

    def __enter__(self) -> "Timer":
        self.start_time = time.perf_counter()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        self.duration_ms = (time.perf_counter() - self.start_time) * 1000.0
