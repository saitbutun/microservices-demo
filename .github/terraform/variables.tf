variable "app_name" {
  default = "microservices-demo"
}

variable "services" {
  description = "Servislerin listesi - Kaynak kod klasör isimleriyle AYNI olmalı"
  type        = set(string)
  default     = [
    "adservice",
    "cartservice",
    "checkoutservice",      
    "currencyservice",      
    "emailservice",
    "frontend",
    "loadgenerator",
    "paymentservice",       
    "productcatalogservice",
    "recommendationservice",
    "shippingservice"       
  ]
}
