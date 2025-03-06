#!/bin/bash

curl -sfL https://get.k3s.io | sh -
sudo rc-update add k3s default
sudo rc-service k3s start

while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
  echo "Esperando a que se cree el archivo node-token..."
  sleep 5  # Espera 5 segundos antes de verificar nuevamente
done

cp /var/lib/rancher/k3s/server/node-token /shared/node-token

echo "El archivo node-token se ha movido a /shared."



