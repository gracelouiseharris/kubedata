#!/bin/bash

NAMESPACE="default"

echo "[INFO] Fetching pods with 'camera' in their name in namespace '$NAMESPACE'..."

PODS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "camera-live")

if [ -z "$PODS" ]; then
  echo "[ERROR] No pods with 'camera' in the pod name found."
  exit 1
fi

for POD in $PODS; do
  echo "[INFO] Enabling zeek-sidecar in pod: $POD"
  kubectl exec -n "$NAMESPACE" -it "$POD" -c zeek-sidecar -- /bin/sh -c "echo start > /shared/trigger_camera"
  
  echo "[INFO] Enabling receiver-container in pod: $POD"
  kubectl exec -n "$NAMESPACE" -it "$POD" -c receiver-container -- /bin/sh -c "echo 1 > /shared/trigger_camera"
done

echo "[DONE] Enabled zeek and camera publisher on all matching pods."
