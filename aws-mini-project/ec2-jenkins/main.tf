resource "aws_instance" "jenkins" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = var.instance_type
  key_name               = var.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "${var.project_name}-jenkins"
  }

 user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # Install Java & Jenkins
              amazon-linux-extras install java-openjdk11 -y
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              yum install jenkins -y
              systemctl enable jenkins
              systemctl start jenkins

              # Install Docker
              yum install docker -y
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ec2-user
              usermod -aG docker jenkins

              # Install kubectl
              curl -o /usr/local/bin/kubectl -LO "https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-06-14/bin/linux/amd64/kubectl"
              chmod +x /usr/local/bin/kubectl

              # Install AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install

              # Install eksctl
              curl --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
              mv /tmp/eksctl /usr/local/bin

              # Reboot to apply docker group changes
              reboot
              EOF
}

resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Allow Jenkins and port 3000"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
