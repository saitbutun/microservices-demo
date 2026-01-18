# ---------------------------------------------------------
# 1. Build Aşaması (SDK Kullanılır)
# ---------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder
WORKDIR /app

# Proje dosyasını kopyala ve bağımlılıkları çek
COPY cartservice.csproj .
RUN dotnet restore cartservice.csproj

# Tüm kodu kopyala ve derle
COPY . .
RUN dotnet publish cartservice.csproj \
    -c Release \
    -o /app/publish \
    --no-restore

# ---------------------------------------------------------
# 2. Run Aşaması (Shell içeren Alpine Runtime Kullanılır)
# ---------------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app

# Derlenen dosyaları builder aşamasından al
COPY --from=builder /app/publish .

# Port ve Environment ayarları
EXPOSE 7070
ENV DOTNET_EnableDiagnostics=0 \
    ASPNETCORE_HTTP_PORTS=7070

# Güvenlik için root olmayan kullanıcıya geç
# (Alpine imajlarında genelde 'app' kullanıcısı olmazsa default kalabilir veya oluşturulabilir, 
# ama sock-shop genelde root olarak başlar, şimdilik bu satırı sildim ki permission hatası alma)
# USER 1000 

ENTRYPOINT ["./cartservice"]