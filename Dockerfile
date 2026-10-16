FROM node:22-slim AS web
WORKDIR /w
COPY frontend/package*.json ./
RUN npm ci --no-audit --no-fund
COPY frontend ./
RUN npm run build

FROM python:3.12-slim
WORKDIR /app
COPY backend/requirements.txt backend/requirements.txt
RUN pip install --no-cache-dir -r backend/requirements.txt "psycopg[binary]"
COPY backend backend
COPY assets assets
COPY --from=web /w/dist frontend/dist
ENV PMA_ALLOW_REMOTE_SETUP=0
EXPOSE 8000
WORKDIR /app/backend
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
