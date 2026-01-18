# ---------------------------------------------------------
# 1. Build Aşaması (Standart SDK - Debian tabanlı)
# ---------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS builder
WORKDIR /app

COPY cartservice.csproj .
# Debian tabanlı olduğu için restore işlemi burada hata vermez
RUN dotnet restore cartservice.csproj

COPY . .
RUN dotnet publish cartservice.csproj \
    -c Release \
    -o /app/publish \
    --no-restore

# ---------------------------------------------------------
# 2. Run Aşaması (Standart Runtime - SHELL İÇERİR)
# ---------------------------------------------------------
# 'alpine' veya 'chiseled' YAZMIYORUZ. Düz 8.0 kullanıyoruz.
# Bunun içinde /bin/sh da var, /bin/bash de var. Vault bayılır buna.
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

COPY --from=builder /app/publish .

EXPOSE 7070
ENV DOTNET_EnableDiagnostics=0 \
    ASPNETCORE_HTTP_PORTS=7070

# Root yetkisiyle çalışsın ki Vault dosyaları rahat okusun (Demo ortamı)
ENTRYPOINT ["./cartservice"]