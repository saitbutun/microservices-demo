# 1. AWS Hesap ID'sini ve Bölgeyi alalım (Otomatik)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="eu-west-1"
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

echo "🎯 Hedef ECR: $ECR_URL"

# 2. Değişecek servislerin listesi (Google Demo'daki isimler)
SERVICES=(
  "emailservice"
  "productcatalogservice"
  "recommendationservice"
  "shippingservice"
  "checkoutservice"
  "paymentservice"
  "currencyservice"
  "cartservice"
  "frontend"
  "adservice"
)

# 3. Döngüye girip hepsini güncelleyelim
for SERVICE in "${SERVICES[@]}"; do
  FILE="kubernetes-manifests/${SERVICE}.yaml"
  
  if [ -f "$FILE" ]; then
    echo "🛠️  Güncelleniyor: $SERVICE"
    # Linux için sed komutu (Mac kullanıyorsan -i '' kullanman gerekir)
    sed -i "s|image: .*|image: $ECR_URL/$SERVICE:latest|g" $FILE
  else
    echo "⚠️  Dosya bulunamadı: $FILE (Atlanıyor)"
  fi
done

echo "✅ Tüm manifestler senin ECR adresine yönlendirildi!"
