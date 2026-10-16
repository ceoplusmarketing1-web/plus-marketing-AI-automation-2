#!/usr/bin/env bash
# Mac / Linux: double-click or run  ./start.sh
set -e
cd "$(dirname "$0")"
if ! command -v python3 >/dev/null; then echo "Python 3.11+ is required: https://www.python.org/downloads/"; exit 1; fi
[ -d .venv ] || python3 -m venv .venv
.venv/bin/pip install -q -r backend/requirements.txt
if [ ! -f frontend/dist/index.html ]; then
  command -v npm >/dev/null || { echo "frontend/dist is missing and Node.js is not installed."; exit 1; }
  (cd frontend && npm install --no-audit --no-fund && npm run build)
fi
echo ""; echo "  Plus Marketing AI is starting.  Open:  http://127.0.0.1:8000"; echo "  (keep this window open; press Ctrl+C to stop)"; echo ""
cd backend && exec ../.venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000
