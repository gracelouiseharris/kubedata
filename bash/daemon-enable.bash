#!/bin/bash

NAMESPACE="default"

echo "[INFO] Fetching pods with 'lidar' in their name in namespace '$NAMESPACE'..."

PODS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "zeek-daemon")

if [ -z "$PODS" ]; then
  echo "[ERROR] No pods with 'zeek-daemon' in the pod name found."
  exit 1
fi

for POD in $PODS; do
  echo "[INFO] Enabling zeek in pod: $POD"
  kubectl exec -n "$NAMESPACE" -it "$POD" -c zeek -- /bin/sh -c "echo start > /shared/trigger_zeek"
  
done

echo "[DONE] Enabled zeek on all matching pods."
