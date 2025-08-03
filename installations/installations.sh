#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y wget git

# Installing OpenJDK 21
sudo apt-get install -y openjdk-21-jdk
# Set JAVA_HOME environment variable
sudo sh -c echo 'export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64' >> ~/.bashrc
sudo source ~/.bashrc

# Installing Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
          https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
            https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
            /etc/apt/sources.list.d/jenkins.list > /dev/null'
sudo apt-get update -y
sudo apt-get install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Installing Docker and Trivy
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Adding Jenkins and current user to the Docker group and restarting services
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER
sudo systemctl restart docker
sudo systemctl restart jenkins
sudo chmod 777 /var/run/docker.sock

# Installing Trivy
sudo apt-get install -y gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# Deploying Sonarqube via Docker
sudo docker run -d  --name sonar -p 9000:9000 sonarqube:lts-community