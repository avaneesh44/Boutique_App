# ---------- Builder ----------
FROM node:20-slim AS builder

# install build dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --omit=dev

COPY . .

# ---------- Runtime ----------
FROM node:20-slim

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY . .

EXPOSE 50051

ENTRYPOINT ["node", "index.js"]