module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "microservices-demo-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true

  node_security_group_additional_rules = {
    ingress_vault_webhook = {
      description                   = "Control Plane to Vault Agent Injector"
      protocol                      = "tcp"
      from_port                     = 8080
      to_port                       = 8080
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  eks_managed_node_groups = {
    general = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["t4g.large"]
      ami_type       = "AL2_ARM_64"
      capacity_type  = "SPOT"

      tags = {
        "k8s.io/cluster-autoscaler/enabled" = "true"
        "k8s.io/cluster-autoscaler/microservices-demo-cluster" = "owned"
      }
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "demo"
    Terraform   = "true"
  }
}

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "ebs-csi-role-microservices-demo-cluster"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
