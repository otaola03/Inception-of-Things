# Add Docker's official GPG key:
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
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install Kubectl:
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
if echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check | grep -q 'OK'; then
    echo "La verificación fue exitosa."
else
    echo "La verificación falló."
	return 1
fi

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Create a K3D cluster:
# sudo k3d cluster create my-cluster
# sudo k3d cluster create argocd-cluster --api-port 6550 --port 8080:80 --port 8443:443
# sudo k3d cluster create mycluster --api-port 6443 --port 8080:80@loadbalancer --port 8443:443@loadbalancer
sudo k3d cluster create mycluster -p "8080:80@loadbalancer"

# Install ArgoCD:
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Ingress Nginx:
# sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml --validate=false

# Create dev namespace:
sudo kubectl create namespace dev
