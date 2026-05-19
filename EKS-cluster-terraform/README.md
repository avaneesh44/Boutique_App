
# EKS Demo Cluster with Terraform

This repository contains Terraform code to provision an Amazon EKS (Elastic Kubernetes Service) cluster in the `ap-northeast-1` (Tokyo) region.

---

## 🧾 Prerequisites

Before using this setup, ensure the following tools are installed:

- [Terraform (>=1.3.0)](https://www.terraform.io/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Git](https://git-scm.com/downloads)

Also, configure your AWS credentials:

```bash
aws configure
```

---

## 📂 Folder Structure

```text
.
├── main.tf                # Creates EKS Cluster and IAM roles
├── variables.tf           # Defines required input variables
├── outputs.tf             # Provides useful output values
├── provider.tf            # Terraform & AWS provider configuration
├── versions.tf            # Required Terraform and provider versions
```

---

## 🚀 How to Use

### 1. Clone the Repo

```bash
git clone https://github.com/your-username/eks-demo-cluster.git
cd eks-demo-cluster
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the Plan

```bash
terraform plan
```

### 4. Apply the Configuration

```bash
terraform apply
```

> This will take a few minutes. Type `yes` when prompted.

---

## 🔧 Connect to Your EKS Cluster

Once Terraform finishes, update your kubeconfig using:

```bash
aws eks --region ap-northeast-1 update-kubeconfig --name demo-cluster
```

Check the connection:

```bash
kubectl get nodes
```

---

## 🧩 Jenkins Integration

If Jenkins is running on the same EC2 instance:

1. Install **Kubernetes CLI** and **AWS CLI** in Jenkins.
2. Install the **Kubernetes plugin** and/or **Amazon EKS plugin** in Jenkins.
3. Set up credentials and configure Jenkins pipelines to use `kubectl` commands or Helm charts for deployments.

---

## 📤 Outputs

The `outputs.tf` file gives useful information like:

- Cluster name
- EKS endpoint
- IAM role ARN

---

## 📜 License

This project is for demo/training purposes.
