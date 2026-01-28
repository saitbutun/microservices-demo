# 1. KMS Anahtarı (Doğru)
resource "aws_kms_key" "vault" {
  description             = "Vault auto-unseal key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "vault" {
  name          = "alias/vault-unseal"
  target_key_id = aws_kms_key.vault.key_id
}

# 2. IAM Policy (Doğru)
resource "aws_iam_policy" "vault_kms" {
  name = "vault-kms-unseal"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey"
      ]
      Resource = aws_kms_key.vault.arn
    }]
  })
}

# 3. IAM Role (IRSA) - Modül Kullanımı
module "vault_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "vault-kms-unseal-role"

  oidc_providers = {
    vault = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["vault:vault"]
    }
  }
}

# 4. DÜZELTME: Policy'i Modülün oluşturduğu Role takıyoruz
resource "aws_iam_role_policy_attachment" "vault_kms" {
  role       = module.vault_irsa_role.iam_role_name  # <-- BURASI DÜZELDİ
  policy_arn = aws_iam_policy.vault_kms.arn
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

# 5. Helm Chart Kurulumu
resource "helm_release" "vault" {
  name       = "vault"
  namespace  = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.28.0"

  create_namespace = true

  values = [
    <<EOF
server:
  # HA kapalı
  ha:
    enabled: false

  # Standalone mod için konfigürasyonu buraya açıkça yazıyoruz
  standalone:
    enabled: true
    config: |
      ui = true

      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }

      storage "file" {
        path = "/vault/data"
      }

      # İŞTE EKSİK OLAN PARÇA BURASI 👇
      seal "awskms" {
        region     = "eu-west-1"
        kms_key_id = "${aws_kms_key.vault.key_id}"
      }

  # Service Account ve IRSA Rolü
  serviceAccount:
    create: true
    name: "vault"
    annotations:
      eks.amazonaws.com/role-arn: "${module.vault_irsa_role.iam_role_arn}"

  # Disk Ayarları (Veri kalıcılığı için)
  dataStorage:
    enabled: true
    size: 5Gi
    storageClass: "gp2"
EOF
  ]
}