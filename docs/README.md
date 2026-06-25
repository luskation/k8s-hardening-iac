> Infrastructure as Code + Kubernetes hardening usando Terraform, K3s e ferramentas de segurança nativas — rodando na Oracle Cloud Free Tier.

---

## Visão Geral

Este projeto provisiona automaticamente uma VM na Oracle Cloud via Terraform e sobe um cluster Kubernetes leve (K3s) com controles de segurança robustos aplicados. O objetivo é demonstrar habilidades práticas em **IaC**, **DevSecOps** e **segurança de containers** num ambiente real e reproduzível.

```
┌─────────────────────────────────────────────────────────┐
│                   Oracle Cloud (Free Tier)               │
│                                                         │
│   ┌─────────────────────────────────────────────────┐   │
│   │  VCN + Subnet + Security List (Terraform)       │   │
│   │                                                 │   │
│   │   ┌───────────────────────────────────────┐     │   │
│   │   │  VM Ampere A1 (24 GB RAM)             │     │   │
│   │   │                                       │     │   │
│   │   │   K3s Cluster                         │     │   │
│   │   │   ├── namespace: dev                  │     │   │
│   │   │   ├── namespace: staging              │     │   │
│   │   │   └── namespace: prod                 │     │   │
│   │   │                                       │     │   │
│   │   │   Hardening                           │     │   │
│   │   │   ├── RBAC (least privilege)          │     │   │
│   │   │   ├── Network Policies (default-deny) │     │   │
│   │   │   ├── Pod Security Standards          │     │   │
│   │   │   ├── Falco (runtime detection)       │     │   │
│   │   │   └── Trivy Operator (vuln scanning)  │     │   │
│   │   └───────────────────────────────────────┘     │   │
│   └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

CI/CD: GitHub Actions → Checkov + Terraform validate/plan
```

---

## Stack

| Ferramenta | Função |
|---|---|
| **Terraform** | Provisiona VM, rede e firewall na OCI |
| **K3s** | Cluster Kubernetes leve (CNCF certified) |
| **Oracle Cloud Free Tier** | Infraestrutura permanente e sem custo |
| **Checkov** | Scan de segurança no código IaC (CI/CD) |
| **Falco** | Detecção de comportamento anômalo em runtime |
| **Trivy Operator** | Escaneamento contínuo de vulnerabilidades nos containers |
| **GitHub Actions** | Pipeline de validação e deploy automatizado |
| **DVWA** | Workload-alvo para testes de segurança |

---

## Estrutura do Repositório

```
k8s-hardening-iac/
├── .github/
│   └── workflows/
│       ├── checkov.yml          # Scan de segurança no IaC
│       └── terraform.yml        # Validate + Plan automático
├── terraform/
│   ├── main.tf                  # Entry point
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── modules/
│       ├── compute/
│       │   ├── main.tf          # VM Ampere A1
│       │   ├── cloud-init.sh    # Instalação automática do K3s
│       │   └── variable.tf
│       └── network/
│           ├── main.tf          # VCN
│           ├── subnet.tf
│           ├── security.tf      # Security Lists (firewall)
│           └── routing.tf
└── kubernetes/
    ├── namespace/
    │   ├── dev.yaml
    │   ├── staging.yaml
    │   └── prod.yaml
    ├── rbac/
    │   ├── role.yaml            # Permissões mínimas por namespace
    │   ├── role-binding.yaml
    │   └── service-account.yaml
    ├── network-policies/
    │   ├── default-deny.yaml    # Nega todo tráfego por padrão
    │   └── allow-dvwa.yaml      # Libera apenas o necessário
    └── workload/
        ├── dvwa-deployment.yaml
        ├── dvwa-service.yaml
        └── dvwa-ingress.yaml
```

---

## Como Reproduzir

### Pré-requisitos

- Conta na [Oracle Cloud](https://www.oracle.com/cloud/free/) com chave SSH configurada
- Terraform >= 1.0
- `kubectl` instalado localmente

### 1. Provisionar a infraestrutura

```bash
git clone https://github.com/luskation/k8s-hardening-iac
cd k8s-hardening-iac/terraform

# Configure suas variáveis
cp terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars com seus dados da OCI

terraform init
terraform plan
terraform apply
```

### 2. Acessar o cluster

```bash
# O kubeconfig é exportado automaticamente pelo cloud-init
ssh ubuntu@<PUBLIC_IP> "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config
sed -i 's/127.0.0.1/<PUBLIC_IP>/g' ~/.kube/config

kubectl get nodes
```

### 3. Aplicar os manifestos de hardening

```bash
# Namespaces
kubectl apply -f kubernetes/namespace/

# RBAC
kubectl apply -f kubernetes/rbac/

# Network Policies
kubectl apply -f kubernetes/network-policies/

# Workload (DVWA)
kubectl apply -f kubernetes/workload/
```

---

## Controles de Segurança Implementados

### RBAC — Least Privilege

Service account dedicada para o DVWA com `Role` limitada a `get`, `list` e `watch` em `pods` e `services` no namespace `dev`. Sem acesso a `secrets`, `configmaps` ou outros namespaces.

### Network Policies — Default Deny

Todo tráfego de Ingress e Egress é negado por padrão no namespace `dev`. Apenas o tráfego explicitamente permitido via `allow-dvwa.yaml` é liberado.

### Pod Security Standards

Namespaces configurados com PSS no modo `restricted`: containers sem root, filesystem read-only, sem privilege escalation.

### Falco — Runtime Security

Detecta comportamentos anômalos em tempo de execução: execução de shells inesperados, acesso a arquivos sensíveis, tentativas de escalonamento de privilégios.

### Trivy Operator — Vulnerability Scanning

Escaneia imagens continuamente e gera relatórios de vulnerabilidades (`VulnerabilityReport`) diretamente como recursos Kubernetes.

### Checkov — IaC Security (CI/CD)

Pipeline no GitHub Actions que executa `checkov` em todos os arquivos Terraform e YAMLs. Falha em severidade HIGH/CRITICAL.

---

## CI/CD

```
Push → GitHub Actions
         ├── checkov.yml  → Checkov scan (IaC + K8s YAMLs)
         └── terraform.yml → terraform init + validate + plan
```

---

## Mapeamento CIS Kubernetes Benchmark

| Controle CIS | Implementação |
|---|---|
| 5.1 — RBAC | `kubernetes/rbac/` |
| 5.2 — Pod Security | PSS `restricted` nos namespaces |
| 5.3 — Network Policies | `kubernetes/network-policies/` |
| 5.4 — Secrets | Secrets criptografados no etcd |
| 6.6 — Runtime Security | Falco |

---

## Autor

**Lucas** — [@luskation](https://github.com/luskation)   
Áreas: DevSecOps · Cloud · Kubernetes · IaC
