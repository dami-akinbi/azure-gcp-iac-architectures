# Multi-Cloud Infrastructure-as-Code Portfolio (Azure & GCP)

[![Microsoft Certified: Azure Administrator Associate](https://img.shields.io/badge/Azure-AZ--104%20Certified-0078D4?style=flat-square&logo=microsoftazure)](https://learn.microsoft.com/en-us/credentials/)
[![Google Cloud Certified: Associate Cloud Engineer](https://img.shields.io/badge/GCP-Associate%20Cloud%20Engineer-4285F4?style=flat-square&logo=googlecloud)](https://cloud.google.com/certification)
[![CI/CD: GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=flat-square&logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![IaC: Bicep & Terraform](https://img.shields.io/badge/IaC-Bicep%20%7C%20Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white)](https://www.terraform.io/)

A production-oriented, dual-cloud Infrastructure-as-Code (IaC) repository implementing **12 mirrored cloud architectures** across **Microsoft Azure (Bicep)** and **Google Cloud Platform (Terraform)**. Every workload is designed around declarative provisioning, automated GitHub Actions continuous delivery, and strict FinOps cost hygiene.

---

## Architecture & Engineering Principles

* **Dual-Cloud Architectural Parity:** Translates core cloud primitives—compute, networking, identity, databases, serverless, containers, observability, and hub-and-spoke topologies—identically across Azure and GCP.
* **Path-Filtered Continuous Delivery:** Uses dedicated GitHub Actions workflows (`.github/workflows/azure-deploy.yml` and `.github/workflows/gcp-deploy.yml`) triggered automatically on pushes to `azure/**` or `gcp/**`.
* **FinOps & Cost Governance:** Enforces ephemeral compute lifecycles, right-sized dev SKUs (`Standard_D2as_v4` / `e2-medium`), 30-day Log Analytics retention caps, and post-verification teardown routines (`az group delete` / `gcloud` cleanup) to maintain near-zero idle spend.
* **Resilient Dependency Orchestration:** Explicitly sequences peering and resource dependencies (`dependsOn` in Bicep, `depends_on` in Terraform) to prevent cloud control-plane lock conflicts.

---

## Multi-Cloud Architecture Matrix (Projects 01–12)

| # | Architecture Domain | Azure Implementation (Bicep) | GCP Implementation (Terraform) | Key Engineering Focus |
| :- | :--- | :--- | :--- | :--- |
| **01** | **Compute & Networking** | [`01-ubuntu-vm-bicep`](./azure/01-ubuntu-vm-bicep) | [`01-ubuntu-vm-terraform`](./gcp/01-ubuntu-vm-terraform) | Ubuntu LTS provisioning, VNet/VPC isolation, NSG & firewall rules |
| **02** | **Environment Parity** | [`02-parameterized-deployments-bicep`](./azure/02-parameterized-deployments-bicep) | [`02-parameterized-deployments-terraform`](./gcp/02-parameterized-deployments-terraform) | Decoupled configuration via `parameters.dev.json` and `dev.tfvars` |
| **03** | **Modular IaC** | [`03-reusable-modules-bicep`](./azure/03-reusable-modules-bicep) | [`03-reusable-modules-terraform`](./gcp/03-reusable-modules-terraform) | DRY infrastructure components with typed inputs and outputs |
| **04** | **Zero-Trust Access** | [`04-secure-bastion-iap-bicep`](./azure/04-secure-bastion-iap-bicep) | [`04-secure-bastion-iap-terraform`](./gcp/04-secure-bastion-iap-terraform) | Elimination of public SSH exposure via Azure Bastion & GCP IAP |
| **05** | **Managed Persistence** | [`05-managed-databases-bicep`](./azure/05-managed-databases-bicep) | [`05-managed-databases-terraform`](./gcp/05-managed-databases-terraform) | Managed relational instances, private connectivity, secret handling |
| **06** | **Elasticity & Traffic** | [`06-loadbalancer-autoscaling-bicep`](./azure/06-loadbalancer-autoscaling-bicep) | [`06-loadbalancer-autoscaling-terraform`](./gcp/06-loadbalancer-autoscaling-terraform) | L4/L7 Load Balancers, health probes, VMSS & Managed Instance Groups |
| **07** | **Event-Driven Compute** | [`07-serverless-functions-bicep`](./azure/07-serverless-functions-bicep) | [`07-serverless-functions-terraform`](./gcp/07-serverless-functions-terraform) | Scale-to-zero execution with Azure Functions & Cloud Functions |
| **08** | **Managed Containers** | [`08-container-deployments-bicep`](./azure/08-container-deployments-bicep) | [`08-container-deployments-terraform`](./gcp/08-container-deployments-terraform) | Serverless container runtime via Azure Container Apps & Cloud Run |
| **09** | **CI/CD Pipelines** | [`09-github-actions-cicd-bicep`](./azure/09-github-actions-cicd-bicep) | [`09-github-actions-cicd-terraform`](./gcp/09-github-actions-cicd-terraform) | Automated validation and deployment via GitHub Actions runners |
| **10** | **Managed Kubernetes** | [`10-kubernetes-cluster-bicep`](./azure/10-kubernetes-cluster-bicep) | [`10-kubernetes-cluster-terraform`](./gcp/10-kubernetes-cluster-terraform) | Production AKS & GKE clusters with isolated node pools |
| **11** | **Observability & SRE** | [`11-monitoring-alerting-bicep`](./azure/11-monitoring-alerting-bicep) | [`11-monitoring-alerting-terraform`](./gcp/11-monitoring-alerting-terraform) | Log Analytics, KQL scheduled query rules, Action Groups & Cloud Monitoring |
| **12** | **Enterprise Topology** | [`12-hub-and-spoke-network-bicep`](./azure/12-hub-and-spoke-network-bicep) | [`12-hub-and-spoke-network-terraform`](./gcp/12-hub-and-spoke-network-terraform) | Non-overlapping CIDR segmentation (`10.0/16`–`10.2/16`) & bidirectional peering |

---

## CI/CD Deployment Workflow

```text
Push to main (azure/** or gcp/**)
       │
       ├──► azure-deploy.yml ──► Azure Login (Service Principal) ──► arm-deploy@v1 (Bicep) ──► Azure Resource Group
       │
       └──► gcp-deploy.yml   ──► Google Auth (Service Account)   ──► terraform init & apply ──► GCP Project
```

### Repository Structure

```text
cloud-portfolio/
├── .github/
│   └── workflows/
│       ├── azure-deploy.yml        # Automated Bicep deployment pipeline
│       └── gcp-deploy.yml          # Automated Terraform deployment pipeline
├── azure/                          # Projects 01–12 in Azure Bicep
├── gcp/                            # Projects 01–12 in HashiCorp Terraform
└── README.md
```

---

## Production Troubleshooting & Lessons Learned

* **Regional Quota & SKU Selection (Project 10):** Resolved AKS node provisioning constraints in `eastus` by migrating default worker nodes from restricted B-series SKUs to `Standard_D2as_v4`, and handled first-time GCP API activation (`container.googleapis.com`) propagation windows.
* **KQL & Control-Plane Validation (Project 11):** Diagnosed case-sensitive Kusto Query Language (`summarize count()`) and mandatory ARM `severity` schema requirements for `Microsoft.Insights/scheduledQueryRules`.
* **Peering Concurrency & Ephemeral State (Project 12):** Sequenced bidirectional VNet/VPC peering pairs with explicit dependency blocks to prevent simultaneous network lock collisions, motivating the transition to remote Terraform state backends in Phase 2.

---

## Roadmap: Phase 2 (Applied Production Systems)

* [ ] **Remote State & OIDC Authentication:** Migrate Terraform state to versioned GCS / Azure Storage backends with state locking and keyless GitHub OIDC federation, adding `terraform plan` / `az deployment group what-if` checks on Pull Requests.
* [ ] **Real-Time Fraud Detection Pipeline (Dual-Cloud):** Event-driven anomaly scoring using Event Hubs / Pub/Sub, serverless workers, low-latency NoSQL stores, and real-time SRE alerting.
* [ ] **Customer Churn Prediction Platform (Dual-Cloud):** Automated data lake ingestion, feature pipelines, containerized ML inference endpoints, and FinOps cost-per-prediction dashboards.

---

## Author

**Damilola Akinbi** — Cloud, DevOps & FinOps Engineer  
* **Certifications:** Microsoft Certified: Azure Administrator Associate (AZ-104) | Google Cloud Certified: Associate Cloud Engineer (ACE)