# 使用 SDK 作為建置環境
FROM --platform=linux/amd64 mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# 複製 csproj 並還原依賴
COPY *.csproj ./
RUN dotnet restore

# 複製其餘源代碼
COPY . .

# 發布應用
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

# 使用運行時映像作為最終映像
FROM --platform=linux/amd64 mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# 安裝系統依賴
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
    && rm -rf /var/lib/apt/lists/*

# 複製發布的應用
COPY --from=build /app/publish .

# 設置環境變數
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# 健康檢查
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# 暴露端口
EXPOSE 8080

# 啟動應用
ENTRYPOINT ["dotnet", "Tzichi.Plugin.Server.Web.dll"]