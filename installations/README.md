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
### Installation of Helm
- Install the helm by executing below commands
  ```
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  sudo chmod 700 get_helm.sh
  sudo ./get_helm.sh
  ```
Ref: https://helm.sh/docs/intro/install/


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
- Now verify the objects created by argocd, and expose pyserverinfo-svc to access in browser.
  ```
  kubectl get svc
  kubectl port-forward svc/pyserverinfo-svc 30231:30231 --address=0.0.0.0 &
  ```

# Phase-2
##  Monitor Jenkins, ArgoCD with Prometheus and Grafana
### Deployment of Prometheus via helm
- Create namespace **monitoring**.
  ```
  kubectl create namespace monitoring
  ```
- Add, Update, and istall the **prometheus** via helm chart.
  ```
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  helm install prometheus prometheus-community/prometheus -n monitoring
  ```
- Verify the **prometheus services** in monitoring namespace.
  ```
  kubectl get svc -n monitoring
  ```
- Now expose the Prometheus-server service from clusterIP to Nodeport. Find the "**ClusterIp**" in "**prometheus-server**" service and replace it with "**NodePort**".
  ```
  kubectl edit svc/prometheus-server -n monitoring
  ```
- Now expose and forward the **prometheus-server** service port to 9090 to access it on browser.
  ```
  kubectl port-forward svc/prometheus-server -n monitoring 9090:80 --address=0.0.0.0 &
  ```
  access the prometheus server in browser by "public i.p of instance:9090"

### Provisioning Grafana
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

### Configuration of Jenkins, argocd metrics  in Prometheus
- Navigate to Jenkins UI --> Manage Jenkins --> plugins
- Search for **Prometheus metrics plugin**, install and then restart the jenkins. 
- Go to Jenkins UI --> Manage Jenkins --> System --> Prometheus, and make sure that below configurations existed.
    - Path: “/prometheus”
    - Default Namepace: “default”
    - Collecting metrics period: “120” # I changed this metrics to 10 for testing.
  Click on apply and save.
- Validate the Jenkins metrics end point, by browsing the “Jenkins ip:8080/Prometheus”.
- Verify the Prometheus-server configmap add the Jenkins server as target in scrape_configs section.
  ```
  kubectl get cm -n monitoring
  ```
- Add the below configuration for  Jenkins server as target under scrape_configs section.
  ```
  - job_name: 'argocd'
    static_configs:
      - targets:
          - 'argocd-metrics.argocd.svc.cluster.local:8082'                 
          - 'argocd-repo-server.argocd.svc.cluster.local:8084'                  
          - 'argocd-server-metrics.argocd.svc.cluster.local:8083'              
          - 'argocd-notifications-controller-metrics.argocd.svc.cluster.local:9001'
		  
  - job_name: 'jenkins'
    metrics_path: '/prometheus/'
    static_configs:
      - targets: ['15.206.153.19:8080']  #Replace with your jenkins server url
  ```
 Identify the Prometheus server pod name and delete it and wait for it to restart.
  ```
  kubectl get pods –n monitoring
  kubectl delete pod prometheus-server-646498f746-2vgq5 -n monitoring  #replace it with your pod name
  ```
- Once pod restarts,  port forward and expose port 9090 to access it on browser.
  ```
  kubectl port-forward svc/prometheus-server -n monitoring 9090:80 --address=0.0.0.0 &
  ```
- Verify  jenkins, argocd endpoints were added to the prometheus targets by browsing "Prometheus server ip:9090/targets"
- Now validate jenkins, argocd endpoints to the targets, by **prometheusserverip:9090/tagets**. # Replace with your prometheus server ip.

### Visualization  of Jenkins, argocd metrics  in Grafana
**Jenkins**
- Go to GrafanaUI --> Dashboards --> select **import** option from the drop down list on **new**.
- Enter “**9964**” as id and click on **load**.
- Select "**prometheus**" as datasource and click on **import**.
- Now Go to dashboards, click on jenins dashboard and verify the jenkins metrics such as jobs, executors, etc. from dashboard panels.
**Argocd**
-  Go to GrafanaUI --> Dashboards --> select **import** option from the drop down list on **new**.
- Enter “**14584**” as id and click on **load**, and then click on **import**.
- Go to dashboards, click on argocd dashboard and verify the argocd metrics such as cluster, application etc.

**Note**: If there any issue with **prometheus-server** after restarting, kindly check the indentations in **prometheus-server configmap** and modify accordingly.
