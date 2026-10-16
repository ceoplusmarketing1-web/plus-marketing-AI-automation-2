@echo off
REM Windows: double-click this file
cd /d "%~dp0"
where python >nul 2>nul || (echo Python 3.11+ is required: https://www.python.org/downloads/ & pause & exit /b 1)
if not exist .venv ( python -m venv .venv )
.venv\Scripts\pip install -q -r backend\requirements.txt
if not exist frontend\dist\index.html (
  where npm >nul 2>nul || (echo frontend\dist is missing and Node.js is not installed. & pause & exit /b 1)
  pushd frontend & call npm install --no-audit --no-fund & call npm run build & popd
)
echo.
echo   Plus Marketing AI is starting.  Open:  http://127.0.0.1:8000
echo   (keep this window open; close it to stop)
echo.
cd backend
..\.venv\Scripts\uvicorn app.main:app --host 127.0.0.1 --port 8000
pause
