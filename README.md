# Web API Project

一個使用 Next.js 前端和 .NET Core 後端的全端網頁應用程式，採用 Docker 容器化部署。

## 專案結構

```
webapi/
├── backend/          # .NET Core 後端
│   ├── Controllers/  # API 控制器
│   ├── appsettings.json  # 後端配置
│   ├── backend.csproj    # 專案檔
│   └── Program.cs        # 應用程式入口
├── frontend/         # Next.js 前端
│   ├── pages/        # 頁面組件
│   ├── next.config.js # Next.js 配置
│   └── package.json  # 前端依賴
├── data/             # 數據存儲
├── Dockerfile        # Docker 建置檔
├── docker-compose.yml # Docker Compose 配置
└── nginx.conf        # Nginx 配置
```

## 技術架構

### 前端
- Next.js 15.1.3
- Node.js 20.18
- 使用 fetch API 進行後端通訊

### 後端
- .NET 8.0
- ASP.NET Core Web API
- Swagger/OpenAPI

### 基礎設施
- Nginx (反向代理和快取)
- Docker (容器化)
- Docker Compose (服務編排)

## 快速開始

### 前置需求
- Docker
- Docker Compose

### 安裝與運行

1. 克隆專案
```bash
git clone <repository-url>
cd webapi

2. 建置與運行
```bash
docker-compose up -d
```

3. 訪問應用程式
- 前端：http://localhost
- API：http://localhost/api/data
- Swagger UI：http://localhost/api/swagger (開發環境)

## 配置與部署

### 環境變數
- `ASPNETCORE_ENVIRONMENT`: Production
- `NODE_ENV`: production

### 數據存儲
數據存儲在 `./data` 目錄，該目錄作為卷掛載到 Docker 容器中

### 部署方式
應用程式使用 Docker 部署，`docker-compose.yml` 文件包含生產環境的運行配置

### 開發指令
#### 後端
- 配置位於 `backend/appsettings.json`

#### 前端
- 可用指令：
  - `npm run dev` - 啟動開發服務器
  - `npm run build` - 構建生產版本
  - `npm run start` - 啟動生產服務器

## 功能特點

- 多階段 Docker 建置優化
- Nginx 反向代理與快取機制
- 跨域資源共享 (CORS) 支援
- 健康檢查機制
- 錯誤頁面處理
- API 快取策略
- Gzip 壓縮

## API 端點

GET /api/data: 返回測試數據
```json
{
  "message": "Hello from .NET Core!"
}
```

## 開發注意事項

### 平台支援
- 使用 TARGETPLATFORM 確保跨平台兼容性
- 預設支援 linux/amd64 架構

### 快取策略
- 前端快取：10 分鐘 (200/302 響應)
- API 快取：10 分鐘 (200 響應)
- 404 響應：1 分鐘

### 安全性考慮
- 使用環境變數管理敏感設定
- 實作了基本的錯誤處理機制
- Nginx 安全性最佳實踐

### 效能優化
- Nginx 配置
- Gzip 壓縮
- 快取機制
- 上游失敗處理
- 連接超時設定

### Docker 優化
- 多階段建置
- 最小化映像檔大小
- 使用輕量級基礎映像

## 貢獻指南
1. Fork 專案
2. 創建特性分支
3. 提交變更
4. 發送 Pull Request

## License

[MIT](https://choosealicense.com/licenses/mit/)
