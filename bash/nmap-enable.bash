#!/bin/bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-default}"
TCPDUMP_TRIGGER="/shared/tcpdump_enable"
NMAP_TRIGGER="/shared/nmap_enable"

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
  echo "[INFO] Enabling triggers on pod: $POD (container: $CONTAINER_NAME)"

  kubectl exec -n "$NAMESPACE" -c "$CONTAINER_NAME" "$POD" -- /bin/sh -c "
    mkdir -p /shared && \
    printf '1' > '$TCPDUMP_TRIGGER' && \
    touch '$NMAP_TRIGGER' && \
    echo '[INFO] tcpdump trigger:' && ls -l '$TCPDUMP_TRIGGER' && \
    echo '[INFO] nmap trigger:' && ls -l '$NMAP_TRIGGER'
  "
done

echo "[DONE] tcpdump/zeek/ptcpdump and nmap triggers enabled on all nginx pods."