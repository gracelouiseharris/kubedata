#!/bin/bash
set -euo pipefail

NAMESPACE="default"
TRIGGER="/shared/trigger_camera"

PODS=$(kubectl get pods -n "$NAMESPACE" -o name | cut -d/ -f2 | grep "camera-live" || true)
[ -n "${PODS:-}" ] || { echo "[ERROR] No matching pods"; exit 1; }

for POD in $PODS; do
  echo "[INFO] Removing trigger in pod: $POD via receiver-container"
  kubectl exec -n "$NAMESPACE" "$POD" -c receiver-container -- rm -f "$TRIGGER"
done

echo "[DONE]"
