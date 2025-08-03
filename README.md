# Build and Deploy with Github, Jenkins, Argocd, Kubernetes
This is Server information micro service developed using Python and Flask Framework which displays "**server name**" and "**ip**".
This is Implementation of an automated CI/CD pipeline for deploying containerized applications using "**GitHub, Jenkins, Docker, ArgoCD, Kubernetes**" and monitor with "**Prometheus, and Grafana**".

## Architecture
![Architecture](images/architecture.png)


The objective of this project is to automate the build and deployment pipeline with integrated monitoring using the following tools and services:
- **GitHub**: Store and manage source code repositories and trigger CI on commits.
- **Jenkins**: Build application code, run tests, build Docker images, and push to container registry.
- **SonarQube**: Analyze source code for bugs, vulnerabilities, code smells, and maintainability issues to ensure high-quality code standards.
- **Docker**: Package applications into containers for consistent deployment.
- **Trivy**: Scan Docker images and Infrastructure-as-Code (IaC) configurations for vulnerabilities and misconfigurations.
- **ArgoCD**: Automate Kubernetes deployment using GitOps principles.
- **Kubernetes**: Orchestrate containerized applications in a scalable environment.
- **Prometheus**: Collect metrics from Kubernetes workloads and nodes.
- **Grafana**: Create dashboards for observability and real-time monitoring of application and infrastructure.

## Installations & Configurations
For installations and configurations refer 
 https://github.com/AjayKumarPatnaikuni/pyserverinfo-service/tree/main/installations
