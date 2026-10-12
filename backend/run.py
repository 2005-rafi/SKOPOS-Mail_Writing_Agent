"""SKOPOS Production Entrypoint for Render and Local Deployments.

Works seamlessly whether invoked from the repository root or backend subdirectory.
"""
import os
import sys
from pathlib import Path
import uvicorn

# Determine paths
current_dir = Path(__file__).resolve().parent
if (current_dir / "backend" / "app").is_dir():
    backend_dir = current_dir / "backend"
elif (current_dir / "app").is_dir():
    backend_dir = current_dir
else:
    backend_dir = current_dir / "backend"

# Ensure backend directory is first in sys.path
backend_str = str(backend_dir)
if backend_str not in sys.path:
    sys.path.insert(0, backend_str)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8000"))
    host = os.environ.get("HOST", "0.0.0.0")
    
    uvicorn.run(
        "app.main:app",
        host=host,
        port=port,
        app_dir=backend_str,
        workers=1,
        limit_concurrency=50,
        timeout_keep_alive=30,
        log_level=os.environ.get("LOG_LEVEL", "info").lower(),
    )
