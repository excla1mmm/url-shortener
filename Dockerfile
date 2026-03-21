# Stage 1: Dependencies
FROM python:3.12.9-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Final image
FROM python:3.12.9-slim
WORKDIR /app

# Creating non root user
RUN useradd --create-home appuser
USER appuser

COPY --from=builder /root/.local /home/appuser/.local
COPY app/ ./app/

ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]