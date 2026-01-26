terraform {
  backend "s3" {
    bucket         = "saitbutun-terraform-state"
    key            = "microservices-demo/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
