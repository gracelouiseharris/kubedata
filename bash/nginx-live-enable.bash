#!/bin/bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-default}"
TRIGGER_FILE="/shared/tcpdump_enable"

# Pick a container that definitely has /shared mounted
CONTAINER_NAME="${CONTAINER_NAME:-nginx-main}"

echo "[INFO] Looking for pods in namespace '$NAMESPACE' matching app=nginx ..."
PODS=$(kubectl get pods -n "$NAMESPACE" -l app=nginx -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n')

if [ -z "${PODS:-}" ]; then
  echo "[ERROR] No pods found with label app=nginx in namespace $NAMESPACE"
  echo "        Tip: check your Deployment template labels and Service selector."
  exit 1
fi

for POD in $PODS; do
  echo "[INFO] Enabling trigger on pod: $POD (container: $CONTAINER_NAME)"
  kubectl exec -n "$NAMESPACE" -c "$CONTAINER_NAME" "$POD" -- /bin/sh -c \
    "mkdir -p /shared && printf '1' > '$TRIGGER_FILE' && echo -n '[INFO] trigger content=' && cat '$TRIGGER_FILE' && echo && ls -l '$TRIGGER_FILE'"
done

echo "[DONE] Trigger file set to '1' on all nginx pods."

