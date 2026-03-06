#!/bin/bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-default}"
TRIGGER_FILE="/shared/tcpdump_enable"
CONTAINER_NAME="${CONTAINER_NAME:-nginx-main}"

echo "[INFO] Looking for pods in namespace '$NAMESPACE' matching app=nginx ..."
PODS=$(kubectl get pods -n "$NAMESPACE" -l app=nginx -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n')

if [ -z "${PODS:-}" ]; then
  echo "[ERROR] No pods found with label app=nginx in namespace $NAMESPACE"
  exit 1
fi

for POD in $PODS; do
  echo "[INFO] Disabling capture trigger on pod: $POD (container: $CONTAINER_NAME)"
  kubectl exec -n "$NAMESPACE" -c "$CONTAINER_NAME" "$POD" -- /bin/sh -c "rm -f $TRIGGER_FILE && echo '[INFO] removed' || true"
done

echo "[DONE] Trigger file removed on all nginx pods."
