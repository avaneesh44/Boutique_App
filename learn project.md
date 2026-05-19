# Learn Project: Boutique_App Deep Dive

## 1. Project Overview

This repository is a cloud-native **e-commerce microservices platform** based on the Online Boutique reference architecture, adapted in this fork for **AWS EKS deployment**, **ECR image hosting**, **Jenkins CI/CD**, and **Prometheus/Grafana monitoring**.

At a high level, the project demonstrates how to:
- Build multiple independent services in different languages
- Connect them through gRPC APIs using Protocol Buffers
- Containerize and deploy them on Kubernetes (EKS)
- Automate infra setup with Terraform
- Add observability and pipeline automation for real-world operations

---

## 2. How the Project Is Set Up (Structure and Starting Point)

## 2.1 Root-Level Structure

From the repository root:
- `EKS-cluster-terraform/`
  - Terraform code for provisioning EKS and related AWS infra
- `Microservices/`
  - Application source code, deployment manifests, proto contracts, build scripts
- `README.md`
  - Main project walkthrough for manual deployment
- `Jenkinsfile`
  - CI/CD pipeline script for Jenkins-based automation
- `Monitor.sh`
  - Monitoring setup (Prometheus/Grafana via Helm)
- `Outputs/`
  - Screenshots of expected outputs (frontend, Jenkins, Grafana)

This is important in meetings because it shows clear separation between:
- Infrastructure provisioning (`EKS-cluster-terraform`)
- Application and deployment logic (`Microservices`)
- Operations automation (`Jenkinsfile`, `Monitor.sh`)

## 2.2 Service Contract First: The Proto Model

The core communication model is defined in:
- `Microservices/protos/demo.proto`

This file is the **API contract** between services. It defines:
- Services: `CartService`, `CheckoutService`, `ProductCatalogService`, `PaymentService`, etc.
- RPC methods: e.g., `AddItem`, `PlaceOrder`, `GetQuote`, `Charge`
- Message schemas: `CartItem`, `Money`, `Address`, `OrderResult`, etc.

### Why this matters
This project follows a contract-driven approach:
1. Define service interfaces in `.proto`
2. Generate language-specific stubs (`genproto`) for each service
3. Implement service logic in each service’s native language

So when explaining "how model/setup is done," describe this as the **service communication model** (gRPC + protobuf), not a single monolithic code model.

## 2.3 Microservices Layout

Inside `Microservices/src/`, each service is isolated in its own folder. Example services:
- `frontend` (Go) - web UI and aggregation layer
- `checkoutservice` (Go) - orchestrates order flow across other services
- `productcatalogservice` (Go) - product retrieval/search
- `cartservice` (C#) - cart state management
- `paymentservice` (Node.js) - payment simulation
- `currencyservice` (Node.js) - currency conversion
- `emailservice` (Python) - order confirmation
- `recommendationservice` (Python) - product recommendations
- `shippingservice` (Go) - shipping quote/tracking simulation
- `adservice` (Java) - contextual ads
- `shoppingassistantservice` (Python) - AI assistant integration (optional/advanced)

This is a **polyglot microservices** architecture, intentionally designed to show cross-language interoperability via protobuf/gRPC.

## 2.4 Runtime Interaction Pattern

Typical runtime flow:
1. User accesses `frontend` service from browser
2. `frontend` calls backend services over gRPC
3. `checkoutservice` coordinates cart -> shipping -> payment -> email during order placement
4. Each service stays independently deployable/scalable in Kubernetes

In code terms:
- `frontend/rpc.go` has gRPC client calls to downstream services
- `checkoutservice/main.go` wires multiple service addresses via env vars and invokes them

## 2.5 Deployment and Packaging Model

The project supports multiple deployment styles:
- Kubernetes manifests: `Microservices/kubernetes-manifests/`
- Kustomize variations: `Microservices/kustomize/`
- Helm chart: `Microservices/helm-chart/`
- Skaffold dev flow: `Microservices/skaffold.yaml`

In your AWS execution path, you are mainly using:
- ECR image build/push scripts
- Direct `kubectl apply -f kubernetes-manifests/`

## 2.6 Infrastructure Model

`EKS-cluster-terraform/` provisions cluster resources in AWS (region shown in docs: `ap-northeast-1`).

This means infrastructure is reproducible and version-controlled (Infrastructure as Code).

---

## 3. Purpose of This Project

## 3.1 Technical Purpose

This project is used to demonstrate end-to-end cloud-native practices:
- Microservices decomposition
- gRPC-based service communication
- Containerization and image lifecycle
- Kubernetes orchestration
- Cloud infrastructure automation
- Monitoring and operational visibility
- CI/CD pipeline integration

## 3.2 Business/Demo Purpose

It simulates an online retail application so teams can discuss and test:
- User journey (browse -> cart -> checkout)
- Service dependencies and fault boundaries
- Deployment and release strategies
- Operational readiness (dashboards, health checks, observability)

## 3.3 Team Onboarding Purpose

For new engineers, this repo is useful for learning:
- How microservices are split by responsibility
- How contracts (`demo.proto`) unify teams across languages
- How infra and app lifecycle are connected from code to production

---

## 4. Detailed Run Guide (How to Run on Your System)

## 4.1 Prerequisites

You need:
- AWS account and IAM permissions
- AWS CLI configured (`aws configure`)
- Terraform
- Docker
- kubectl
- Helm

Recommended checks:
```bash
aws sts get-caller-identity
terraform version
docker --version
kubectl version --client
helm version
```

## 4.2 Step 1: Provision EKS Infrastructure

```bash
cd EKS-cluster-terraform
terraform init
terraform plan
terraform apply
```

Notes:
- `apply` may take several minutes.
- Review outputs after apply completes.

## 4.3 Step 2: Configure kubectl for EKS

```bash
aws eks --region ap-northeast-1 update-kubeconfig --name demo-cluster
kubectl get nodes
```

Expected: nodes should appear in `Ready` state.

## 4.4 Step 3: Build and Push Microservice Images to ECR

```bash
cd ../Microservices
chmod +x docker_image_buid_push.sh
./docker_image_buid_push.sh
```

What this script typically does:
- Logs into ECR
- Detects services by scanning `src/*/Dockerfile`
- Ensures repos exist in ECR
- Builds all images with tags
- Pushes images to ECR

## 4.5 Step 4: Deploy Microservices to Kubernetes

```bash
kubectl apply -f kubernetes-manifests/
kubectl get pods
kubectl get svc
```

Validation checklist:
- All major service pods should become `Running`
- `frontend-external` service should get external endpoint

## 4.6 Step 5: Access the Application

```bash
kubectl get svc frontend-external
```

Open:
- `http://<EXTERNAL-IP>`

You should see the storefront UI.

## 4.7 Step 6: Enable Monitoring

From project root:
```bash
cd ..
chmod +x Monitor.sh
./Monitor.sh
```

Then check Grafana service and credentials as needed:
```bash
kubectl get svc -n monitor
kubectl get secret prometheus-grafana -n monitor -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

## 4.8 Optional: CI/CD with Jenkins

Use `Jenkinsfile` pipeline stages to automate:
- Build and push
- Kubernetes deployment
- Cleanup steps

---

## 5. Important Clarifications for Meetings

## 5.1 "Model setup" clarification

If someone asks "where the model is setup":
- Core project model = **microservice interaction model** via protobuf/gRPC (`demo.proto`)
- Not a single ML training/inference model
- Each service implements part of the business flow behind that contract

## 5.2 Advanced AI component exists (optional)

`shoppingassistantservice` includes GenAI + vector retrieval logic (Gemini + AlloyDB vector store). This is an extension service and not required for the base e-commerce deployment path.

## 5.3 Manifest usage note

`Microservices/kubernetes-manifests/README.md` mentions manifests are generally paired with Skaffold image-tag injection in upstream workflows. In this repository flow, this is addressed by building/pushing your own images first and then applying manifests.

---

## 6. End-to-End Architecture Summary (One-Minute Version)

Use this in meetings:

"This project is a polyglot microservices e-commerce app. Service APIs are standardized through `demo.proto` using gRPC, and each business capability (cart, checkout, payment, shipping, catalog, etc.) is implemented as an independent service. Infrastructure is provisioned on AWS EKS through Terraform. Services are containerized with Docker, pushed to ECR, and deployed to Kubernetes using manifests. The frontend is the public entrypoint, while backend services communicate internally over gRPC. Operationally, Jenkins can automate delivery, and Prometheus/Grafana provide monitoring and dashboards." 

---

## 7. Quick Troubleshooting Checklist

- EKS not reachable:
  - Re-run `aws eks update-kubeconfig`
  - Verify AWS profile/region
- Pods pending/crashing:
  - `kubectl describe pod <pod-name>`
  - `kubectl logs <pod-name>`
- No external URL:
  - Check `frontend-external` service type and cloud load balancer provisioning
- Image pull errors:
  - Confirm images pushed to correct ECR repo/tag
  - Validate node IAM/ECR pull permissions
- Grafana unavailable:
  - Check namespace/service names in `monitor` namespace

---

## 8. Files to Reference During Knowledge Transfer

- Root project guide: `README.md`
- EKS infra guide: `EKS-cluster-terraform/README.md`
- Service contract: `Microservices/protos/demo.proto`
- Deployment manifests: `Microservices/kubernetes-manifests/`
- Build/push automation: `Microservices/docker_image_buid_push.sh`
- Monitoring automation: `Monitor.sh`
- Pipeline: `Jenkinsfile`
- Frontend gRPC calls: `Microservices/src/frontend/rpc.go`
- Checkout orchestration logic: `Microservices/src/checkoutservice/main.go`

