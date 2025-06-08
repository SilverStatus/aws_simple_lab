#!/bin/bash

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root or with sudo"
  exit 1
fi

# Function to check if command executed successfully
check_command() {
  if [ $? -ne 0 ]; then
    echo "Error: $1 failed"
    exit 1
  fi
}

# Update system packages
echo "Updating system packages..."
apt-get update -y && apt-get upgrade -y
check_command "System package update"

# Install GitLab Runner
echo "Installing GitLab Runner..."
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash
check_command "GitLab Runner repository setup"

apt-get install gitlab-runner -y
check_command "GitLab Runner installation"

# Install Docker dependencies
echo "Installing Docker dependencies..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
check_command "Docker dependencies installation"

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
check_command "Docker GPG key installation"

# Set up the stable repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
check_command "Docker repository setup"

# Install Docker Engine
echo "Installing Docker..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io
check_command "Docker installation"

# Enable and start Docker
systemctl enable docker
systemctl start docker
check_command "Docker service startup"

# Install AWS CLI
echo "Installing AWS CLI..."
apt-get install -y unzip
check_command "unzip installation"

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
check_command "AWS CLI download"

unzip awscliv2.zip
check_command "AWS CLI unzip"

./aws/install
check_command "AWS CLI installation"

# Clean up AWS CLI installer
rm -rf awscliv2.zip aws
check_command "AWS CLI cleanup"

# Add gitlab-runner to docker group
echo "Adding gitlab-runner to docker group..."
usermod -aG docker gitlab-runner
check_command "Adding user to docker group"

# Test docker access
echo "Testing docker access for gitlab-runner..."
sudo -u gitlab-runner docker ps
#check_command "Docker access test"

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
check_command "kubectl download"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
check_command "kubectl installation"

# Verify kubectl installation
kubectl version --client
check_command "kubectl verification"

# Clean up kubectl installer
rm -f kubectl
check_command "kubectl cleanup"

echo ""
echo "All installations completed successfully!"
echo "GitLab Runner, Docker, AWS CLI, and kubectl are now ready to use."
