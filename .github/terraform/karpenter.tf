module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.0"

  cluster_name = module.eks.cluster_name

  # IRSA (Controller'ın yetkisi)
  enable_irsa            = true
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  # Node Role (Sunucuların yetkisi)
  create_node_iam_role = true
  
  # Spot Interruption (Opsiyonel ama önerilir, hata verirse bunu da false yapabiliriz)
  enable_spot_termination = true

  tags = {
    Environment = "demo"
    Terraform   = "true"
  }
}


# Çıktılar (ArgoCD için lazım olacak)
output "karpenter_irsa_arn" {
  value = module.karpenter.iam_role_arn
}

output "karpenter_node_role_name" {
  value = module.karpenter.node_iam_role_name
}

output "karpenter_queue_name" {
  value = module.karpenter.queue_name
}