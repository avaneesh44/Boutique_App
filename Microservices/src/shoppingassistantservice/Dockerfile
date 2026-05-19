FROM python:3.12.8-slim AS base

FROM base AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends g++ \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

FROM base

ENV PYTHONUNBUFFERED=1
ENV PORT=8080

WORKDIR /shoppingassistantservice

COPY --from=builder /usr/local/lib/python3.12/ /usr/local/lib/python3.12/

COPY . .

EXPOSE 8080

ENTRYPOINT ["python", "shoppingassistantservice.py"]