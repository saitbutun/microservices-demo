

---

# 🚀 Microservices Demo – Kurulum ve Dağıtım Rehberi

Bu proje, **Sock Shop** benzeri bir mikroservis mimarisinin **Platform Engineering** bakış açısıyla modernleştirilmiş bir örneğidir.
Altyapı **AWS EKS** üzerinde çalışır, **Terraform** ile yönetilir, **Vault** ile güvenliği sağlanır ve **ArgoCD (App of Apps)** modeli ile GitOps yaklaşımıyla dağıtılır.

> 🎯 Amaç: Legacy bir mikroservis uygulamasını, gerçek hayata yakın bir senaryo ile **cloud-native**, **güvenli** ve **otomatik** hale getirmek.

---

## 🧱 Mimari Bileşenler

* **AWS EKS** – Kubernetes kümesi
* **Terraform (IaC)** – Altyapı ve gizli anahtar üretimi
* **Vault** – Secret yönetimi ve güvenli saklama
* **ArgoCD (GitOps)** – Uygulama dağıtımı (App of Apps)
* **Monitoring Stack** – Grafana & Prometheus

---

## 📋 Ön Hazırlık

Projeyi klonladıktan sonra, **ana dizindeyken** aşağıdaki adımları **sırayla** uygulayın.

---

## 1️⃣ Kümeye Bağlan (AWS EKS)

Kubernetes konfigürasyonunu yerel makinenize çekin:

```bash
aws eks update-kubeconfig \
  --region eu-west-1 \
  --name microservices-demo-cluster
```

Bağlantıyı doğrulamak için:

```bash
kubectl get nodes
```

---

## 2️⃣ Altyapı ve Şifre Üretimi (Terraform)

Terraform dosyaları `.github/terraform` dizinindedir.
Bu adımda:

* Altyapı bileşenleri hazırlanır
* Uygulama şifreleri üretilir
* Vault bootstrap dosyası otomatik oluşturulur

```bash
# Terraform dizinine gir
cd .github/terraform

# Provider'ları indir
terraform init

# Kaynakları oluştur ve şifreleri üret
terraform apply
# ("yes" diyerek onaylayın)

# İşlem tamamlanınca ana dizine dön
cd ../..
```

> 📄 Bu adım sonunda `vault-bootstrap-generated.yaml` dosyası oluşur.

---

## 3️⃣ ArgoCD Kurulumu (GitOps)

Sürekli dağıtım (CD) için ArgoCD kurulumu:

```bash
kubectl create namespace argocd

kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.3/manifests/install.yaml
```

### 🔑 ArgoCD Admin Şifresi

```bash
kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
```

---

## 4️⃣ Vault Bootstrap (Otomatik Kurulum 🔐)

Terraform tarafından üretilen dosya ile Vault:

* Kurulur
* Init & Unseal edilir
* Redis / DB gibi uygulama secret’ları kasaya yazılır

```bash
kubectl apply -f .github/terraform/vault-bootstrap-generated.yaml
```

> ⚙️ Bu işlem **tamamen otomatiktir**, manuel Vault init gerekmez.

---

## 5️⃣ Uygulamaları Başlat (App of Apps) 🚀

Tüm mikroservisleri ve yan bileşenleri ArgoCD’ye tanıtın:

```bash
kubectl apply -f root-app.yaml
```

Bu komut:

* ArgoCD’ye **root application**’ı tanımlar
* Diğer tüm uygulamalar otomatik olarak senkronize edilir

📌 ArgoCD arayüzünden uygulamaların **Sync** ve **Healthy** olduğunu görebilirsiniz.

---

## 🔒 Güvenlik: Manuel Secret Yönetimi ve Temizlik

Bakım, manuel secret güncelleme veya root token temizliği için aşağıdaki adımlar izlenebilir.

---

### 1️⃣ Yetkilendirme (RBAC)

Vault’un Kubernetes secret’larına erişebilmesi için:

```bash
kubectl create role vault-secret-manager \
  --verb=get,list,watch,create,update,patch,delete \
  --resource=secrets \
  --namespace=vault

kubectl create rolebinding vault-secret-binding \
  --role=vault-secret-manager \
  --serviceaccount=vault:vault \
  --namespace=vault
```

---

### 2️⃣ Vault Login & Temizlik

> ⚠️ Önce port-forward yaptığınızdan emin olun:

```bash
kubectl port-forward svc/vault-active -n vault 8200:8200
```

```bash
export VAULT_ADDR="http://127.0.0.1:8200"

# AWS IAM ile Vault admin girişi
vault login -method=aws role=devops-admin
```

İşiniz bittikten sonra **güvenlik için mutlaka temizleyin**:

```bash
kubectl delete rolebinding vault-secret-binding -n vault
kubectl delete secret vault-init-keys -n vault
```

---

## 🌐 Arayüzlere Erişim (Port Forwarding)

### 🔹 ArgoCD UI

📍 [https://localhost:8080](https://localhost:8080)

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

---

### 📊 Grafana (Monitoring)

📍 [http://localhost:3000](http://localhost:3000)

```bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
```

---

## 🧠 Notlar & İpuçları

* ArgoCD **App of Apps** modeli sayesinde ölçeklenebilir bir yapı sunar
* Vault bootstrap işlemi **idempotent** çalışır
* Terraform + GitOps birlikte kullanılarak **tam otomasyon** sağlanmıştır

---

