variable "app_name" {
  default = "microservices-demo"
}

variable "services" {
  description = "Servislerin listesi - Kaynak kod klasör isimleriyle AYNI olmalı"
  type        = set(string)
  default     = [
    "adservice",
    "cartservice",
    "checkoutservice",      # checkout -> checkoutservice oldu
    "currencyservice",      # currency -> currencyservice oldu
    "emailservice",
    "frontend",
    "loadgenerator",
    "paymentservice",       # payment -> paymentservice oldu
    "productcatalogservice",# productcatalog -> productcatalogservice oldu
    "recommendationservice",# recommendation -> recommendationservice oldu
    "shippingservice"       # shipping -> shippingservice oldu
  ]
}