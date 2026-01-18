# ---------------------------------------------------------
# 1. Build Aşaması (SDK 10 Kullanıyoruz - Hata Vermez)
# ---------------------------------------------------------
# Senin projeye uygun en güncel SDK imajı
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS builder
WORKDIR /app

# Proje dosyasını kopyala
COPY cartservice.csproj .
# Şimdi .NET 10 SDK olduğu için burası hatasız çalışacak
RUN dotnet restore cartservice.csproj

# Kodları kopyala ve derle
COPY . .
# Standart publish yapıyoruz (SingleFile yapmıyoruz ki hata riskini azaltalım)
RUN dotnet publish cartservice.csproj \
    -c Release \
    -o /app/publish \
    --no-restore

# ---------------------------------------------------------
# 2. Run Aşaması (Standart Runtime - SHELL İÇERİR)
# ---------------------------------------------------------
# Chiseled DEĞİL, normal aspnet 10.0 imajı kullanıyoruz.
# Bunda /bin/sh var, Vault bunu sever.
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app

COPY --from=builder /app/publish .

# Port ayarı (Senin eski dosyadaki gibi)
ENV DOTNET_EnableDiagnostics=0 \
    ASPNETCORE_HTTP_PORTS=7070

# Root kullanıcısı ile çalışsın (Demo ortamı için en garantisi)
USER root

# Standart publish yaptığımız için dll çalıştırıyoruz
ENTRYPOINT ["dotnet", "cartservice.dll"]