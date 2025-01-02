# 使用 Node.js 作為基礎映像
FROM --platform=linux/amd64 node:20.18-slim AS base

# 1. 依賴安裝階段
FROM base AS deps
WORKDIR /app

# 複製 package.json 文件
COPY package.json ./
COPY package-lock.json* ./

# 安裝依賴
RUN npm ci

# 2. 建置階段
FROM base AS builder
WORKDIR /app

# 複製依賴
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# 建置應用
ENV NEXT_TELEMETRY_DISABLED 1
RUN npm run build

# 3. 運行階段
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

# 創建非 root 用戶
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# 複製必要文件
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# 設置正確的權限
RUN chown -R nextjs:nodejs /app

# 切換到非 root 用戶
USER nextjs

# 暴露端口
EXPOSE 3000

# 健康檢查
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD node -e "try{require('http').get('http://localhost:3000/', res => res.statusCode === 200 ? process.exit(0) : process.exit(1))}catch(e){process.exit(1)}"

# 啟動應用
ENV PORT 3000
CMD ["node", "server.js"]