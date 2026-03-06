#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-default}"
SELECTOR="${SELECTOR:-app=turtlebot3,component=bringup}"
CONTAINER="${CONTAINER:-turtlebot3-bringup}"
FILE="${FILE:-/shared/start_bringup}"

POD="$(kubectl -n "$NS" get pod -l "$SELECTOR" \
  --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].metadata.name}')"

echo "Using pod: $POD"

kubectl -n "$NS" exec "$POD" -c "$CONTAINER" -- sh -lc "set -eux; touch '$FILE'; ls -la /shared"
echo "Triggered: $FILE"