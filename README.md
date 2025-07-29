🧠 Trend App Deployment (React JS + Jenkins + AWS EKS + Monitoring)
This project demonstrates the CI/CD deployment of a React JS application using Jenkins, Docker, and Kubernetes (EKS), with monitoring integrated via Prometheus and Grafana.

1.1 git clone the repo

1.2. Launch 1 VM (Ubuntu, 24.04, t2.large, 28 GB, Name: Ingress-Server)

Open below ports for the Security Group attached to the above VM
Type                  Protocol   Port range
SMTP                  TCP           25
(Used for sending emails between mail servers)

Custom TCP        TCP		3000-10000
(Used by various applications, such as Node.js (3000), Grafana (3000), Jenkins (8080), and custom web applications.

HTTP                   TCP           80
Allows unencrypted web traffic. Used by web servers (e.g., Apache, Nginx) to serve websites over HTTP.

HTTPS                 TCP           443
Allows secure web traffic using SSL/TLS.

SSH                      TCP           22
Secure Shell (SSH) for remote server access.

Custom TCP         TCP           6443
Kubernetes API server port. Used for communication between kubectl, worker nodes, and the Kubernetes control plane.

SMTPS                 TCP           465
Secure Mail Transfer Protocol over SSL/TLS. Used for sending emails securely via SMTP with encryption.

Custom TCP         TCP           30000-32767
Kubernetes NodePort service range.

===============
Step 2: Tools Installation
===============
2.1.1 Connect to the Ingress Server
vi Jenkins.sh ----> Paste the below content ---->

#!/bin/bash
# Update system
sudo apt update -y
# Install dependencies
sudo apt install -y fontconfig openjdk-17-jre-headless wget gnupg2
# Download and add the Jenkins GPG key
wget -O- https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \\
    gpg --dearmor | sudo tee /usr/share/keyrings/jenkins-keyring.gpg > /dev/null
# Add Jenkins repository
echo "deb \[signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | \\
    sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
# Update package lists
sudo apt update -y
# Install Jenkins
sudo apt install jenkins -y
# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
# Print status
sudo systemctl status jenkins

----> esc ----> :wq ----> sudo chmod +x jenkins.sh ----> ./jenkins.sh

Open Port 8080 in Jenkins server
Access Jenkins and setup Jenkins


2.1.2 Install Docker
vi docker.sh ----> Paste the below content ---->
#!/bin/bash
# Update package manager repositories
sudo apt-get update
# Install necessary dependencies
sudo apt-get install -y ca-certificates curl
# Create directory for Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
# Download Docker's GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# Ensure proper permissions for the key
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add Docker repository to Apt sources
echo "deb \[arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \\
$(. /etc/os-release \&\& echo "$VERSION\_CODENAME") stable" | \\
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Update package manager repositories
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

----> esc ----> :wq ----> sudo chmod +x docker.sh ----> ./docker.sh

docker --version

===================
Step 3: Access Jenkins Dashboard
===================
Setup the Jenkins

3.1. Plugins installation
Install below plugins;
Docker, Docker Commons, Docker Pipeline, Docker API, docker-build-step, AWS Credentials, Pipeline stage view, Kubernetes, Kubernetes CLI, Kubernetes Client API, Kubernetes Credentials, Config File Provider, Prometheus metrics

3.2. Creation of Credentials
Configure Dockerhub Credentials as "dockerhub-creds"
Configure AWS Credentials (Access and Secret Access Keys) as "aws-creds"

3.3. Tools Configuration

====================
Step 4: Creation of EKS Cluster
===================
4.1. Creation of IAM user (To create EKS Cluster, its not recommended to create using Root Account)

4.2. Attach policies to the user
AmazonEC2FullAccess, AmazonEKS\_CNI\_Policy, AmazonEKSClusterPolicy, AmazonEKSWorkerNodePolicy, AWSCloudFormationFullAccess, IAMFullAccess

Attach the below inline policy also for the same user

{
  "Version": "2012-10-17",
  "Statement": \[
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "eks:\*",
      "Resource": "\*"
    }
  ]
}

4.3. Create Access Keys for the user created

With this we have created the IAM User with appropriate permissions to create the EKS Cluster

4.4. Install AWS CLI (to interact with AWS Account)
sudo apt update
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86\_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install

Configure aws by executing below command
aws configure

4.5. Install KubeCTL (to interact with K8S)
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --short --client

4.6. Install EKS CTL (used to create EKS Cluster)
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl\_$(uname -s)\_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

4.7. Create EKS Cluster
eksctl create cluster --name trend --region us-east-1 --node-type t2.medium --zones us-east-1a,us-east-1b

4.8. Modifying the permissions
sudo usermod -aG docker jenkins
sudo systemctl restart docker
sudo systemctl restart jenkins

==================== Step 5: jenkins files config
5. CI/CD with Jenkins
Jenkins is configured with GitHub Webhook.
Jenkins Pipeline pulls code from GitHub, builds Docker image, pushes to ECR, and deploys to EKS using kubectl.
Jenkinsfile Sample (placed in web-branch)

    Uses dockerhub-creds for image push
    Uses aws-creds to authenticate with EKS cluster

==================== Step 6: Monitoring Setup
Prometheus & Grafana
Installed Prometheus and Grafana on cluster
Connected to EKS using Kubernetes service discovery
Node Exporter
Installed node-exporter on two worker nodes
Monitored system metrics on Grafana dashboard
