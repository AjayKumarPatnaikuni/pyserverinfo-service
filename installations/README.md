# Installation & Configuration
### Installation of Jenkins, Docker, Ansible, Trivy

- Create a file with name "**jenkins.sh**" and copy the code from "**jenkins.sh**", save and exit.
- Provide the executable permissions to "**jenkins.sh**"
  ```
  sudo chmod +x jenkins.sh
  ./jenkins.sh
  ```
- Now verify the installed packages are running or not
  ```
  sudo docker --version
  systemctl status docker
  systemctl status jenkins
  ```
### Installation of kind
- Install the kind by executing below commands.
  ```
   #kind installation
   # For AMD64 / x86_64
   [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64

   chmod +x ./kind
   sudo mv ./kind /usr/local/bin/kind
   echo "kind installation complete."
  ```
- Verify the kind version
  ```
  kind --version
  ```
  ref: https://kind.sigs.k8s.io/docs/user/quick-start/#installation
### Installation of kubectl
- Install the kubectl by executing below commands
  ```
  VERSION="v1.30.0"
  # Download and install kubectl
  curl -LO "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  kubectl version --client
  ```
  ref: https://kubernetes.io/docs/tasks/tools/

### Installation of Helm
- Install the helm by executing below commands
  ```
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  sudo chmod 700 get_helm.sh
  sudo ./get_helm.sh
  ```
  ref: https://helm.sh/docs/intro/install/

  **Note**: If you want to install as a script create a file with name "**kind-kubectl.sh**" and copy from "**kind-kubectl.sh**", save and exit.
  provide the executable peramissions and run the script
  ```
  sudo chmod +x kind-kubectl.sh
  ./kind-kubectl.sh
  ```

### Provisioning kubernetes cluster with kind
- Create a configuration file **config.yml** to create multimode cluster and paste the below configuration.
  ```
  kind: Cluster
  apiVersion: kind.x-k8s.io/v1alpha4
  nodes:
  - role: control-plane
    image: kindest/node:v1.30.0
  - role: worker
    image: kindest/node:v1.30.0
  - role: worker
    image: kindest/node:v1.30.0
  ```
- Create cluster with name “webapp” by executing below command.
  ```
  sudo kind create cluster --name webapp --config=config.yml
  ```
- Now verify the cluster information
  ```
  kubectl cluster-info --context kind-webapp
  kubectl get nodes
  ```
Ref: https://kind.sigs.k8s.io/docs/user/configuration/

### Installation of ArgoCD with Helm
- Create a new **namespace** with name “**argocd**” in cluster.
  ```
  kubectl create namespace argocd
  ```
- Deploy the ArgoCD application using manifest files.
  ```
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```
- Now verify the services created in argocd namespace.
  ```
  kubectl get svc -n argocd
  ```
- Now expose the argocd-server from clusterIP to Nodeport by editing the argocd-server service. Find service type "**clusterIP**" and replace it with "**NodePort**".
  ```
  kubectl edit svc argocd-server -n argocd
  ```
- To access argocd server, we need to do port forwarding.
  ```
  kubectl port-forward -n argocd service/argocd-server 8090:443 --address=0.0.0.0 &
  ```
- Access the argocd server from browser, username is "**admin**, and get password by execute below command.
  ```
  kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
  ```
  Note: Default user is “**admin**”
### Configuration of Application in Argocd
- Navigate to Argocd dashboard, click on applications, and then click on new app.
- Provide application details as follows:
  **Application name**: pyserverinfo service # replace with your application name
  **Project name**: default
  **Sync policy**: automatic
  **Repository URL**: https://github.com/AjayKumarPatnaikuni/pyserverinfo-service.git  #replace with your github URL
  **Revision**: main #mention your branch name
  **Path**: kubernetes/  # replace with your kubernetes manifest path in github url
  **ClusterURL**: https://kubernetes.default.svc
  **Namespace**: default
 Click on create.

