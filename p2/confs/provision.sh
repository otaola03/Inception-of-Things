#!/bin/bash

# Instalar K3s
curl -sfL https://get.k3s.io | sh -

# Esperar a que kubectl esté disponible
echo "⏳ Esperando a que K3s esté listo..."
while ! kubectl get nodes &>/dev/null; do
    sleep 5
done

echo "✅ K3s está listo"

# Instalar Ingress Nginx (sin validación por si hay problemas con el webhook)
echo "🚀 Desplegando Ingress Nginx..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml --validate=false

# Esperar a que el controlador de Ingress esté listo
echo "⏳ Esperando a que el pod ingress-nginx-controller esté listo y en ejecución..."

while true; do
    # Obtener la línea correspondiente al pod ingress-nginx-controller
    status_line=$(sudo kubectl get pods -n ingress-nginx | grep "ingress-nginx-controller")
    
    # Obtener el estado de 'READY' y 'STATUS'
    ready_status=$(echo "$status_line" | awk '{print $2}')
    pod_status=$(echo "$status_line" | awk '{print $3}')
    
	echo "line: $status_line"
    # Verificar si el pod está listo y en ejecución
    if [[ "$ready_status" == "1/1" && "$pod_status" == "Running" ]]; then
        echo "El pod ingress-nginx-controller está listo y en ejecución."
        break  # Salir del bucle una vez que la condición se cumpla
    fi
    
    # Si no está listo, esperar 5 segundos y volver a comprobar
    sleep 2
done

echo "✅ Ingress Nginx desplegado correctamente"

# Aplicar los deployments de las apps
echo "🚀 Desplegando aplicaciones..."
kubectl apply -f /shared/app-one.yaml --validate=false
kubectl apply -f /shared/app-two.yaml --validate=false
kubectl apply -f /shared/app-three.yaml --validate=false

# Esperar a que los pods estén en estado Running
echo "⏳ Esperando a que las aplicaciones estén listas..."
kubectl wait --for=condition=Ready pod --all --timeout=120s

# Aplicar el Ingress
echo "🚀 Configurando Ingress..."
kubectl apply -f /shared/ingress.yaml --validate=false

while true; do
    # Obtener la línea correspondiente al pod ingress-nginx-controller
    status_line=$(sudo kubectl get ing | grep "ingress")
    
    # Obtener el estado de 'READY' y 'STATUS'
    pod_status=$(echo "$status_line" | awk '{print $4}')
    
	echo "line: $status_line"
	echo "pod_status: $pod_status"
    # Verificar si el pod está listo y en ejecución
    if [[ "$pod_status" != "" ]]; then
        echo "El pod ingress-nginx-controller está listo y en ejecución."
        break  # Salir del bucle una vez que la condición se cumpla
    fi
    
    # Si no está listo, esperar 5 segundos y volver a comprobar
	echo "El pod ingress-nginx-controller no está listo o en ejecución. Esperando..."
    sleep 2
done

echo "✅ Configuración completada con éxito"
