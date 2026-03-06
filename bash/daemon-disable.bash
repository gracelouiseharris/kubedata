#!/bin/bash

NAMESPACE="default"

echo "[INFO] Fetching pods with 'zeek-daemon' in their name in namespace '$NAMESPACE'..."

PODS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "zeek-daemon")

if [ -z "$PODS" ]; then
  echo "[ERROR] No pods with 'zeek' in the pod name found."
  exit 1
fi

for POD in $PODS; do
  echo "[INFO] Disabling zeek in pod: $POD"
  kubectl exec -n "$NAMESPACE" -it "$POD" -c zeek -- /bin/sh -c "rm -f /shared/trigger_zeek"
  
done

echo "[DONE] Disabled zeek on all matching pods."
