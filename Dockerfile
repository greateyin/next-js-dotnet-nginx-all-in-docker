# 使用 ARG 來設置架構和 Node.js 版本
ARG NODE_VERSION=20.18
ARG TARGETPLATFORM=linux/amd64

FROM --platform=$TARGETPLATFORM node:${NODE_VERSION}-slim AS base

# === 1. 前端建置階段 ===
FROM base AS frontend-builder
WORKDIR /frontend

COPY frontend/package.json ./package.json
COPY frontend/next.config.js ./next.config.js
COPY frontend/pages ./pages
RUN mkdir -p public

RUN npm install
RUN npm run build

# === 2. 後端建置階段 ===
FROM --platform=$TARGETPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS backend-builder
WORKDIR /src

COPY backend/*.csproj ./ 
RUN dotnet restore

COPY backend/ ./
RUN dotnet publish -c Release -o /app/publish \
    --self-contained false \
    --runtime linux-x64 \
    /p:PublishReadyToRun=true \
    /verbosity:diag

# === 3. 最終運行階段 ===
FROM --platform=$TARGETPLATFORM mcr.microsoft.com/dotnet/aspnet:8.0 AS runner

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nodejs npm nginx && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/share/nginx/html && \
    echo "<!DOCTYPE html><html><head><title>Error</title></head><body><h1>An error occurred.</h1></body></html>" > /usr/share/nginx/html/50x.html

WORKDIR /app

COPY --from=backend-builder /app/publish ./backend/
COPY --from=frontend-builder /frontend/.next ./frontend/.next
COPY --from=frontend-builder /frontend/package.json ./frontend/
COPY --from=frontend-builder /frontend/next.config.js ./frontend/
COPY --from=frontend-builder /frontend/node_modules ./frontend/node_modules

COPY nginx.conf /etc/nginx/nginx.conf

ENV ASPNETCORE_URLS=http://+:8080
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'cd /app/frontend && node_modules/.bin/next start --port 3000 &' >> /app/start.sh && \
    echo 'cd /app/backend && dotnet backend.dll &' >> /app/start.sh && \
    echo 'nginx -g "daemon off;"' >> /app/start.sh && \
    chmod +x /app/start.sh

RUN mkdir -p /var/cache/nginx/frontend /var/cache/nginx/api && \
    chown -R www-data:www-data /var/cache/nginx

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

EXPOSE 80
CMD ["/app/start.sh"]
