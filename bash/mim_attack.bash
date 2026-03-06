#!/bin/bash

NAMESPACE="default"

PODS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "lidar-live")

if [ -z "$PODS" ]; then
  echo "[ERROR] No pods with 'lidar' in the pod name found."
  exit 1
fi

for POD in $PODS; do
  echo "[INFO] Enabling attack in pod: $POD"
  kubectl exec -n "$NAMESPACE" -it "$POD" -c lidar-replayer -- bash -c 'echo "2" > /shared/trigger_lidar'
  
done

echo "[DONE] Lidar attacked"
