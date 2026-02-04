  Microservices Demo - Kurulum ve Dağıtım Rehberi
Bu proje, “Sock Shop” mikroservis uygulaması için uçtan uca bir Platform Engineering uygulamasını göstermektedir.
Gerçek hayattan bir senaryoyu simüle ederek, legacy (eski) bir uygulamanın AWS EKS, GitOps ve Infrastructure as Code (IaC) prensipleri kullanılarak nasıl modernize edildiğini ortaya koyar.

📋 Ön Hazırlık
Projeyi klonladıktan sonra (Ana dizindeyken) aşağıdaki adımları sırasıyla takip edin.

1. Kümeye Bağlan (AWS EKS)
Kubernetes konfigürasyonunu yerel makineye çekin:

Bash
aws eks update-kubeconfig --region eu-west-1 --name microservices-demo-cluster
2. Altyapı ve Şifre Üretimi (Terraform)
Terraform dosyaları .github/terraform dizinindedir. Oraya girip şifreleri üretin ve Vault Job dosyasını hazırlayın:

Bash
# Terraform dizinine gir
cd .github/terraform

# Provider'ları indir
terraform init

# Dosyaları üret (generated.yaml oluşacak)
terraform apply
# ("yes" diyerek onayla)

# İşlem bitince tekrar ana dizine dön
cd ../..
3. ArgoCD Kurulumu (GitOps)
Sürekli dağıtım (CD) aracı olarak ArgoCD'yi kurun:

Bash
kubectl create namespace argocd

kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.3/manifests/install.yaml
ArgoCD Admin Şifresini Öğrenme:

Bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
4. Vault Bootstrap (Otomatik Kurulum)
Terraform tarafından üretilen ve şifrelerin içine gömüldüğü dosyayı uygulayın. Bu işlem Vault'u kurar, başlatır (init/unseal) ve uygulama şifrelerini (Redis/DB) kasaya koyar.

Bash
# Terraform'un ürettiği dosyayı uygula
kubectl apply -f .github/terraform/vault-bootstrap-generated.yaml
5. Uygulamaları Başlat (App of Apps) 🚀
Tüm mikroservisleri ve yan bileşenleri (Monitoring vb.) ArgoCD üzerinden tetikleyin:

Bash
kubectl apply -f root-app.yaml
Bu komut ArgoCD'ye projeyi izlemesini söyler. ArgoCD arayüzünden uygulamanın "Sync" olduğunu görebilirsiniz.

🔒 Güvenlik: Manuel Secret Yönetimi ve Temizlik
Eğer Vault Secret'larını manuel değiştirmek, root token'ı silmek veya bakım yapmak isterseniz:

1. Yetkilendirme (RBAC):

Bash
# Role ve Binding oluştur
kubectl create role vault-secret-manager \
  --verb=get,list,watch,create,update,patch,delete \
  --resource=secrets \
  --namespace=vault

kubectl create rolebinding vault-secret-binding \
  --role=vault-secret-manager \
  --serviceaccount=vault:vault \
  --namespace=vault
2. Vault Login ve Temizlik: (Not: Önce kubectl port-forward svc/vault-active -n vault 8200:8200 yaptığınızdan emin olun)

Bash
export VAULT_ADDR='http://127.0.0.1:8200' 

# AWS IAM üzerinden Admin girişi yap
vault login -method=aws role=devops-admin 

# İşi biten yetkileri ve Root Token secret'ını sil (Güvenlik için önemli!)
kubectl delete rolebinding vault-secret-binding -n vault
kubectl delete secret vault-init-keys -n vault
🌐 Arayüzlere Erişim (Port Forwarding)
Servislere tarayıcıdan erişmek için port yönlendirmesi yapın.

ArgoCD Arayüzü: https://localhost:8080

Bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
Grafana (Monitoring): http://localhost:3000

Bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80