#!/bin/bash

TOKEN=$(cat /shared/node-token)

echo "curl -sfL https://get.k3s.io | K3S_URL=https://$1:6443 K3S_TOKEN=\"$TOKEN\" sh -s - agent --node-name=worker-01"

curl -sfL https://get.k3s.io | K3S_URL=https://$1:6443 K3S_TOKEN="$TOKEN" sh -s - agent --node-name=worker-01

