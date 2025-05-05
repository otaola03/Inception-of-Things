#!/bin/bash

red='\033[31m'
green='\033[32m'
blue='\033[34m'
gold='\033[1m'
underline='\033[4m'
reset='\033[0m'

# Add Docker's official GPG key:
echo -e "${blue}🐋 Insatlling Docker${reset}"
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker Engine:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# Install K3D:
echo -e "${blue}🐋 Insatlling K3D${reset}"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash


echo -e "${blue}🐋 Insatlling Kubectl${reset}"
# Install Kubectl:
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
if echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check | grep -q 'OK'; then
    echo -e ${green}"La verificación fue exitosa.${reset}"
else
    echo -e ${red}"La verificación falló.${reset}"
	return 1
fi
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl



# Create a K3D cluster:
echo -e "${blue}📦 Creating k3d cluster${reset}"
# sudo k3d cluster create my-cluster
# sudo k3d cluster create argocd-cluster --api-port 6550 --port 8080:80 --port 8443:443
# sudo k3d cluster create mycluster --api-port 6443 --port 8080:80@loadbalancer --port 8443:443@loadbalancer
# sudo k3d cluster create mycluster -p "8080:80@loadbalancer"
sudo k3d cluster create mycluster -p "8082:80@loadbalancer"


# Install Ingress Nginx:
echo -e "${blue}📡 Installing Ingress Nginx${reset}"
sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml --validate=false

echo -e "${blue}⏳ Waiting for ingress-nginx-controller pod to be ready...${reset}"
while true; do
    # Obtener la línea correspondiente al pod ingress-nginx-controller
    status_line=$(sudo kubectl get pods -n ingress-nginx | grep "ingress-nginx-controller")
    
    # Obtener el estado de 'READY' y 'STATUS'
    ready_status=$(echo "$status_line" | awk '{print $2}')
    pod_status=$(echo "$status_line" | awk '{print $3}')
    
	echo "line: $status_line"
    # Verificar si el pod está listo y en ejecución
    if [[ "$ready_status" == "1/1" && "$pod_status" == "Running" ]]; then
        echo -e "${green}El pod ingress-nginx-controller está listo y en ejecución.${reset}"
        break  # Salir del bucle una vez que la condición se cumpla
    fi
    
    # Si no está listo, esperar 5 segundos y volver a comprobar
    sleep 2
done


# Install ArgoCD:
echo -e "${blue}📦 Installing ArgoCD${reset}"
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# Install Helm:
echo -e "${blue}📦 Installing Helm${reset}"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add gitlab Helm repository:
echo -e "${blue}🦊 Adding Gitlab Helm repository${reset}"
sudo helm repo add gitlab https://charts.gitlab.io
sudo helm repo update

# Install Gitlab:
echo -e "${blue}🦊 Installing Gitlab${reset}"
sudo kubectl create namespace gitlab
sudo helm install gitlab gitlab/gitlab -n gitlab -f /shared/values.yaml


# Create dev namespace:t
echo -e "${blue}📛 Creating dev namespace${reset}"
sudo kubectl create namespace dev
