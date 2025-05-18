#!/bin/bash

# Update the system
sudo apt update -y

sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
sudo apt update -y
sudo apt-get install -y kubectl

sudo snap install microk8s --classic --channel=1.29/stable
sudo usermod -a -G microk8s ubuntu
newgrp microk8s
wait 

# start microk8s
microk8s start 
wait

# Check status of microk8s
microk8s status 

# how to deploy a simple flask app on microk8s

#login to aws ecr
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 084828586638.dkr.ecr.us-east-1.amazonaws.com
# tag image
sudo docker tag myflask:v1 084828586638.dkr.ecr.us-east-1.amazonaws.com/my-ecr-repo:latest
# push image to ecr
sudo docker push 084828586638.dkr.ecr.us-east-1.amazonaws.com/my-ecr-repo:latest
# create a secret for ecr
microk8s kubectl create secret docker-registry ecr-secret \
  --docker-server=084828586638.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --namespace=default