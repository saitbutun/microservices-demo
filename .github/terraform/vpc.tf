module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "microservices-demo-vpc"
  cidr = "10.0.0.0/16"

  # İrlanda'daki kullanılabilir bölgeler (Data Centerlar)
  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  
  # Özel Subnetler (Uygulamaların çalışacağı yer - Dışarıdan erişilemez, Güvenli)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  
  # Genel Subnetler (Load Balancer'ın duracağı yer - İnternete açık)
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # NAT Gateway (Özel ağdaki podların internete çıkıp update alması için şart)
  enable_nat_gateway = true
  single_nat_gateway = true # DEMO olduğu için tek tane yeter (Maliyet tasarrufu!)
  enable_vpn_gateway = false

  # Kubernetes'in Load Balancer'ları nereye koyacağını bilmesi için bu etiketler ŞART!
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}