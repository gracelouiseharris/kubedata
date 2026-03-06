#!/bin/bash
set -euo pipefail

NAMESPACE="default"
TRIGGER="/shared/trigger_lidar"

PODS=$(kubectl get pods -n "$NAMESPACE" -o name | cut -d/ -f2 | grep "lidar-live" || true)
[ -n "${PODS:-}" ] || { echo "[ERROR] No matching pods"; exit 1; }

for POD in $PODS; do
  echo "[INFO] Removing trigger in pod: $POD via lidar-publisher"
  kubectl exec -n "$NAMESPACE" "$POD" -c lidar-publisher -- rm -f "$TRIGGER"
done

echo "[DONE]"
