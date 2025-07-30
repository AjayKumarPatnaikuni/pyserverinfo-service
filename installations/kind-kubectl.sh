#!/bin/bash
sudo apt-get update -y

#kind installation
# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64

chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
echo "kind installation complete."

#kubectl installation
# Variables
VERSION="v1.30.0" #change the version as needed by your requirements

# Download and install kubectl
curl -LO "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Clean up
rm -f kubectl

echo "kubectl installation complete."
# Helm installation
# Download and install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh
