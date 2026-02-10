# Copyright 2020 Google LLC
# ... (Lisans kısımları aynı) ...

# 👇 DÜZELTME: --platform=$BUILDPLATFORM KISMINI SİLDİM
# Ayrıca sha256 digest'ini kaldırdım ki multi-arch tag'i (3.14.2-alpine) rahatça çekebilsin.
FROM python:3.14.2-alpine AS base

FROM base AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apk update \
    && apk add --no-cache g++ linux-headers \
    && rm -rf /var/cache/apk/*

# get packages
COPY requirements.txt .
RUN pip install -r requirements.txt

FROM base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Enable Profiler
ENV ENABLE_PROFILER=1

RUN apk update \
    && apk add --no-cache libstdc++ \
    && rm -rf /var/cache/apk/*

WORKDIR /email_server

# Grab packages from builder
COPY --from=builder /usr/local/lib/python3.14/ /usr/local/lib/python3.14/

# Add the application
COPY . .

EXPOSE 8080
ENTRYPOINT [ "python", "email_server.py" ]