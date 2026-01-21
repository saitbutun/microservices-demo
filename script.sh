ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="eu-west-1"
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

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

for SERVICE in "${SERVICES[@]}"; do
  FILE="kubernetes-manifests/${SERVICE}.yaml"
  
  if [ -f "$FILE" ]; then
    echo "🛠️  Düzeltiliyor: $SERVICE -> microservices-demo/$SERVICE"
    sed -i "s|image: .*|image: $ECR_URL/microservices-demo/$SERVICE:latest|g" $FILE
  else
    echo "⚠️  Dosya bulunamadı: $FILE"
  fi
done

