#!/bin/bash
# Helm + Grafana + Prometheus automation script
# Assumes kubectl is configured and Helm is installed

set -e  # Exit immediately if a command fails
NAMESPACE="monitor"
RELEASE_NAME="grafana-prometheus"
CHART="prometheus-community/kube-prometheus-stack"

# 1️⃣ Add Prometheus Helm repo
echo "Adding Prometheus Helm repo..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# 2️⃣ Update Helm repos
echo "Updating Helm repos..."
helm repo update

# 3️⃣ Create namespace if it doesn't exist
if ! kubectl get namespace $NAMESPACE > /dev/null 2>&1; then
  echo "Creating namespace $NAMESPACE..."
  kubectl create namespace $NAMESPACE
fi

# 4️⃣ Install Grafana + Prometheus stack
echo "Installing $RELEASE_NAME in namespace $NAMESPACE..."
helm install $RELEASE_NAME $CHART -n $NAMESPACE

# 5️⃣ Wait for Grafana pods to be ready
echo "Waiting for Grafana pods to be ready..."
kubectl wait --namespace $NAMESPACE --for=condition=ready pod -l app.kubernetes.io/name=grafana --timeout=300s

# 6️⃣ Get Grafana admin password
echo "Fetching Grafana admin password..."
GRAFANA_PASSWORD=$(kubectl get secret grafana-prometheus -n monitor -o jsonpath="{.data.admin-password}" | base64 --decode)
echo "Grafana admin password: $GRAFANA_PASSWORD"

# 7️⃣ Show Grafana service URLc
echo "Grafana service info:"
kubectl get svc -n $NAMESPACE

echo "✅ Helm installation complete. Grafana is ready to use."

## After running script change from cluster ip to load balancer and access Grafana using the external IP. Use admin as username and the password printed above to log in.
# kubectl edit svc grafana-prometheus -n monitor