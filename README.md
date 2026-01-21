# 🚀 Sock Shop Microservices Modernization on AWS EKS

![Terraform](https://img.shields.io/badge/Terraform-v1.6-purple?style=flat&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28-blue?style=flat&logo=kubernetes)
![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-orange?style=flat&logo=argo)
![GitHub Actions](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?style=flat&logo=github-actions)
![License](https://img.shields.io/badge/License-MIT-green)

## 📖 Overview
This project demonstrates a complete **Platform Engineering** implementation for the "Sock Shop" microservices application. It simulates a real-world scenario where a legacy application is modernized using **AWS EKS, GitOps, and Infrastructure as Code (IaC)** principles.

**Key Achievements:**
* **Zero-Touch Provisioning:** Infrastructure created 100% via Terraform.
* **GitOps Workflow:** Application state managed purely by Git repositories via ArgoCD.
* **Secure by Design:** No hardcoded secrets; implemented **HashiCorp Vault** for dynamic secret injection.
* **Scalability:** Automated horizontal scaling (HPA) based on CPU metrics.

---

## 🏗️ Architecture
The solution follows an Event-Driven and GitOps-based architecture.

![Architecture Diagram](./docs/architecture-diagram.png) 
*(Note: Please upload your architecture diagram to a /docs folder and link it here)*

### 🛠️ Tech Stack & Tools

| Category | Tool | Description |
| :--- | :--- | :--- |
| **Cloud Provider** | AWS | EKS, VPC, ECR, ELB |
| **IaC** | Terraform | Provisioning Network & Cluster resources |
| **CI (Integration)** | GitHub Actions | Matrix Strategy for parallel builds |
| **CD (GitOps)** | ArgoCD | Continuous Deployment & Sync |
| **Security** | HashiCorp Vault | Secret Management & Injection |
| **Monitoring** | Prometheus & Grafana | Observability stack |
| **Networking** | Cloudflare & Ingress Nginx | DNS, SSL, and CDN |
| **App** | Sock Shop (Microservices) | Polyglot microservices (Go, Java, Node.js) |

---

## 🔄 CI/CD Pipeline Details

### Continuous Integration (GitHub Actions)
Instead of linear builds, this project utilizes a **Matrix Strategy** to optimize build times.

* **Parallel Execution:** 11 microservices are built and pushed concurrently.
* **Conditional Logic:** Special handling for services with non-standard paths (e.g., `CartService`).
* **Tagging Strategy:** Images are tagged with both `latest` and `${github.sha}` for full traceability.

### Continuous Deployment (ArgoCD)
* **Pattern:** Pull-based deployment.
* **Sync Policy:** Automated sync with self-healing enabled.
* **Health Checks:** Custom health checks for critical services.

---

## 🚀 Getting Started

### Prerequisites
* AWS CLI (Configured)
* Terraform installed
* Kubectl installed
* A domain managed by Cloudflare (Optional for Ingress)



Follow these steps to deploy the entire stack from scratch.

### 1. Prerequisites & Repository Setup
First, clone the repository and configure your AWS credentials to allow GitHub Actions to push images to ECR.


---


```markdown
## ⚙️ Installation & Setup Guide

Follow these steps to deploy the entire stack from scratch.

### 1. Prerequisites & Repository Setup
First, clone the repository and configure your AWS credentials to allow GitHub Actions to push images to ECR.


git clone https://github.com/saitbutun/microservices-demo.git
cd microservices-demo

```

> **⚠️ IMPORTANT:** Before proceeding, go to your GitHub Repository Settings > Secrets and Variables > Actions. Add the following repository secrets:
> * `AWS_ACCESS_KEY_ID`
> * `AWS_SECRET_ACCESS_KEY`
> * `AWS_REGION` (e.g., eu-west-1)
> 
> 

---

### 2. Infrastructure Provisioning (Terraform)

We use Terraform to provision the AWS EKS cluster, VPC, and ECR repositories.

```bash
cd .github/terraform
terraform init
terraform apply --auto-approve

```

*Wait for the infrastructure to be fully provisioned (approx. 15-20 mins).*

---

### 3. Connect to Cluster

Update your local kubeconfig to interact with the new EKS cluster.

```bash
aws eks update-kubeconfig --region eu-west-1 --name microservices-demo-cluster

```

---

### 4. CI Pipeline Trigger (Critical Step!)

Before deploying applications with ArgoCD, the Container Registry (ECR) must be populated.

1. Go to the **Actions** tab in this repository.
2. Select the **"Build and Push to AWS ECR"** workflow.
3. Click **Run workflow**.

> 🛑 **Note:** If you skip this step, ArgoCD will fail with `ImagePullBackOff` errors because the Docker images won't exist yet.

---

### 5. Security Setup (HashiCorp Vault)

We will install Vault, initialize it, and configure Kubernetes authentication for secret injection.

**Install Vault via Helm:**

```bash
helm repo add hashicorp [https://helm.releases.hashicorp.com](https://helm.releases.hashicorp.com)
helm repo update
kubectl create ns vault
helm install vault hashicorp/vault --namespace vault

```

**Initialize & Configure Vault:**
*Access the Vault pod shell to run configuration commands:*

```bash
kubectl exec -n vault -it vault-0 -- sh

```

*Inside the pod, run the following commands:*

```bash
# 1. Initialize Vault (SAVE THE KEYS AND TOKEN!)
vault operator init
vault login <YOUR_ROOT_TOKEN>

# 2. Enable KV Secrets Engine & Add Demo Secret
vault secrets enable -path=secret kv-v2
vault kv put secret/sockshop/redis password="INITIALPASSWORD"

# 3. Enable Kubernetes Authentication
vault auth enable kubernetes

# 4. Configure Kubernetes Auth Method
vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

# 5. Define Policy for Sock Shop
vault policy write sockshop-policy - <<EOF
path "secret/data/sockshop/redis" {
  capabilities = ["read"]
}
EOF

# 6. Create Role Binding (Example for CartService)
vault write auth/kubernetes/role/sockshop-role \
  bound_service_account_names=cartservice \
  bound_service_account_namespaces=default \
  policies=sockshop-policy \
  ttl=1h

```

*Type `exit` to leave the pod.*

---

### 6. GitOps Deployment (ArgoCD)

Now we deploy ArgoCD and let it handle the application deployment.

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)

# Deploy the Application (App of Apps Pattern)
cd ~/microservices-demo/kubernetes-manifests
kubectl apply -f sock-shop-argocd.yaml

```

**Access ArgoCD UI:**

```bash
# Get Initial Admin Password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

# Port Forward to Localhost
kubectl port-forward svc/argocd-server -n argocd 8080:443

```

👉 Open [https://localhost:8080](https://www.google.com/search?q=https://localhost:8080) in your browser.

---

### 7. Observability Stack (Prometheus & Grafana)

Finally, deploy the monitoring stack to visualize metrics.

```bash
# Install Kube-Prometheus-Stack via Helm
kubectl create namespace monitoring
helm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts)
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring

# Apply Monitoring Configs via ArgoCD
kubectl apply -f kubernetes-manifests/monitoring-argocd.yaml

```

**Access Grafana:**

```bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80

```

👉 Open [http://localhost:3000](https://www.google.com/search?q=http://localhost:3000) (Default user: `admin` / password: `prom-operator`)








