# Cloud Shield: OCI DevSecOps & Kubernetes Hardening Hub 🚀🛡️

[![Terraform](https://img.shields.io/badge/Terraform-%235C4EE5.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Oracle](https://img.shields.io/badge/Oracle-F80000?style=for-the-badge&logo=oracle&logoColor=white)](https://www.oracle.com/cloud/)
[![Security](https://img.shields.io/badge/DevSecOps-🔒-green?style=for-the-badge)](#controles-de-segurança-implementados)

> **Infrastructure as Code (IaC) + Kubernetes Hardening rigoroso utilizando Terraform, K3s e a suíte nativa de ferramentas de segurança do ecossistema CNCF — rodando integralmente na Oracle Cloud Free Tier.**

---

## 📌 Visão Geral

Este projeto automatiza o provisionamento de uma infraestrutura resiliente na **Oracle Cloud (OCI)** usando Terraform, seguida pela implantação de um cluster **K3s** altamente blindado (*hardened*).

O objetivo principal é demonstrar de forma prática a convergência entre **IaC**, **DevSecOps** e **Segurança em Camadas (Defense in Depth)**, aplicando restrições que vão desde o perímetro da rede na nuvem até o runtime dos containers no cluster, mitigando riscos do [OWASP Top 10 Kubernetes](https://owasp.org/www-project-kubernetes-top-ten/).

```text
Oracle Cloud (Free Tier)

VCN + Subnet + Security List (Terraform)
└── VM Ampere A1 (24 GB RAM)
    └── K3s Cluster
        ├── namespace: dev
        ├── namespace: staging
        └── namespace: prod

Hardening
├── RBAC (least privilege)
├── Network Policies (default-deny)
├── Pod Security Standards
├── Falco (runtime detection)
└── Trivy Operator (vuln scanning)

CI/CD Pipeline: GitHub Actions ➔ Checkov (IaC Scan) ➔ Terraform Validate & Plan
```

---

## 🛠️ Stack Tecnológica

| Componente | Tecnologia | Função no Ecossistema |
| :--- | :--- | :--- |
| **Orquestração de Infra** | [Terraform](https://www.terraform.io/) | Provisionamento declarativo de redes, computação e firewalls na OCI. |
| **Orquestrador K8s** | [K3s](https://k3s.io/) | Distribuição Kubernetes leve, certificada pela CNCF, otimizada para ARM64. |
| **Provedor de Nuvem** | [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/free/) | Infraestrutura sob o modelo de gratuidade *Always Free*. |
| **Linter Estático** | [Checkov](https://www.checkov.io/) | Varredura de segurança do código-fonte IaC direto no fluxo de CI/CD. |
| **Segurança em Runtime** | [Falco](https://falco.org/) | Detecção em tempo real de comportamentos anômalos e syscalls maliciosas. |
| **Scanner Ativo** | [Trivy Operator](https://aquasecurity.github.io/trivy-operator/) | Escaneamento contínuo de CVEs nas imagens em execução dentro dos pods. |
| **Automação CI/CD** | [GitHub Actions](https://github.com/features/actions) | Automação das esteiras de linting, testes estruturais e geração de planos de execução. |
| **Aplicações de Teste** | [DVWA](https://github.com/digininja/DVWA) | *Damn Vulnerable Web Application* — Alvo para simulação e auditoria de ataques. |

---

## 📂 Estrutura do Repositório

```text
k8s-hardening-iac/
├── .github/
│   └── workflows/
│       ├── checkov.yml          # Scanner de segurança estático para IaC
│       └── terraform.yml        # Pipeline automatizada de validação (Validate/Plan)
├── terraform/
│   ├── main.tf                  # Orquestração principal do ecossistema
│   ├── variables.tf             # Definição e tipagem das variáveis globais
│   ├── outputs.tf               # Exposição de IPs e dados cruciais pós-build
│   ├── provider.tf              # Configurações do provider OCI e versões
│   └── modules/
│       ├── compute/
│       │   ├── main.tf          # Provisionamento da instância Ampere A1 (ARM64)
│       │   ├── cloud-init.sh    # Script automatizado de bootstrap e hardening do K3s
│       │   └── variable.tf
│       └── network/
│           ├── main.tf          # Configuração da Virtual Cloud Network (VCN)
│           ├── subnet.tf        # Arquitetura de sub-redes públicas/privadas
│           ├── security.tf      # Security Lists (Firewall Statefule de borda)
│           └── routing.tf       # Tabelas de rotas e Internet Gateway
└── kubernetes/
    ├── namespace/
    │   ├── dev.yaml             # Namespace com annotations de PSS (Restricted)
    │   ├── staging.yaml
    │   └── prod.yaml
    ├── rbac/
    │   ├── role.yaml            # Controle granular de acessos por verbos e recursos
    │   ├── role-binding.yaml    # Associação de identidades às regras restritas
    │   └── service-account.yaml # Identidade isolada para a execução de workloads
    ├── network-policies/
    │   ├── default-deny.yaml    # Implementação de isolamento Zero-Trust por padrão
    │   └── allow-dvwa.yaml      # Liberação cirúrgica e controlada de tráfego inbound/outbound
    └── workload/
        ├── dvwa-deployment.yaml # Workload com SecurityContext robustecido (Non-root, Read-only FS)
        ├── dvwa-service.yaml    # Exposição interna do serviço
        └── dvwa-ingress.yaml    # Gerenciamento de rotas e tráfego HTTP de entrada
```

## 🚀 Como Reproduzir o Ambiente

### 📋 Pré-requisitos

Antes de iniciar, certifique-se de possuir instalado em sua máquina local:

- Uma conta ativa na Oracle Cloud Infrastructure.
- Terraform CLI (Versão > 1.0).
- kubectl CLI devidamente configurado.
- Um par de chaves SSH criado (~/.ssh/id_rsa.pub).

### 💻 Passo a Passo da Execução

#### 1. Provisionar a Infraestrutura na OCI

Clone o repositório e inicialize as camadas de infraestrutura via Terraform:

```bash
git clone https://github.com/luskation/k8s-hardening-iac
cd k8s-hardening-iac/terraform

# Configurar variáveis de ambiente OCI
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars # Preencha com suas credenciais OCI (Tenancy, User, Fingerprint, SSH Key)

# Executar provisionamento
terraform init
terraform plan -out=tfplan.binary
terraform apply tfplan.binary
```

#### 2. Extrair e Configurar o Acesso Seguro ao Cluster

O bootstrap automatizado via cloud-init cria o arquivo de configuração. Copie-o remotamente de maneira segura:

```bash
# Obtenha o IP público gerado nos outputs do Terraform
PUBLIC_IP=$(terraform output -raw instance_public_ip)

# Copiar a configuração do kubeconfig mapeando para o host local
ssh -i ~/.ssh/id_rsa ubuntu@$PUBLIC_IP "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config-oci

# Ajustar o endpoint local de loopback para o IP público correto da VM
sed -i "s/127.0.0.1/$PUBLIC_IP/g" ~/.kube/config-oci
export KUBECONFIG=~/.kube/config-oci

# Validar conectividade
kubectl get nodes -o wide
```

#### 3. Aplicar os Manifestos de Hardening Kubernetes

A ordem de execução garante que o ecossistema herde as políticas de segurança de forma imediata:

```bash
# 1. Namespaces (Configura as regras de Pod Security Standards de forma ativa)
kubectl apply -f kubernetes/namespace/

# 2. RBAC (Configura o Princípio do Menor Privilégio)
kubectl apply -f kubernetes/rbac/

# 3. Network Policies (Fecha todo o tráfego inter-pod e externo - Zero Trust)
kubectl apply -f kubernetes/network-policies/

# 4. Workloads (Aplica a aplicação vulnerável protegida pelo isolamento do cluster)
kubectl apply -f kubernetes/workload/
```

## 🛡️ Controles de Segurança Implementados

- 🟢 RBAC — Least Privilege
  - Implementação: kubernetes/rbac/
  - A ServiceAccount vinculada à aplicação de teste possui apenas verbos de leitura (get, list, watch) estritos à coleção de pods no namespace específico dev.
  - Acesso bloqueado a componentes críticos como Secrets, ConfigMaps e APIs de gerenciamento do nó.

- 🛑 Network Policies — Isolation Mode
  - Implementação: kubernetes/network-policies/
  - Default Deny: Bloqueia nativamente 100% da comunicação Ingress/Egress no escopo de rede do namespace.
  - White-listing: O manifesto allow-dvwa.yaml abre exclusivamente a porta HTTP de entrada e as requisições de DNS ao CoreDNS interno do K3s, evitando movimentação lateral de atacantes.

- 🔒 Pod Security Standards (PSS)
  - Os namespaces são injetados com a tag rigorosa do Kubernetes Engine:

  ```yaml
  pod-security.kubernetes.io/enforce: restricted
  ```

  - Impacto direto: Impede que pods rodem como usuários root, exige que sistemas de arquivos de containers sejam montados em modo apenas leitura (readOnlyRootFilesystem: true) e proíbe escalonamento de privilégios kernel (allowPrivilegeEscalation: false).

- 🕵️ Falco — Runtime Behavioral Analysis
  - Audita syscalls (chamadas de sistema) no nível do kernel Linux subjacente.
  - Gera logs e alertas imediatos em cenários de violação do ambiente como:
    - Injeção ou spawn de binários interativos (/bin/sh, /bin/bash) dentro de pods web.
    - Leitura/escrita de diretórios cruciais como /etc, /usr/bin ou caminhos de arquivos de segredos.

- 🔍 Trivy Operator — Continuous Scanning
  - Monitoramento passivo contínuo do ciclo de vida das imagens executando no cluster.
  - Gera Custom Resource Definitions (CRDs) do tipo VulnerabilityReport de forma nativa na API do K8s, facilitando auditorias rápidas em tempo real.

## 📊 Mapeamento CIS Kubernetes Benchmark

Este laboratório foi construído visando atingir compliance estrito com os principais tópicos recomendados no guia CIS (Center for Internet Security) Kubernetes Benchmark:

| ID CIS | Requisito do Controle | Abordagem neste Projeto | Estado |
| :--- | :--- | :--- | :--- |
| 5.1.1 | Monitorar uso de RBAC e Privilégios Mínimos | kubernetes/rbac/role.yaml | Implementado |
| 5.2.1 | Restringir o uso de Containers Privilegiados | Pod Security Standards em modo restricted | Implementado |
| 5.3.2 | Garantir que Network Policies estejam ativas | default-deny.yaml cobrindo namespaces inteiros | Implementado |
| 5.4.1 | Evitar compartilhamento de Host IPC/Namespaces | Desabilitado por herança via política restrict | Implementado |
| 6.6.1 | Habilitar Auditoria e Segurança de Runtime | Monitoramento dinâmico via Falco de Kernel | Implementado |

## 👥 Autor

- **Lucas** — [@luskation](https://github.com/luskation)   
- Áreas de Foco: DevSecOps · Cloud Infrastructure (AWS/OCI) · Security Hardening · Linux Architecture
