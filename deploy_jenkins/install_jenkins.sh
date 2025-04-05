# references: https://medium.com/@oladejit3/how-to-install-jenkins-on-aws-ec2-instance-4ec700f68948
#!/bin/bash

# Update the system
sudo yum update -y

# Install Java (Jenkins requires Java 8 or 11)
sudo yum install java-17-amazon-corretto -y

# Add Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install jenkins -y

# Start and enable Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Print access instructions
PUBLIC_IP=$(curl -s ifconfig.me)
echo "Access Jenkins at: http://${PUBLIC_IP}:8080"

# Get master password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# enable swap on amazon linux 2 enable only 1280MB
sudo dd if=/dev/zero of=/swapfile bs=128M count=10
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# verify swap
sudo swapon --show

# check disk status
free -h

# install git
sudo yum install git -y

# Install prerequisites
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

# Install Terraform
sudo yum install -y terraform

# Verify installation
terraform --version
echo "Terraform installed successfully!"
