# Phase-1:
## Installation & Configuration of Jenkins, Docker, Kind, Kubectl, Helm, Agocd

### Installation of Jenkins, Docker, Trivy

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
Ref: https://kind.sigs.k8s.io/docs/user/quick-start/#installation
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
Ref: https://kubernetes.io/docs/tasks/tools/

  **Note**: If you want to install as a script create a file with name "**kind-kubectl.sh**" and copy from "**kind-kubectl.sh**", save and exit.
  provide the executable peramissions and run the script
  ```
  sudo chmod +x kind-kubectl.sh
  ./kind-kubectl.sh
  ```

### Provisioning kubernetes cluster with kind
- Create a configuration file **config.yml** to create multi-node cluster and paste the below configuration.
  ```
  kind: Cluster
  apiVersion: kind.x-k8s.io/v1alpha4
  nodes:
  - role: control-plane
    image: kindest/node:v1.30.0 # Ensure this matches the kubectl version
  - role: worker
    image: kindest/node:v1.30.0 # Ensure this matches the kubectl version
  - role: worker
    image: kindest/node:v1.30.0 # Ensure this matches the kubectl version
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

### Installation of ArgoCD
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
- To access argocd server, we need to expose its port.
  ```
  kubectl port-forward -n argocd service/argocd-server 8090:443 --address=0.0.0.0 &
  ```
- Access the argocd server from browser, username is "**admin**, and get password by execute below command.
  ```
  kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
  ```
  Note: Default user is “**admin**”

### Configuration of Application in Argocd
- Navigate to Argocd dashboard, click on **Applications**, and then click on **NEW APP**.
- Provide application details as follows:
  - **Application name**: pyserverinfoservice   **# replace with your application name**
  - **Project name**: default
  - **Sync policy**: automatic
  - **Repository URL**: https://github.com/AjayKumarPatnaikuni/pyserverinfo-service.git    **#replace with your github URL**
  - **Revision**: main   **#mention your branch name**
  - **Path**: kubernetes/    **# replace with your kubernetes manifest path in github url**
  - **ClusterURL**: https://kubernetes.default.svc
  - **Namespace**: default
 Click on create.

# Phase-2
##  Monitor Jenkins, ArgoCD with Prometheus and Grafana
- Create prometheus container.
  ```
  docker run --name prometheus -d -p 127.0.0.1:9090:9090 prom/prometheus
  ```
- Access the prometheus in browser by **serverip:9090**. #replace **serverip** with your ip.
Ref: https://hub.docker.com/r/prom/prometheus
- Create grafana container.
  ```
  docker run -d --name=grafana -p 3000:3000 grafana/grafana
  ```
- Access the grafana in browser by **serverip:3000**. #replace **serverip** with your ip.
- Default login credentials to access grafana are **admin/admin**. Once loggedin reset the password.
Ref: https://hub.docker.com/r/grafana/grafana

### Add Prometheus as Datasource in Grafana
- Go to grafana UI --> Datasource --> Add Datasource --> select "prometheus"
- Under "**connection**" section provide **prometheus url**, click on **save & test**.

### Configuration & Visualization  of Jenkins metrics  in Prometheus & Grafana
- Navigate to Jenkins UI --> Manage Jenkins --> plugins
- Search for **Prometheus metrics plugin**, install and then restart the jenkins. 
- Go to Jenkins UI --> Manage Jenkins --> System --> Prometheus, and make sure that below configurations existed.
    - Path: “/prometheus”
    - Default Namepace: “default”
    - Collecting metrics period: “120” # I changed this metrics to 10 for testing.
  Click on apply and save.
- Validate the Jenkins metrics end point, by browsing the “Jenkins ip:8080/Prometheus”.
