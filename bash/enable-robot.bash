#!/bin/bash

NAMESPACE="default"

echo "[INFO] Fetching robot pods in namespace '$NAMESPACE'..."

PODS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep -E "robot-controller|robot-hardware")

if [ -z "$PODS" ]; then
  echo "[ERROR] No robot pods found."
  exit 1
fi

for POD in $PODS; do
  echo "[INFO] Enabling packet capture in pod: $POD"

  kubectl exec -n "$NAMESPACE" -it "$POD" -- \
    /bin/sh -c "touch /shared/tcpdump_enable"

done

echo "[DONE] Packet capture enabled on all robot pods."
