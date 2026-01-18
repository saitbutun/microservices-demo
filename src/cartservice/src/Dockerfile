FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0-noble AS builder
# NOT: Yukarıdaki versiyonu 10 yazmışsın ama .NET 10 henüz çıkmadı, muhtemelen 8 veya 9 kullanıyorsundur.
# Eğer özel bir preview sürüm değilse burayı 8.0 veya 9.0 yapmalısın.
ARG TARGETARCH
WORKDIR /app
COPY cartservice.csproj .
RUN dotnet restore cartservice.csproj \
    -a $TARGETARCH
COPY . .
RUN dotnet publish cartservice.csproj \
    -p:PublishSingleFile=true \
    -a $TARGETARCH \
    --self-contained true \
    -p:PublishTrimmed=true \
    -p:TrimMode=full \
    -c release \
    -o /cartservice

# DÜZELTME BURADA: "chiseled" ifadesini kaldırdık.
# Artık içinde /bin/sh var, Vault scriptleri çalışacak.
# Versiyon numarasını (10.0.0) kendi gerçek versiyonunla (örn: 8.0 veya 9.0) teyit et.
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-noble

WORKDIR /app
COPY --from=builder /cartservice .
EXPOSE 7070
ENV DOTNET_EnableDiagnostics=0 \
    ASPNETCORE_HTTP_PORTS=7070
USER 1000
ENTRYPOINT ["/app/cartservice"]