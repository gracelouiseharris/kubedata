#!/bin/bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-default}"
TCPDUMP_TRIGGER="/shared/tcpdump_enable"
NMAP_TRIGGER="/shared/nmap_enable"

# Container that has /shared mounted
CONTAINER_NAME="${CONTAINER_NAME:-nginx-main}"

echo "[INFO] Looking for pods in namespace '$NAMESPACE' matching app=nginx ..."
PODS=$(kubectl get pods -n "$NAMESPACE" -l app=nginx -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n')

if [ -z "${PODS:-}" ]; then
  echo "[ERROR] No pods found with label app=nginx in namespace $NAMESPACE"
  exit 1
fi

for POD in $PODS; do
  echo "[INFO] Disabling triggers on pod: $POD (container: $CONTAINER_NAME)"

  kubectl exec -n "$NAMESPACE" -c "$CONTAINER_NAME" "$POD" -- /bin/sh -c "
    rm -f '$TCPDUMP_TRIGGER' '$NMAP_TRIGGER' && \
    echo '[INFO] Remaining trigger files:' && \
    ls -l /shared || true
  "
done

echo "[DONE] tcpdump/zeek/ptcpdump and nmap triggers disabled on all nginx pods."