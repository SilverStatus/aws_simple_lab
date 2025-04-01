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