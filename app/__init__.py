"""Root-level proxy package forwarding all lookups to backend/app."""
import os
import sys

_current_dir = os.path.dirname(os.path.abspath(__file__))
_repo_root = os.path.dirname(_current_dir)
_backend_dir = os.path.join(_repo_root, "backend")
_backend_app_dir = os.path.join(_backend_dir, "app")

if _backend_dir not in sys.path:
    sys.path.insert(0, _backend_dir)

if os.path.isdir(_backend_app_dir) and _backend_app_dir not in __path__:
    __path__.insert(0, _backend_app_dir)
