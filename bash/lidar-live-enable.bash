#!/bin/bash

NAMESPACE="default"

echo "[INFO] Fetching pods with 'lidar' in their name in namespace '$NAMESPACE'..."

PODS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "lidar-live")

if [ -z "$PODS" ]; then
  echo "[ERROR] No pods with 'lidar' in the pod name found."
  exit 1
fi

for POD in $PODS; do
  echo "[INFO] Enabling zeek-sidecar in pod: $POD"
  kubectl exec -n "$NAMESPACE" -it "$POD" -c zeek-sidecar -- /bin/sh -c "echo start > /shared/trigger_lidar"
  
  echo "[INFO] Enabling lidar-publisher in pod: $POD"
  kubectl exec -n "$NAMESPACE" -it "$POD" -c lidar-publisher -- /bin/sh -c "echo 1 > /shared/trigger_lidar"
done

echo "[DONE] Enabled zeek and lidar publisher on all matching pods."
