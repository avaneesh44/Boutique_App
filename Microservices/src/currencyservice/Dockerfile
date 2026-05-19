# Copyright 2020 Google LLC
# Licensed under the Apache License, Version 2.0

FROM node:20.18.1-bullseye-slim AS builder

# Install build tools required for native modules (pprof)
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY package*.json ./

# Install dependencies (skip optional to avoid pprof issues if possible)
RUN npm install --omit=dev --no-optional

COPY . .

# ---- Runtime image ----
FROM node:20.18.1-bullseye-slim

WORKDIR /usr/src/app

# Copy only necessary files
COPY --from=builder /usr/src/app ./

EXPOSE 7000

CMD ["node", "server.js"]